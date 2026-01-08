import cv2 as cv
import numpy as np
from skimage.metrics import structural_similarity as ssim
import matplotlib.pyplot as plt
from pathlib import Path
import urllib.parse


class comparative:
    img_path_original = ""
    img_path_processed = ""
    image_original = None
    image_processed = None

    def __init__(self, path_original: str, path_processed: str):
        # ✅ Limpiar rutas
        self.img_path_original = self._clean_path(path_original)
        self.img_path_processed = self._clean_path(path_processed)

        try:
            # ✅ Cargar y validar imágenes
            self.image_original = cv.imread(self.img_path_original)
            if self.image_original is None:
                raise ValueError(f"No se puede leer imagen original: {self.img_path_original}")

            self.image_processed = cv.imread(self.img_path_processed)
            if self.image_processed is None:
                raise ValueError(f"No se puede leer imagen procesada: {self.img_path_processed}")

            # ✅ Verificar que tengan las mismas dimensiones
            if self.image_original.shape != self.image_processed.shape:
                raise ValueError(
                    f"Las imágenes tienen diferentes dimensiones: "
                    f"Original {self.image_original.shape} vs Procesada {self.image_processed.shape}"
                )

            print(f"Imágenes cargadas correctamente para comparación")

        except Exception as e:
            raise ValueError(f"Error al cargar las imágenes: {str(e)}")

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

    def compare(self):
        """Compara métricas entre las dos imágenes"""
        # Convertir a escala de grises para la comparación
        gray_original = cv.cvtColor(self.image_original, cv.COLOR_BGR2GRAY)
        gray_processed = cv.cvtColor(self.image_processed, cv.COLOR_BGR2GRAY)

        # SSIM (Structural Similarity Index)
        ssim_value = ssim(gray_original, gray_processed)

        # PSNR (Peak Signal-to-Noise Ratio)
        psnr_value = cv.PSNR(self.image_original, self.image_processed)

        # MSE (Mean Squared Error)
        mse_value = np.mean((self.image_original.astype(float) - self.image_processed.astype(float)) ** 2)

        # Crear gráfica comparativa
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))

        metrics = ['SSIM', 'PSNR', 'MSE']
        values = [ssim_value, psnr_value, mse_value]
        colors = ['green', 'blue', 'red']

        for i, (metric, value, color) in enumerate(zip(metrics, values, colors)):
            axes[i].bar([metric], [value], color=color)
            axes[i].set_title(f'{metric}: {value:.4f}', fontsize=14, fontweight='bold')
            axes[i].set_ylabel('Value', fontsize=12)
            axes[i].grid(axis='y', alpha=0.3)

        plt.suptitle('Comparación de Métricas de Calidad', fontsize=16, fontweight='bold')
        plt.tight_layout()

        return fig

    def get_histograms(self):
        """Genera histogramas de ambas imágenes"""
        fig, axes = plt.subplots(2, 3, figsize=(15, 10))

        # Histogramas de la imagen original
        colors = ('b', 'g', 'r')
        for i, color in enumerate(colors):
            hist = cv.calcHist([self.image_original], [i], None, [256], [0, 256])
            axes[0, i].plot(hist, color=color, linewidth=2)
            axes[0, i].set_title(f'Original - Canal {color.upper()}', fontsize=12, fontweight='bold')
            axes[0, i].set_xlim([0, 256])
            axes[0, i].set_ylabel('Frecuencia')
            axes[0, i].grid(alpha=0.3)

        # Histogramas de la imagen procesada
        for i, color in enumerate(colors):
            hist = cv.calcHist([self.image_processed], [i], None, [256], [0, 256])
            axes[1, i].plot(hist, color=color, linewidth=2)
            axes[1, i].set_title(f'Procesada - Canal {color.upper()}', fontsize=12, fontweight='bold')
            axes[1, i].set_xlim([0, 256])
            axes[1, i].set_xlabel('Intensidad')
            axes[1, i].set_ylabel('Frecuencia')
            axes[1, i].grid(alpha=0.3)

        plt.suptitle('Comparación de Histogramas RGB', fontsize=16, fontweight='bold')
        plt.tight_layout()

        return fig

    def get_difference_map(self):
        """Genera mapa de diferencias entre las imágenes"""
        # Calcular diferencia absoluta
        diff = cv.absdiff(self.image_original, self.image_processed)

        # Convertir a escala de grises para visualización
        diff_gray = cv.cvtColor(diff, cv.COLOR_BGR2GRAY)

        # Crear figura
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))

        # Imagen original
        axes[0].imshow(cv.cvtColor(self.image_original, cv.COLOR_BGR2RGB))
        axes[0].set_title('Original', fontsize=14, fontweight='bold')
        axes[0].axis('off')

        # Imagen procesada
        axes[1].imshow(cv.cvtColor(self.image_processed, cv.COLOR_BGR2RGB))
        axes[1].set_title('Procesada', fontsize=14, fontweight='bold')
        axes[1].axis('off')

        # Mapa de diferencias
        im = axes[2].imshow(diff_gray, cmap='hot')
        axes[2].set_title('Mapa de Diferencias', fontsize=14, fontweight='bold')
        axes[2].axis('off')
        plt.colorbar(im, ax=axes[2], fraction=0.046)

        plt.suptitle('Análisis Visual de Diferencias', fontsize=16, fontweight='bold')
        plt.tight_layout()

        return fig

    def get_metrics_dict(self):
        """Retorna diccionario con todas las métricas"""
        gray_original = cv.cvtColor(self.image_original, cv.COLOR_BGR2GRAY)
        gray_processed = cv.cvtColor(self.image_processed, cv.COLOR_BGR2GRAY)

        return {
            "ssim": float(ssim(gray_original, gray_processed)),
            "psnr": float(cv.PSNR(self.image_original, self.image_processed)),
            "mse": float(np.mean((self.image_original.astype(float) - self.image_processed.astype(float)) ** 2)),
            "mae": float(np.mean(np.abs(self.image_original.astype(float) - self.image_processed.astype(float)))),
            "dimensiones_original": self.image_original.shape,
            "dimensiones_procesada": self.image_processed.shape
        }

    def __del__(self):
        print("adiós comparative")