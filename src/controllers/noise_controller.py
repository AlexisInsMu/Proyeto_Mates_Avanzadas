from PySide6.QtCore import QObject, Signal, Slot, Property
from pathlib import Path
import cv2 as cv
import inspect
from logics.noise import GenerateNoise


class NoiseController(QObject):
    imageLoaded = Signal(str)
    noiseApplied = Signal(str)  # Emite la ruta de la imagen procesada
    noiseListChanged = Signal()
    noiseParametersChanged = Signal()
    errorOccurred = Signal(str)

    def __init__(self):
        super().__init__()
        self._noise_instance = None
        self._original_path = ""
        self._processed_path = ""
        self._available_noises = []
        self._current_noise_params = {}
        self._param_values = {}
        self._selected_noise = None

    @Slot(str)
    def loadImage(self, file_path):
        """Carga imagen desde path (soporta file:// URLs)"""
        path = file_path.replace("file://", "")
        try:
            self._noise_instance = GenerateNoise(path)
            self._original_path = path
            self._available_noises = self._getNoiseMethods()
            self.noiseListChanged.emit()
            self.imageLoaded.emit(file_path)
        except Exception as e:
            self.errorOccurred.emit(f"Error al cargar imagen: {e}")

    @Slot(str)
    def selectNoise(self, noise_name):
        """Selecciona un tipo de ruido y obtiene sus parámetros"""
        if not self._noise_instance:
            return

        try:
            self._selected_noise = noise_name
            method = getattr(self._noise_instance, noise_name)
            sig = inspect.signature(method)

            params = {}
            for param_name, param in sig.parameters.items():
                if param_name == 'self':
                    continue

                param_info = {
                    'name': param_name,
                    'type': 'float',
                    'default': None,
                    'required': param.default == inspect.Parameter.empty
                }

                if param.annotation != inspect.Parameter.empty:
                    if param.annotation == int:
                        param_info['type'] = 'int'
                    elif param.annotation == float:
                        param_info['type'] = 'float'
                    elif param.annotation == bool:
                        param_info['type'] = 'bool'
                    elif param.annotation == str:
                        param_info['type'] = 'string'

                if param.default != inspect.Parameter.empty:
                    param_info['default'] = param.default

                params[param_name] = param_info

            self._current_noise_params = params
            self._param_values = {}
            self.noiseParametersChanged.emit()

        except Exception as e:
            self.errorOccurred.emit(f"Error al seleccionar ruido: {e}")

    @Slot(str, float)
    def setParameterValue(self, param_name: str, value: float):
        """Establece el valor de un parámetro"""
        self._param_values[param_name] = value

    @Slot()
    def applyNoise(self):
        """Aplica el ruido seleccionado con los parámetros configurados"""
        if not self._original_path:
            self.errorOccurred.emit("No hay imagen cargada")
            return

        if not self._selected_noise:
            self.errorOccurred.emit("No hay ruido seleccionado")
            return

        try:
            # Convertir parámetros al tipo correcto
            converted_params = {}
            for param_name, param_value in self._param_values.items():
                if param_name in self._current_noise_params:
                    param_type = self._current_noise_params[param_name]['type']

                    if param_type == 'int':
                        converted_params[param_name] = int(float(param_value))
                    elif param_type == 'float':
                        converted_params[param_name] = float(param_value)
                    elif param_type == 'bool':
                        converted_params[param_name] = bool(param_value)
                    else:
                        converted_params[param_name] = param_value

            # Aplicar ruido
            method = getattr(self._noise_instance, self._selected_noise)
            noisy_img = method(**converted_params)

            # Guardar resultado
            temp_dir = Path("/tmp/noise_results")
            temp_dir.mkdir(exist_ok=True)
            result_path = temp_dir / f"{self._selected_noise}_result.png"

            cv.imwrite(str(result_path), noisy_img)
            self._processed_path = str(result_path)

            # Emitir señal con la ruta
            self.noiseApplied.emit(f"file://{result_path}")

        except Exception as e:
            self.errorOccurred.emit(f"Error al aplicar ruido: {e}")
            import traceback
            traceback.print_exc()

    @Slot(str)
    def saveImage(self, save_path: str):
        """Guarda imagen procesada"""
        if not self._processed_path:
            self.errorOccurred.emit("No hay imagen procesada para guardar")
            return

        try:
            save_path = save_path.replace("file://", "")
            img = cv.imread(self._processed_path)
            cv.imwrite(save_path, img)
        except Exception as e:
            self.errorOccurred.emit(f"Error al guardar imagen: {e}")

    @Property(list, notify=noiseListChanged)
    def availableNoises(self):
        return self._available_noises

    @Property(dict, notify=noiseParametersChanged)
    def currentNoiseParameters(self):
        return self._current_noise_params

    def _getNoiseMethods(self):
        """Obtiene métodos públicos de la clase GenerateNoise"""
        noise_methods = []

        for method_name in dir(self._noise_instance):
            if method_name.startswith('_') or not callable(getattr(self._noise_instance, method_name)):
                continue

            try:
                method = getattr(self._noise_instance, method_name)
                sig = inspect.signature(method)

                # Excluir métodos que retornan tuplas o tienen 'detailed' en el nombre
                if sig.return_annotation != inspect.Signature.empty:
                    if sig.return_annotation == tuple or 'tuple' in str(sig.return_annotation).lower():
                        continue

                noise_methods.append(method_name)

            except Exception:
                continue

        return sorted(noise_methods)