import cv2 as cv
import numpy as np
from skimage.metrics import structural_similarity as ssim
import matplotlib.pyplot as plt

class comparative:
    img_path_original = ""
    img_path_processed = ""
    image_original = None
    image_processed = None

    def __init__(self, path_original: str, path_processed: str):
        self.img_path_original = path_original
        self.img_path_processed = path_processed
        try:
            self.image_original = cv.imread(self.img_path_original)
            self.image_processed = cv.imread(self.img_path_processed)
        except Exception as e:
            raise ValueError("Error al cargar las imágenes: " + str(e))

    def compare(self):
        # Convertir a escala de grises para la comparación
        gray_original = cv.cvtColor(self.image_original, cv.COLOR_BGR2GRAY)
        gray_processed = cv.cvtColor(self.image_processed, cv.COLOR_BGR2GRAY)

        # SSIM
        ssim_value = ssim(gray_original, gray_processed)

        # PSNR
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
            axes[i].set_title(f'{metric}: {value:.4f}')
            axes[i].set_ylabel('Value')

        plt.tight_layout()

        return fig

    def get_histograms(self):
        fig, axes = plt.subplots(2, 3, figsize=(15, 10))

        # Histogramas de la imagen original
        colors = ('b', 'g', 'r')
        for i, color in enumerate(colors):
            hist = cv.calcHist([self.image_original], [i], None, [256], [0, 256])
            axes[0, i].plot(hist, color=color)
            axes[0, i].set_title(f'Original - Canal {color.upper()}')
            axes[0, i].set_xlim([0, 256])

        # Histogramas de la imagen procesada
        for i, color in enumerate(colors):
            hist = cv.calcHist([self.image_processed], [i], None, [256], [0, 256])
            axes[1, i].plot(hist, color=color)
            axes[1, i].set_title(f'Procesada - Canal {color.upper()}')
            axes[1, i].set_xlim([0, 256])

        plt.tight_layout()

        return fig

    def __del__(self):
        print("adiós comparative")
