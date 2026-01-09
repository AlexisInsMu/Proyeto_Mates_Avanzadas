import numpy as np
import cv2 as cv
from pathlib import Path
import urllib.parse


class filters:
    image_path: str = None
    _cached_image = None

    def __init__(self, image_path: str):
        if image_path is None:
            raise ValueError("Dime la dirección de la imagen")

        # ✅ Limpiar y normalizar ruta
        clean_path = self._clean_path(image_path)

        # ✅ Verificar que la imagen existe y se puede leer
        test_img = cv.imread(clean_path)
        if test_img is None:
            raise ValueError(f"No se puede leer la imagen: {clean_path}")

        self.image_path = clean_path
        self.image = test_img  # Usar imagen ya cargada
        self._cached_image = test_img
        print(f"Imagen cargada correctamente: {clean_path}")

    @staticmethod
    def _clean_path(path: str) -> str:
        """Limpia y normaliza rutas para Windows/Linux"""
        # Remover file://
        path = path.replace("file://", "")

        # Decodificar URL encoding (%20 -> espacio)
        path = urllib.parse.unquote(path)

        # Convertir a Path
        path_obj = Path(path)

        # En Windows, remover `/` inicial si existe (ej: /C:/...)
        if path_obj.parts and len(path_obj.parts[0]) == 1 and path_obj.parts[0].isalpha():
            path = str(path_obj).lstrip('/')

        return str(Path(path).resolve())

    # Métodos principales que retornan solo la imagen (para la UI)
    def ffts_filter_lowpass(self, radio: float = 0.14):
        """Filtro pasa bajas: suaviza la imagen, elimina ruido"""
        result, _, _ = self.ffts_filter_lowpass_detailed(radio)
        return result

    def ffts_filter_highpass(self, radio: float = 0.14):
        """Filtro pasa altas: realza bordes y detalles"""
        result, _, _ = self.ffts_filter_highpass_detailed(radio)
        return result

    # Métodos detallados con toda la información
    def ffts_filter_lowpass_detailed(self, radio: float = 0.14):
        """Filtro pasa bajas con análisis completo

        Retorna:
            tuple: (imagen_filtrada, análisis_dict, visualizaciones_dict)
        """
        Nf, Nc = self.image.shape[:2]

        # Malla de frecuencias normalizadas
        fx = np.arange(-Nc // 2, Nc // 2)
        fy = np.arange(-Nf // 2, Nf // 2)
        X, Y = np.meshgrid(fx, fy)
        D = np.sqrt(X.astype(float) ** 2 + Y.astype(float) ** 2)
        D = D / (D.max() if D.max() != 0 else 1.0)

        # Máscara pasa bajas
        mask = (D < radio).astype(np.float64)

        # Procesar cada canal
        channels = cv.split(self.image)
        filtered_channels = []
        all_analysis = []

        for ch in channels:
            img_filtered, analysis = self.__process_channels_fft_detailed(ch, mask, "lowpass", radio)
            filtered_channels.append(img_filtered)
            all_analysis.append(analysis)

        filtered_image = cv.merge(filtered_channels)

        # Calcular métricas globales
        mse = np.mean((self.image.astype(float) - filtered_image.astype(float)) ** 2)
        psnr = 20 * np.log10(255.0 / np.sqrt(mse)) if mse > 0 else float('inf')

        total_freq = D.size
        freq_passed = np.sum(mask)
        freq_blocked = total_freq - freq_passed

        analysis_dict = {
            "mse": float(mse),
            "psnr": float(psnr),
            "radio_cutoff": radio,
            "frecuencias_pasadas": int(freq_passed),
            "frecuencias_bloqueadas": int(freq_blocked),
            "porcentaje_pasado": float(freq_passed / total_freq * 100),
            "tipo_filtro": "pasa-bajas",
            "canales": all_analysis
        }

        visualizations_dict = {
            "mask": mask,
            "frequency_grid": D,
            "espectro_original": all_analysis[0]["espectro_original"],
            "espectro_filtrado": all_analysis[0]["espectro_filtrado"]
        }

        return filtered_image, analysis_dict, visualizations_dict

    def ffts_filter_highpass_detailed(self, radio: float = 0.14):
        """Filtro pasa altas con análisis completo"""
        Nf, Nc = self.image.shape[:2]

        fx = np.arange(-Nc // 2, Nc // 2)
        fy = np.arange(-Nf // 2, Nf // 2)
        X, Y = np.meshgrid(fx, fy)
        D = np.sqrt(X.astype(float) ** 2 + Y.astype(float) ** 2)
        D = D / (D.max() if D.max() != 0 else 1.0)

        mask = (D >= radio).astype(np.float64)

        channels = cv.split(self.image)
        filtered_channels = []
        all_analysis = []

        for ch in channels:
            img_filtered, analysis = self.__process_channels_fft_detailed(ch, mask, "highpass", radio)
            filtered_channels.append(img_filtered)
            all_analysis.append(analysis)

        filtered_image = cv.merge(filtered_channels)

        mse = np.mean((self.image.astype(float) - filtered_image.astype(float)) ** 2)
        psnr = 20 * np.log10(255.0 / np.sqrt(mse)) if mse > 0 else float('inf')

        total_freq = D.size
        freq_passed = np.sum(mask)
        freq_blocked = total_freq - freq_passed

        analysis_dict = {
            "mse": float(mse),
            "psnr": float(psnr),
            "radio_cutoff": radio,
            "frecuencias_pasadas": int(freq_passed),
            "frecuencias_bloqueadas": int(freq_blocked),
            "porcentaje_pasado": float(freq_passed / total_freq * 100),
            "tipo_filtro": "pasa-altas",
            "canales": all_analysis
        }

        visualizations_dict = {
            "mask": mask,
            "frequency_grid": D,
            "espectro_original": all_analysis[0]["espectro_original"],
            "espectro_filtrado": all_analysis[0]["espectro_filtrado"]
        }

        return filtered_image, analysis_dict, visualizations_dict

    def apply_median_filter(self, ksize: int = 5):
        """Filtro de Mediana: elimina ruido sal y pimienta"""
        ksize = int(ksize)
        ksize = max(1, ksize)
        if ksize % 2 == 0:
            ksize += 1

        return cv.medianBlur(self.image, ksize)

    def apply_gaussian_filter(self, ksize: int = 5, sigma: float = 1.0):
        """Filtro Gaussiano: suaviza preservando bordes"""
        ksize = int(ksize)
        ksize = max(1, ksize)
        if ksize % 2 == 0:
            ksize += 1

        return cv.GaussianBlur(self.image, (ksize, ksize), sigma)

    def compare_filters(self, radio: float = 0.14):
        """Compara filtro pasa-bajas vs pasa-altas"""
        lowpass_img, lowpass_analysis, lowpass_viz = self.ffts_filter_lowpass_detailed(radio)
        highpass_img, highpass_analysis, highpass_viz = self.ffts_filter_highpass_detailed(radio)

        original_sharpness = cv.Laplacian(self.image, cv.CV_64F).var()
        lowpass_sharpness = cv.Laplacian(lowpass_img, cv.CV_64F).var()
        highpass_sharpness = cv.Laplacian(highpass_img, cv.CV_64F).var()

        return {
            "lowpass": {
                "imagen": lowpass_img,
                "analisis": lowpass_analysis,
                "visualizaciones": lowpass_viz,
                "nitidez": float(lowpass_sharpness)
            },
            "highpass": {
                "imagen": highpass_img,
                "analisis": highpass_analysis,
                "visualizaciones": highpass_viz,
                "nitidez": float(highpass_sharpness)
            },
            "original": {
                "nitidez": float(original_sharpness)
            },
            "comparacion": {
                "diferencia_mse": abs(lowpass_analysis["mse"] - highpass_analysis["mse"]),
                "diferencia_nitidez": {
                    "lowpass_vs_original": float(lowpass_sharpness - original_sharpness),
                    "highpass_vs_original": float(highpass_sharpness - original_sharpness)
                }
            }
        }

    def __process_channels_fft_detailed(self, ch, mask, filter_type, cutoff_radius):
        """Procesa un canal con FFT y retorna análisis detallado"""
        ch_f = ch.astype(np.float64)

        F = np.fft.fft2(ch_f)
        Fshift = np.fft.fftshift(F)

        magnitude_spec_original = 20 * np.log10(np.abs(Fshift) + 1e-8)

        G_shift = Fshift * mask

        magnitude_spec_filtered = 20 * np.log10(np.abs(G_shift) + 1e-8)

        G = np.fft.ifftshift(G_shift)
        img_filtered = np.fft.ifft2(G)
        img_filtered = np.abs(img_filtered)
        img_filtered = np.clip(img_filtered, 0, 255).astype(np.uint8)

        energy_original = np.sum(np.abs(Fshift) ** 2)
        energy_filtered = np.sum(np.abs(G_shift) ** 2)
        energy_retained = (energy_filtered / energy_original * 100) if energy_original > 0 else 0

        analysis = {
            "espectro_original": magnitude_spec_original,
            "espectro_filtrado": magnitude_spec_filtered,
            "energia_original": float(energy_original),
            "energia_filtrada": float(energy_filtered),
            "energia_retenida_porcentaje": float(energy_retained),
            "media_original": float(np.mean(ch)),
            "media_filtrada": float(np.mean(img_filtered)),
            "std_original": float(np.std(ch)),
            "std_filtrada": float(np.std(img_filtered)),
            "min_max_original": (float(np.min(ch)), float(np.max(ch))),
            "min_max_filtrada": (float(np.min(img_filtered)), float(np.max(img_filtered)))
        }

        return img_filtered, analysis

    def __process_channels_fft(self, ch, mask):
        """Versión simplificada para compatibilidad"""
        img_filtered, analysis = self.__process_channels_fft_detailed(ch, mask, "generic", 0.0)
        return img_filtered, analysis["espectro_original"]

    def __str__(self):
        return f"Filtros aplicados a {self.image_path}"

    def __del__(self):
        if hasattr(super(), '__del__'):
            super().__del__()