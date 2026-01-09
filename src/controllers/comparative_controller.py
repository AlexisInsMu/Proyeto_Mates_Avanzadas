from PySide6.QtCore import QObject, Signal, Slot, Property
from pathlib import Path
import cv2 as cv
import numpy as np
from skimage.metrics import structural_similarity as ssim
import tempfile


class ComparativeController(QObject):
    image1Loaded = Signal(str)
    image2Loaded = Signal(str)
    diffImageReady = Signal(str)
    histogram1Ready = Signal(str)
    histogram2Ready = Signal(str)
    metricsChanged = Signal()

    def __init__(self):
        super().__init__()
        self._img1 = None
        self._img2 = None
        self._img1_path = ""
        self._img2_path = ""

        # Métricas individuales
        self._mse = 0.0
        self._psnr = 0.0
        self._mae = 0.0
        self._ssim = 0.0
        self._correlation = 0.0
        self._color_diff = 0.0
        self._resolution1 = ""
        self._resolution2 = ""
        self._size_match = ""

    @Slot(str)
    def loadImage1(self, file_path):
        path = file_path.replace("file://", "")
        try:
            self._img1 = cv.imread(path)
            self._img1_path = file_path
            self._resolution1 = f"{self._img1.shape[1]}x{self._img1.shape[0]}"
            self.image1Loaded.emit(file_path)
            self._generateHistogram(self._img1, 1)
            if self._img2 is not None:
                self._calculateMetrics()
        except Exception as e:
            print(f"Error loading image 1: {e}")

    @Slot(str)
    def loadImage2(self, file_path):
        path = file_path.replace("file://", "")
        try:
            self._img2 = cv.imread(path)
            self._img2_path = file_path
            self._resolution2 = f"{self._img2.shape[1]}x{self._img2.shape[0]}"
            self.image2Loaded.emit(file_path)
            self._generateHistogram(self._img2, 2)
            if self._img1 is not None:
                self._calculateMetrics()
        except Exception as e:
            print(f"Error loading image 2: {e}")

    def _generateHistogram(self, img, img_num):
        """Genera histograma RGB"""
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        colors = ('b', 'g', 'r')
        plt.figure(figsize=(8, 4))

        for i, color in enumerate(colors):
            hist = cv.calcHist([img], [i], None, [256], [0, 256])
            plt.plot(hist, color=color, label=f'Canal {color.upper()}')

        plt.xlim([0, 256])
        plt.xlabel('Intensidad de píxel')
        plt.ylabel('Frecuencia')
        plt.title(f'Histograma Imagen {img_num}')
        plt.legend()
        plt.grid(alpha=0.3)

        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.png')
        plt.savefig(temp_file.name, bbox_inches='tight', dpi=100)
        plt.close()

        if img_num == 1:
            self.histogram1Ready.emit(f"file://{temp_file.name}")
        else:
            self.histogram2Ready.emit(f"file://{temp_file.name}")

    def _calculateMetrics(self):
        if self._img1 is None or self._img2 is None:
            return

        # Redimensionar si es necesario
        if self._img1.shape != self._img2.shape:
            h = min(self._img1.shape[0], self._img2.shape[0])
            w = min(self._img1.shape[1], self._img2.shape[1])
            img1_resized = cv.resize(self._img1, (w, h))
            img2_resized = cv.resize(self._img2, (w, h))
            self._size_match = f"Redimensionadas a {w}x{h}"
        else:
            img1_resized = self._img1
            img2_resized = self._img2
            self._size_match = "Tamaños idénticos"

        # MSE
        self._mse = float(np.mean((img1_resized.astype(float) - img2_resized.astype(float)) ** 2))

        # PSNR
        if self._mse == 0:
            self._psnr = float('inf')
        else:
            self._psnr = float(20 * np.log10(255.0 / np.sqrt(self._mse)))

        # MAE
        self._mae = float(np.mean(np.abs(img1_resized.astype(float) - img2_resized.astype(float))))

        # SSIM (Structural Similarity Index)
        gray1 = cv.cvtColor(img1_resized, cv.COLOR_BGR2GRAY)
        gray2 = cv.cvtColor(img2_resized, cv.COLOR_BGR2GRAY)
        self._ssim = float(ssim(gray1, gray2))

        # Correlación
        self._correlation = float(np.corrcoef(img1_resized.flatten(), img2_resized.flatten())[0, 1])

        # Diferencia de color promedio
        mean1 = np.mean(img1_resized, axis=(0, 1))
        mean2 = np.mean(img2_resized, axis=(0, 1))
        self._color_diff = float(np.mean(np.abs(mean1 - mean2)))

        # Generar imagen de diferencia
        self._generateDifferenceImage(img1_resized, img2_resized)

        self.metricsChanged.emit()

    def _generateDifferenceImage(self, img1, img2):
        """Genera imagen con diferencias visuales"""
        # Diferencia absoluta
        diff = cv.absdiff(img1, img2)

        # Aumentar contraste para visualización
        diff_enhanced = cv.normalize(diff, None, 0, 255, cv.NORM_MINMAX)

        # Convertir a mapa de calor
        gray_diff = cv.cvtColor(diff_enhanced, cv.COLOR_BGR2GRAY)
        heatmap = cv.applyColorMap(gray_diff, cv.COLORMAP_JET)

        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.png')
        cv.imwrite(temp_file.name, heatmap)
        self.diffImageReady.emit(f"file://{temp_file.name}")

    # Properties
    @Property(float, notify=metricsChanged)
    def mse(self):
        return round(self._mse, 4)

    @Property(str, notify=metricsChanged)
    def psnr(self):
        if self._psnr == float('inf'):
            return "∞ (idénticas)"
        return f"{self._psnr:.2f} dB"

    @Property(float, notify=metricsChanged)
    def mae(self):
        return round(self._mae, 4)

    @Property(str, notify=metricsChanged)
    def ssim(self):
        return f"{self._ssim:.4f}"

    @Property(str, notify=metricsChanged)
    def correlation(self):
        return f"{self._correlation:.4f}"

    @Property(float, notify=metricsChanged)
    def colorDiff(self):
        return round(self._color_diff, 2)

    @Property(str, notify=metricsChanged)
    def resolution1(self):
        return self._resolution1

    @Property(str, notify=metricsChanged)
    def resolution2(self):
        return self._resolution2

    @Property(str, notify=metricsChanged)
    def sizeMatch(self):
        return self._size_match

    @Slot()
    def reset(self):
        self._img1 = None
        self._img2 = None
        self._img1_path = ""
        self._img2_path = ""
        self._mse = 0.0
        self._psnr = 0.0
        self._mae = 0.0
        self._ssim = 0.0
        self._correlation = 0.0
        self._color_diff = 0.0
        self._resolution1 = ""
        self._resolution2 = ""
        self._size_match = ""
        self.metricsChanged.emit()
