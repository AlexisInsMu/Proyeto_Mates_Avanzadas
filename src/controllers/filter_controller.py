from PySide6.QtCore import QObject, Signal, Slot, Property
from pathlib import Path
import cv2 as cv
import inspect
from logics.filters import filters


class FilterController(QObject):
    imageLoaded = Signal(str)
    filterApplied = Signal(str)  # Ahora emite la ruta de la imagen procesada
    filterListChanged = Signal()
    filterParametersChanged = Signal()
    errorOccurred = Signal(str)

    def __init__(self):
        super().__init__()
        self._filter_instance = None
        self._original_path = ""
        self._processed_path = ""
        self._available_filters = []
        self._current_filter_params = {}
        self._param_values = {}
        self._selected_filter = None

    @Slot(str)
    def loadImage(self, file_path):
        """Carga imagen desde path (soporta file:// URLs)"""
        path = file_path.replace("file://", "")
        try:
            self._filter_instance = filters(path)
            self._original_path = path
            self._available_filters = self._getFilterMethods()
            self.filterListChanged.emit()
            self.imageLoaded.emit(file_path)
        except Exception as e:
            self.errorOccurred.emit(f"Error al cargar imagen: {e}")

    @Slot(str)
    def selectFilter(self, filter_name):
        """Selecciona un filtro y obtiene sus parámetros"""
        if not self._filter_instance:
            return

        try:
            self._selected_filter = filter_name
            method = getattr(self._filter_instance, filter_name)
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

            self._current_filter_params = params
            self._param_values = {}
            self.filterParametersChanged.emit()

        except Exception as e:
            self.errorOccurred.emit(f"Error al seleccionar filtro: {e}")

    @Slot(str, float)
    def setParameterValue(self, param_name: str, value: float):
        """Establece el valor de un parámetro"""
        self._param_values[param_name] = value

    @Slot()
    def applyFilter(self):
        """Aplica el filtro seleccionado con los parámetros configurados"""
        if not self._original_path:
            self.errorOccurred.emit("No hay imagen cargada")
            return

        if not self._selected_filter:
            self.errorOccurred.emit("No hay filtro seleccionado")
            return

        try:
            # Convertir parámetros al tipo correcto
            converted_params = {}
            for param_name, param_value in self._param_values.items():
                if param_name in self._current_filter_params:
                    param_type = self._current_filter_params[param_name]['type']

                    if param_type == 'int':
                        value = int(float(param_value))

                        # Validación especial para ksize (debe ser impar y >= 1)
                        if param_name == 'ksize':
                            value = max(1, value)
                            if value % 2 == 0:
                                value += 1

                        converted_params[param_name] = value

                    elif param_type == 'float':
                        converted_params[param_name] = float(param_value)
                    elif param_type == 'bool':
                        converted_params[param_name] = bool(param_value)
                    else:
                        converted_params[param_name] = param_value

            # Aplicar filtro
            method = getattr(self._filter_instance, self._selected_filter)
            filtered_img = method(**converted_params)

            # Guardar resultado
            temp_dir = Path("/tmp/filter_results")
            temp_dir.mkdir(exist_ok=True)
            result_path = temp_dir / f"{self._selected_filter}_result.png"

            cv.imwrite(str(result_path), filtered_img)
            self._processed_path = str(result_path)

            # Emitir señal con la ruta
            self.filterApplied.emit(f"file://{result_path}")

        except Exception as e:
            self.errorOccurred.emit(f"Error al aplicar filtro: {e}")
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

    @Property(list, notify=filterListChanged)
    def availableFilters(self):
        return self._available_filters

    @Property(dict, notify=filterParametersChanged)
    def currentFilterParameters(self):
        return self._current_filter_params

    def _getFilterMethods(self):
        """Obtiene métodos públicos de la clase filters"""
        filter_methods = []

        for method_name in dir(self._filter_instance):
            if method_name.startswith('_') or not callable(getattr(self._filter_instance, method_name)):
                continue

            if 'detailed' in method_name.lower() or method_name.lower() == "compare_filters":
                continue

            try:
                method = getattr(self._filter_instance, method_name)
                sig = inspect.signature(method)

                if sig.return_annotation != inspect.Signature.empty:
                    if sig.return_annotation == tuple or 'tuple' in str(sig.return_annotation).lower():
                        continue

                filter_methods.append(method_name)

            except Exception:
                continue

        return sorted(filter_methods)
