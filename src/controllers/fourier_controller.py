from PySide6.QtCore import QObject, Signal, Slot, Property
from pathlib import Path
import cv2 as cv
import numpy as np
from logics.filters import filters
from typing import Dict, Any
from skimage.metrics import structural_similarity as ssim


class FourierController(QObject):
    imageLoaded = Signal(str)
    analysisReady = Signal()
    errorOccurred = Signal(str)

    def __init__(self):
        super().__init__()
        self._current_image_path = ""
        self._filter_instance = None
        self._original_image = None
        self._current_analysis = {
            'mse': 0.0,
            'psnr': 0.0,
            'ssim': 0.0
        }
        self._current_visualizations = {
            'spectrum_original_path': '',
            'spectrum_filtered_path': '',
            'mask_path': '',
            'filtered_image_path': ''
        }

    @Slot(str)
    def loadImage(self, file_path: str):
        """Carga imagen desde path (soporta file:// URLs)"""
        path = file_path.replace("file://", "")
        try:
            self._filter_instance = filters(path)
            self._original_image = cv.imread(path, cv.IMREAD_GRAYSCALE)
            self._current_image_path = path
            self.imageLoaded.emit(file_path)
            print(f"✅ Imagen cargada: {path}, shape: {self._original_image.shape}")
        except Exception as e:
            error_msg = f"Error al cargar imagen: {e}"
            print(error_msg)
            self.errorOccurred.emit(error_msg)

    def _normalize_image_shape(self, img: np.ndarray) -> np.ndarray:
        """Normaliza la imagen a 2D (escala de grises)"""
        if len(img.shape) == 3:
            # Convertir a escala de grises si tiene canales
            if img.shape[2] == 3:
                img = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
            elif img.shape[2] == 1:
                img = img[:, :, 0]
        return img

    @Slot(str, float)
    def applyFourierFilter(self, filterType: str, radio: float):
        """
        Aplica filtro de Fourier
        filterType: 'lowpass' o 'highpass'
        radio: float entre 0.01 y 0.5
        """
        if not self._current_image_path or self._original_image is None:
            self.errorOccurred.emit("No hay imagen cargada")
            return

        try:
            print(f"🔧 Aplicando filtro {filterType} con radio {radio}")

            # Aplicar filtro correspondiente
            if filterType == "lowpass":
                filtered_img, analysis, viz = self._filter_instance.ffts_filter_lowpass_detailed(radio)
            else:  # highpass
                filtered_img, analysis, viz = self._filter_instance.ffts_filter_highpass_detailed(radio)

            # DEBUG: Ver qué retorna el filtro
            print(f"🔍 Imagen filtrada - shape: {filtered_img.shape}, dtype: {filtered_img.dtype}, "
                  f"min: {filtered_img.min():.2f}, max: {filtered_img.max():.2f}")

            # Normalizar forma de imagen filtrada
            filtered_img_normalized = self._normalize_image_shape(filtered_img)

            print(f"📐 Shapes - Original: {self._original_image.shape}, Filtrada: {filtered_img_normalized.shape}")

            # Asegurar que ambas imágenes tengan las mismas dimensiones
            if self._original_image.shape != filtered_img_normalized.shape:
                filtered_img_normalized = cv.resize(
                    filtered_img_normalized,
                    (self._original_image.shape[1], self._original_image.shape[0])
                )
                print(f"⚠️ Imagen redimensionada a: {filtered_img_normalized.shape}")

            # IMPORTANTE: Asegurar que AMBAS estén en uint8 [0, 255]
            orig_uint8 = self._original_image.astype(np.uint8)
            filt_uint8 = np.clip(filtered_img_normalized, 0, 255).astype(np.uint8)

            print(f"🔍 Rangos - Original: [{orig_uint8.min()}, {orig_uint8.max()}], "
                  f"Filtrada: [{filt_uint8.min()}, {filt_uint8.max()}]")

            # DEBUG: Ver diferencias píxel a píxel
            diff = np.abs(orig_uint8.astype(np.float32) - filt_uint8.astype(np.float32))
            print(f"🔍 Diferencia - min: {diff.min():.2f}, max: {diff.max():.2f}, mean: {diff.mean():.2f}")
            print(
                f"🔍 Píxeles diferentes: {np.count_nonzero(diff)} de {diff.size} ({np.count_nonzero(diff) / diff.size * 100:.2f}%)")

            # Verificar si las imágenes son idénticas
            if np.array_equal(orig_uint8, filt_uint8):
                print("⚠️ ADVERTENCIA: Las imágenes son IDÉNTICAS - el filtro no tuvo efecto")
                ssim_value = 1.0
            else:
                # Calcular SSIM con data_range=255 (rango de uint8)
                win_size = min(7,
                               min(orig_uint8.shape) if min(orig_uint8.shape) % 2 == 1 else min(orig_uint8.shape) - 1)
                ssim_value = ssim(
                    orig_uint8,
                    filt_uint8,
                    data_range=255,
                    win_size=win_size
                )

            print(f"📊 Análisis - MSE={analysis.get('mse')}, PSNR={analysis.get('psnr')}, SSIM={ssim_value:.4f}")

            # Guardar temporalmente las visualizaciones
            temp_dir = Path("/tmp/fourier_analysis")
            temp_dir.mkdir(exist_ok=True)

            spectrum_orig_path = temp_dir / "spectrum_original.png"
            spectrum_filt_path = temp_dir / "spectrum_filtered.png"
            mask_path = temp_dir / "mask.png"
            filtered_path = temp_dir / "filtered_image.png"

            # Normalizar espectros para visualización (0-255)
            spectrum_orig_norm = cv.normalize(viz['espectro_original'], None, 0, 255, cv.NORM_MINMAX, dtype=cv.CV_8U)
            spectrum_filt_norm = cv.normalize(viz['espectro_filtrado'], None, 0, 255, cv.NORM_MINMAX, dtype=cv.CV_8U)

            # Convertir máscara float a uint8
            mask_norm = (viz['mask'] * 255).astype(np.uint8)

            cv.imwrite(str(spectrum_orig_path), spectrum_orig_norm)
            cv.imwrite(str(spectrum_filt_path), spectrum_filt_norm)
            cv.imwrite(str(mask_path), mask_norm)
            cv.imwrite(str(filtered_path), filt_uint8)

            # Almacenar análisis con SSIM calculado
            self._current_analysis = {
                'mse': float(analysis.get('mse', 0.0)),
                'psnr': float(analysis.get('psnr', 0.0)),
                'ssim': float(ssim_value)
            }

            self._current_visualizations = {
                'spectrum_original_path': f"file://{spectrum_orig_path}",
                'spectrum_filtered_path': f"file://{spectrum_filt_path}",
                'mask_path': f"file://{mask_path}",
                'filtered_image_path': f"file://{filtered_path}"
            }

            print(f"✅ SSIM: {self._current_analysis['ssim']:.4f} ({self._current_analysis['ssim'] * 100:.2f}%)")

            self.analysisReady.emit()
            print("🔔 Signal analysisReady emitido")

        except Exception as e:
            error_msg = f"Error al aplicar filtro: {e}"
            print(error_msg)
            import traceback
            traceback.print_exc()
            self.errorOccurred.emit(error_msg)


    @Slot(float, result='QVariantMap')
    def compareFilters(self, radio: float) -> Dict[str, Any]:
        """Compara filtros lowpass y highpass"""
        if not self._current_image_path or self._original_image is None:
            self.errorOccurred.emit("No hay imagen cargada")
            return {}

        try:
            print(f"⚖️ Comparando filtros con radio {radio}")

            # Aplicar ambos filtros
            lowpass_img, low_analysis, low_viz = self._filter_instance.ffts_filter_lowpass_detailed(radio)
            highpass_img, high_analysis, high_viz = self._filter_instance.ffts_filter_highpass_detailed(radio)

            # Normalizar formas
            lowpass_img_norm = self._normalize_image_shape(lowpass_img)
            highpass_img_norm = self._normalize_image_shape(highpass_img)

            # Redimensionar si es necesario
            if lowpass_img_norm.shape != self._original_image.shape:
                lowpass_img_norm = cv.resize(lowpass_img_norm,
                                             (self._original_image.shape[1], self._original_image.shape[0]))
            if highpass_img_norm.shape != self._original_image.shape:
                highpass_img_norm = cv.resize(highpass_img_norm,
                                              (self._original_image.shape[1], self._original_image.shape[0]))

            # Convertir a uint8
            orig_uint8 = self._original_image.astype(np.uint8)
            low_uint8 = np.clip(lowpass_img_norm, 0, 255).astype(np.uint8)
            high_uint8 = np.clip(highpass_img_norm, 0, 255).astype(np.uint8)

            # Calcular SSIM con data_range=255
            low_ssim = ssim(orig_uint8, low_uint8, data_range=255)
            high_ssim = ssim(orig_uint8, high_uint8, data_range=255)

            # Calcular nitidez
            low_sharpness = cv.Laplacian(low_uint8, cv.CV_64F).var()
            high_sharpness = cv.Laplacian(high_uint8, cv.CV_64F).var()

            # Guardar temporalmente
            temp_dir = Path("/tmp/fourier_comparison")
            temp_dir.mkdir(exist_ok=True)

            low_path = temp_dir / "lowpass_comparison.png"
            high_path = temp_dir / "highpass_comparison.png"

            cv.imwrite(str(low_path), low_uint8)
            cv.imwrite(str(high_path), high_uint8)

            result = {
                'lowpass_path': f"file://{low_path}",
                'highpass_path': f"file://{high_path}",
                'lowpass_mse': float(low_analysis.get('mse', 0.0)),
                'highpass_mse': float(high_analysis.get('mse', 0.0)),
                'lowpass_psnr': float(low_analysis.get('psnr', 0.0)),
                'highpass_psnr': float(high_analysis.get('psnr', 0.0)),
                'lowpass_ssim': float(low_ssim),
                'highpass_ssim': float(high_ssim),
                'lowpass_sharpness': float(low_sharpness),
                'highpass_sharpness': float(high_sharpness)
            }

            print(
                f"✅ Comparación - Low SSIM: {low_ssim:.4f} ({low_ssim * 100:.2f}%), High SSIM: {high_ssim:.4f} ({high_ssim * 100:.2f}%)")
            return result

        except Exception as e:
            error_msg = f"Error en comparación: {e}"
            print(error_msg)
            import traceback
            traceback.print_exc()
            self.errorOccurred.emit(error_msg)
            return {}

    @Property('QVariantMap', notify=analysisReady)
    def currentAnalysis(self) -> Dict[str, Any]:
        return self._current_analysis

    @Property('QVariantMap', notify=analysisReady)
    def currentVisualizations(self) -> Dict[str, str]:
        return self._current_visualizations