import cv2 as cv
import numpy as np
import random as rd
from pathlib import Path
import urllib.parse


class GenerateNoise:
    img_path: str = None
    _cached_image = None  # ✅ Cachear imagen para no recargar

    def __init__(self, image_path: str):
        if image_path is None:
            raise ValueError("Dime la dirección de la imagen")

        # ✅ Limpiar y normalizar ruta
        clean_path = self._clean_path(image_path)

        # ✅ Verificar que la imagen existe y se puede leer
        test_img = cv.imread(clean_path)
        if test_img is None:
            raise ValueError(f"No se puede leer la imagen: {clean_path}")

        self.img_path = clean_path
        self._cached_image = test_img  # Cachear imagen
        print(f"Imagen cargada correctamente: {clean_path}")

    @staticmethod
    def _clean_path(path: str) -> str:
        """Limpia y normaliza rutas para Windows/Linux"""
        # Remover file://
        path = path.replace("file://", "")

        # Decodificar URL encoding (%20 -> espacio)
        path = urllib.parse.unquote(path)

        # Convertir a Path y luego a string absoluto
        path_obj = Path(path)

        # En Windows, remover `/` inicial si existe (ej: /C:/...)
        if path_obj.parts and len(path_obj.parts[0]) == 1 and path_obj.parts[0].isalpha():
            # Es una ruta de Windows mal formada
            path = str(path_obj).lstrip('/')

        return str(Path(path).resolve())

    def _load_image(self):
        """Carga la imagen (usa caché si está disponible)"""
        if self._cached_image is not None:
            return self._cached_image.copy()

        img = cv.imread(self.img_path)
        if img is None:
            raise ValueError(f"Error al leer imagen: {self.img_path}")
        return img

    def impulsive_noise(self, noise_percentage=0):
        """Ruido sal y pimienta"""
        if noise_percentage <= 0 or noise_percentage > 100:
            print("Porcentaje inválido")
            return self._load_image()  # ✅ Retornar imagen original

        image = self._load_image()
        self.size_img = image.shape[0] * image.shape[1]
        self.noise_percentage_to_use = (noise_percentage * self.size_img) / 200

        if image.shape[2] > 1:
            self.pepper = [0, 0, 0]
            self.salt = [255, 255, 255]
        else:
            self.pepper = 0
            self.salt = 255

        # Pixeles blancos
        for x in range(int(self.noise_percentage_to_use)):
            position_x = rd.randrange(2, image.shape[0] - 2)
            position_y = rd.randrange(2, image.shape[1] - 2)
            image[position_x][position_y] = self.salt

        # Pixeles negros
        for x in range(int(self.noise_percentage_to_use)):
            position_x = rd.randrange(2, image.shape[0] - 2)
            position_y = rd.randrange(2, image.shape[1] - 2)
            image[position_x][position_y] = self.pepper

        return image

    def guassiano_noise(self, standard_deviation=1):
        """Ruido Gaussiano"""
        image = self._load_image()
        self.std_dev = standard_deviation
        dist_nor = np.random.normal(0, self.std_dev, size=image.shape[0:2])

        for i in range(dist_nor.shape[0]):
            for j in range(dist_nor.shape[1]):
                dist_nor[i][j] = int(round(((dist_nor[i][j]) * self.std_dev) + 127))

        dist_nor = np.array(dist_nor, dtype=np.uint8)

        for i in range(dist_nor.shape[0]):
            for j in range(dist_nor.shape[1]):
                for k in range(image.shape[2]):
                    if dist_nor[i][j] == 127:
                        continue
                    else:
                        image[i][j][k] = dist_nor[i][j]

        return image

    def periodic_noise(self, frequency=30, amplitude=50):
        """Ruido Periódico"""
        image = self._load_image()
        rows, cols = image.shape[:2]

        x = np.arange(cols)
        y = np.arange(rows)
        X, Y = np.meshgrid(x, y)

        pattern = amplitude * np.sin(2 * np.pi * frequency * (X + Y) / cols)

        if len(image.shape) == 3:
            pattern = np.repeat(pattern[:, :, np.newaxis], 3, axis=2)

        noisy_image = np.clip(image.astype(np.int16) + pattern.astype(np.int16), 0, 255).astype(np.uint8)
        return noisy_image

    def poisson_noise(self):
        """Ruido Poisson"""
        image = self._load_image()
        normalized = image / 255.0
        noisy = np.random.poisson(normalized * 255.0) / 255.0
        noisy_image = np.clip(noisy * 255, 0, 255).astype(np.uint8)
        return noisy_image

    def __del__(self):
        if hasattr(super(), '__del__'):
            super().__del__()
