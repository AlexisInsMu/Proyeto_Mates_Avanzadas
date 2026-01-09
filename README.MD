# 📷 Filtros FFT - Sistema de Procesamiento de Imágenes

![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python&logoColor=white)
![Qt](https://img.shields.io/badge/Qt-6.0+-green?logo=qt&logoColor=white)
![OpenCV](https://img.shields.io/badge/OpenCV-4.8+-red?logo=opencv&logoColor=white)
![License](https://img.shields.io/badge/License-LGPLv3-blue)

Sistema avanzado de procesamiento de imágenes con filtros en el dominio de Fourier, análisis comparativo y gestión de ruido. Desarrollado con **PySide6** (Qt for Python) y **OpenCV**.

---

## ✨ Características Principales

- 🔄 **Filtros de Fourier**: Lowpass (suavizado) y Highpass (realce de bordes) con ajuste dinámico de radio
- 📊 **Métricas de Calidad**: MSE, PSNR, SSIM, MAE, Correlación de Pearson
- 🎨 **Visualizaciones Interactivas**:
  - Espectros de Fourier (original y filtrado)
  - Máscaras de filtrado en tiempo real
  - Mapas de diferencias (heatmaps) con escala de color
  - Histogramas RGB de distribución de píxeles
- 🔊 **Gestión de Ruido**: Agregar y analizar ruido Gaussiano, Salt & Pepper, Poisson
- ⚖️ **Comparación de Imágenes**: Análisis lado a lado con 8+ métricas
- 🎯 **Interfaz Moderna**: UI con gradientes, drag & drop, animaciones suaves
- 🚀 **Alto Rendimiento**: Procesamiento optimizado con NumPy y FFT

---

## 📋 Requisitos del Sistema

### Sistema Operativo
- **Linux** (Ubuntu 20.04+, Fedora 35+, Arch Linux) ✅ **Recomendado**
- macOS 11+ (parcialmente soportado)
- Windows 10/11 (requiere configuración adicional)

### Software Base
- **Python**: 3.10 o superior
- **pip**: 21.0 o superior
- **Git**: Para clonar el repositorio

### Dependencias del Sistema (Linux)

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install -y \
    python3-dev \
    python3-pip \
    libgl1-mesa-dev \
    libglib2.0-0 \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    libxkbcommon-x11-0 \
    libdbus-1-3 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0

```
#### Como ejecutar en Linux
```bash

git clone
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
python main.py
```


### Requisitos para Windows
- Instalar Python 3.10+ desde [python.org](https://www.python.org/downloads/windows/)
- Instalar Git desde [git-scm.com](https://git-scm.com/download/win)
- Configurar variables de entorno para Python y Git
- Instalar Visual C++ Build Tools desde [visualstudio.microsoft.com](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
- Instalar gcc y make usando [MSYS2](https://www.msys2.org/) o [MinGW-w64](http://mingw-w64.org/doku.php)


### Como configurar en Windows
3. Abrir PowerShell y ejecutar:
```powershell
git clone
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
python main.py
```



### Referencias
Gonzalez, R. C., & Woods, R. E. (2018). Digital image processing (4.ª ed.). Pearson. 

Harris, C. R., Millman, K. J., van der Walt, S. J., Gommers, R., Virtanen, P., Cournapeau, D., ... & Oliphant, T. E. (2020). Array programming with NumPy. Nature, 585(7825), 357–362. https://doi.org/10.1038/s41586-020-2649-2 

Bradski, G. (2000). The OpenCV Library. Dr. Dobb's Journal of Software Tools, 25(11), 120–125.


### GIthub referenciados


1. **Trabajo de referencia**, (2023), *Programa Delfin 2023* [Software]. Github  
   [LINK Github](https://github.com/AlexisInsMu/Delfin-programa-2023)

 

 


### autores : 
Jiménez Rodríguez Alejandro Martin
Mendoza Mendoza Alexsandra
Murillo Barrientos Alexis Adrian
Suárez Elizalde Miguel Angel






