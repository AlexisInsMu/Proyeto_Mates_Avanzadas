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



### Como configurar en Windows
1. Instalar Python 3.10+ desde [python.org](https://www.python.org/downloads/windows/)
2. Instalar Git desde [git-scm.com](https://git-scm.com/download/win)
3. Abrir PowerShell y ejecutar:
```powershell
git clone
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
python main.py
```






