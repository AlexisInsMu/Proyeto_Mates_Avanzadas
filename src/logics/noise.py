import cv2 as cv
import numpy as np
import random as rd


# Clase que genera diferentes tipos de ruidos
class GenerateNoise:
    img_path: str = None

    def __init__(self, image_path: str):
        if (image_path is None):
            raise ValueError("Dime la dirección de la imagen")
            __del__()
        self.img_path = image_path

        print("Todo salio bien")

    # Método que genera a una imagen un ruido de sal y pimienta por medio de un porcentaje
    def impulsive_noise(self, noise_percentage=0):
        if (noise_percentage <= 0 or noise_percentage > 100):
            print("Por si todo sale mal")
            return

        image = cv.imread(self.img_path)
        self.size_img = image.shape[0] * image.shape[1]
        self.noise_percentage_to_use = (noise_percentage * self.size_img) / 200

        if image.shape[2] > 1:
            self.pepper = [0, 0, 0]
            self.salt = [255, 255, 255]
        elif image.shape[2] == 1:
            self.pepper = 0
            self.salt = 255

        # pixeles blancos
        for x in range(int(self.noise_percentage_to_use)):
            position_x = rd.randrange(2, image.shape[0] - 2)
            position_y = rd.randrange(2, image.shape[1] - 2)

            image[position_x][position_y] = self.salt

        # pixeles negros
        for x in range(int(self.noise_percentage_to_use)):
            position_x = rd.randrange(2, image.shape[0] - 2)
            position_y = rd.randrange(2, image.shape[1] - 2)

            image[position_x][position_y] = self.pepper

        # Retorna la imagen contaminada
        return image

    def guassiano_noise(self, standard_deviation=1):
        """ Método que genera a una imagen un ruido Guassiano por medio de indicar la desviación estándar
            starndard_deviation: desviación estándar del ruido
            Retorna la imagen con ruido Guassiano aplicado
        """
        image = cv.imread(self.img_path)
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
        """Ruido Periódico: patrones de interferencia
        donde frequency es la frecuencia del patrón
        y amplitude la intensidad del ruido
        """
        image = cv.imread(self.img_path)
        rows, cols = image.shape[:2]

        # Crear patrón sinusoidal
        x = np.arange(cols)
        y = np.arange(rows)
        X, Y = np.meshgrid(x, y)

        # Patrón diagonal
        pattern = amplitude * np.sin(2 * np.pi * frequency * (X + Y) / cols)

        # Expandir a 3 canales si es color
        if len(image.shape) == 3:
            pattern = np.repeat(pattern[:, :, np.newaxis], 3, axis=2)

        noisy_image = np.clip(image.astype(np.int16) + pattern.astype(np.int16), 0, 255).astype(np.uint8)
        return noisy_image

    def poisson_noise(self):
        """Ruido Poisson: dependiente de la señal (shot noise)
        NO recibe parámetros
        Retorna la imagen con ruido Poisson aplicado
        """


        image = cv.imread(self.img_path)
        # Normalizar a [0,1], aplicar Poisson, escalar de vuelta
        normalized = image / 255.0
        noisy = np.random.poisson(normalized * 255.0) / 255.0
        noisy_image = np.clip(noisy * 255, 0, 255).astype(np.uint8)
        return noisy_image

    def __del__(self):
        super().__del__()
        print("Objeto destruido")