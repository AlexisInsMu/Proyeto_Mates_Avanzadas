import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from controllers.filter_controller import FilterController
from controllers.fourier_controller import FourierController
from controllers.noise_controller import NoiseController
from controllers.comparative_controller import ComparativeController


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Registrar todos los controladores
    filter_controller = FilterController()
    fourier_controller = FourierController()
    noise_controller = NoiseController()
    comparative_controller = ComparativeController()

    engine.rootContext().setContextProperty("filterController", filter_controller)
    engine.rootContext().setContextProperty("fourierController", fourier_controller)
    engine.rootContext().setContextProperty("noiseController", noise_controller)
    engine.rootContext().setContextProperty("comparativeController", comparative_controller)

    qml_file = Path(__file__).resolve().parent / "views/main.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
