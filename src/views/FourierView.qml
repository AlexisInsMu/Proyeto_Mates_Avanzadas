import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

GradientPage {
    pageTitle: "Análisis de Fourier"
    accentColor: "#9C27B0"

    property string originalPath: ""
    property string spectrumOriginalPath: ""
    property string spectrumFilteredPath: ""
    property string maskPath: ""
    property string filteredPath: ""

    Connections {
        target: fourierController

        function onImageLoaded(path) {
            originalPath = path
        }

        function onAnalysisReady() {
            var viz = fourierController.currentVisualizations;
            var analysis = fourierController.currentAnalysis;

            spectrumOriginalPath = viz.spectrum_original_path;
            spectrumFilteredPath = viz.spectrum_filtered_path;
            maskPath = viz.mask_path;
            filteredPath = viz.filtered_image_path;

            // Convertir strings a números
            var mse = parseFloat(analysis.mse);
            var psnr = parseFloat(analysis.psnr);
            var ssim = parseFloat(analysis.ssim);

            // Actualizar labels
            mseLabel.text = isNaN(mse) ? "-" : mse.toFixed(2);
            psnrLabel.text = isNaN(psnr) ? "-" : psnr.toFixed(2) + " dB";
            ssimLabel.text = isNaN(ssim) ? "-" : ssim.toFixed(4);

            // Calcular y actualizar similitud
            var sim = isNaN(ssim) ? 0 : ssim * 100;
            similarityLabel.text = sim.toFixed(1) + "%";

            // Actualizar color basado en el valor
            if (sim > 70) {
                similarityLabel.color = "#4CAF50"; // Verde
            } else if (sim > 40) {
                similarityLabel.color = "#FF9800"; // Naranja
            } else {
                similarityLabel.color = "#F44336"; // Rojo
            }

            // Forzar actualización de la vista
            mseLabel.update();
            psnrLabel.update();
            ssimLabel.update();
            similarityLabel.update();
        }

        function onErrorOccurred(message) {
            errorDialog.text = message;
            errorDialog.open();
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 20

            // Carga de imagen con drag & drop
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: 280
                radius: 10
                color: dropArea.containsDrag ? "#E3F2FD" : "#F5F5F5"
                border.color: dropArea.containsDrag ? "#9C27B0" : "#BDBDBD"
                border.width: 2

                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Label {
                        text: "📷 Imagen Original"
                        font.bold: true
                        font.pixelSize: 16
                        color: "#000000"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        border.color: "#BDBDBD"
                        border.width: 1
                        radius: 8

                        Image {
                            anchors.fill: parent
                            anchors.margins: 5
                            source: originalPath
                            fillMode: Image.PreserveAspectFit
                            visible: originalPath !== ""
                        }

                        Label {
                            anchors.centerIn: parent
                            text: "📁\n\nArrastra una imagen\no haz clic"
                            horizontalAlignment: Text.AlignHCenter
                            color: "#757575"
                            font.pixelSize: 14
                            visible: originalPath === ""
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: fileDialog.open()
                            cursorShape: Qt.PointingHandCursor
                        }

                        DropArea {
                            id: dropArea
                            anchors.fill: parent
                            onDropped: function(drop) {
                                if (drop.hasUrls) {
                                    fourierController.loadImage(drop.urls[0]);
                                }
                            }
                        }
                    }

                    Button {
                        text: "🗂️ Seleccionar"
                        Layout.fillWidth: true
                        onClicked: fileDialog.open()

                        background: Rectangle {
                            radius: 6
                            color: parent.hovered ? "#7B1FA2" : "#9C27B0"
                            border.color: "#6A1B9A"
                            border.width: 1
                        }

                        contentItem: Label {
                            text: parent.text
                            color: "white"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "🗑️ Limpiar"
                        Layout.fillWidth: true
                        visible: originalPath !== ""
                        onClicked: originalPath = ""

                        background: Rectangle {
                            radius: 6
                            color: parent.hovered ? "#C62828" : "#E53935"
                            border.color: "#B71C1C"
                            border.width: 1
                        }

                        contentItem: Label {
                            text: parent.text
                            color: "white"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Controles de filtro
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: controlsLayout.implicitHeight + 40
                radius: 10
                color: "#FFFFFF"
                border.color: "#9C27B0"
                border.width: 2

                ColumnLayout {
                    id: controlsLayout
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Label {
                        text: "⚙️ Controles de Filtro"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#000000"
                    }

                    RowLayout {
                        spacing: 10

                        Label {
                            text: "Tipo de filtro:"
                            font.bold: true
                            color: "#000000"
                        }

                        RadioButton {
                            id: lowpassRadio
                            text: "Pasa Bajas"
                            checked: true

                            contentItem: Label {
                                text: parent.text
                                color: "#000000"
                                leftPadding: parent.indicator.width + parent.spacing
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        RadioButton {
                            id: highpassRadio
                            text: "Pasa Altas"

                            contentItem: Label {
                                text: parent.text
                                color: "#000000"
                                leftPadding: parent.indicator.width + parent.spacing
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    RowLayout {
                        spacing: 10

                        Label {
                            text: "Radio de corte:"
                            font.bold: true
                            Layout.preferredWidth: 120
                            color: "#000000"
                        }

                        Slider {
                            id: radioSlider
                            Layout.fillWidth: true
                            from: 0.01
                            to: 0.5
                            value: 0.1
                            stepSize: 0.01
                        }

                        Label {
                            text: radioSlider.value.toFixed(2)
                            font.bold: true
                            Layout.preferredWidth: 50
                            color: "#000000"
                        }
                    }

                    RowLayout {
                        spacing: 10

                        Button {
                            text: "✨ Aplicar Filtro"
                            Layout.fillWidth: true
                            enabled: originalPath !== ""
                            onClicked: {
                                var filterType = lowpassRadio.checked ? "lowpass" : "highpass";
                                fourierController.applyFourierFilter(filterType, radioSlider.value);
                            }

                            background: Rectangle {
                                radius: 6
                                color: parent.enabled ? (parent.hovered ? "#7B1FA2" : "#9C27B0") : "#BDBDBD"
                                border.color: parent.enabled ? "#6A1B9A" : "#9E9E9E"
                                border.width: 1
                            }

                            contentItem: Label {
                                text: parent.text
                                color: "white"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: "📊 Comparar Filtros"
                            Layout.fillWidth: true
                            enabled: originalPath !== ""
                            onClicked: {
                                var comparison = fourierController.compareFilters(radioSlider.value);
                                comparisonDialog.showComparison(comparison);
                            }

                            background: Rectangle {
                                radius: 6
                                color: parent.enabled ? (parent.hovered ? "#1976D2" : "#2196F3") : "#BDBDBD"
                                border.color: parent.enabled ? "#1565C0" : "#9E9E9E"
                                border.width: 1
                            }

                            contentItem: Label {
                                text: parent.text
                                color: "white"
                                font: parent.font
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            // Visualizaciones en grid 2x2
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: 700
                radius: 10
                color: "#FFFFFF"
                border.color: "#9C27B0"
                border.width: 2

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Label {
                        text: "🔬 Visualizaciones"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#000000"
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 2
                        rowSpacing: 15
                        columnSpacing: 15

                        // Espectro Original
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Label {
                                text: "📈 Espectro Original"
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                                color: "#000000"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#F5F5F5"
                                border.color: "#BDBDBD"
                                border.width: 1
                                radius: 8

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: spectrumOriginalPath
                                    fillMode: Image.PreserveAspectFit
                                    cache: false
                                }
                            }
                        }

                        // Máscara
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Label {
                                text: "🎭 Máscara de Filtrado"
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                                color: "#000000"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#F5F5F5"
                                border.color: "#BDBDBD"
                                border.width: 1
                                radius: 8

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: maskPath
                                    fillMode: Image.PreserveAspectFit
                                    cache: false
                                }
                            }
                        }

                        // Espectro Filtrado
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Label {
                                text: "📉 Espectro Filtrado"
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                                color: "#000000"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#F5F5F5"
                                border.color: "#BDBDBD"
                                border.width: 1
                                radius: 8

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: spectrumFilteredPath
                                    fillMode: Image.PreserveAspectFit
                                    cache: false
                                }
                            }
                        }

                        // Imagen Filtrada
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Label {
                                text: "🖼️ Imagen Filtrada"
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                                color: "#000000"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#F5F5F5"
                                border.color: "#BDBDBD"
                                border.width: 1
                                radius: 8

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: filteredPath
                                    fillMode: Image.PreserveAspectFit
                                    cache: false
                                }
                            }
                        }
                    }
                }
            }

            // Métricas
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: 180
                radius: 10
                color: "#FFFFFF"
                border.color: "#9C27B0"
                border.width: 2

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Label {
                        text: "📊 Métricas de Calidad"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#000000"
                    }

                    GridLayout {
                        id: metricsGrid
                        columns: 2
                        rowSpacing: 12
                        columnSpacing: 40
                        Layout.fillWidth: true

                        Label {
                            text: "MSE:"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#000000"
                        }
                        Label {
                            id: mseLabel
                            text: "-"
                            font.family: "Monospace"
                            font.pixelSize: 14
                            color: "#000000"
                        }

                        Label {
                            text: "PSNR:"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#000000"
                        }
                        Label {
                            id: psnrLabel
                            text: "-"
                            font.family: "Monospace"
                            font.pixelSize: 14
                            color: "#000000"
                        }

                        Label {
                            text: "SSIM:"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#000000"
                        }
                        Label {
                            id: ssimLabel
                            text: "-"
                            font.family: "Monospace"
                            font.pixelSize: 14
                            color: "#000000"
                        }

                        Label {
                            text: "Similitud:"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#000000"
                        }
                        Label {
                            id: similarityLabel
                            text: "-"
                            font.family: "Monospace"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                }
            }
        }
    }

    // Diálogo de comparación
    Dialog {
        id: comparisonDialog
        title: "Comparación de Filtros"
        width: Math.min(parent.width * 0.9, 1200)
        height: Math.min(parent.height * 0.9, 800)
        modal: true
        anchors.centerIn: parent

        function showComparison(data) {
            if (!data || Object.keys(data).length === 0) return;

            lowpassImg.source = data.lowpass_path;
            highpassImg.source = data.highpass_path;

            var lowMse = parseFloat(data.lowpass_mse);
            var highMse = parseFloat(data.highpass_mse);
            var lowPsnr = parseFloat(data.lowpass_psnr);
            var highPsnr = parseFloat(data.highpass_psnr);
            var lowSharp = parseFloat(data.lowpass_sharpness);
            var highSharp = parseFloat(data.highpass_sharpness);

            lowMseVal.text = isNaN(lowMse) ? "-" : lowMse.toFixed(2);
            highMseVal.text = isNaN(highMse) ? "-" : highMse.toFixed(2);
            lowPsnrVal.text = isNaN(lowPsnr) ? "-" : lowPsnr.toFixed(2) + " dB";
            highPsnrVal.text = isNaN(highPsnr) ? "-" : highPsnr.toFixed(2) + " dB";
            lowSharpVal.text = isNaN(lowSharp) ? "-" : lowSharp.toFixed(2);
            highSharpVal.text = isNaN(highSharp) ? "-" : highSharp.toFixed(2);

            var mse_sim = 100 / (1 + Math.abs(lowMse - highMse) / Math.max(lowMse, highMse));
            var psnr_sim = 100 / (1 + Math.abs(lowPsnr - highPsnr) / Math.max(lowPsnr, highPsnr));
            var sharp_sim = 100 / (1 + Math.abs(lowSharp - highSharp) / Math.max(lowSharp, highSharp));
            var overall_sim = (mse_sim + psnr_sim + sharp_sim) / 3;

            similarityVal.text = overall_sim.toFixed(1) + "%";
            similarityVal.color = overall_sim > 70 ? "#4CAF50" : overall_sim > 40 ? "#FF9800" : "#F44336";

            open();
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 15

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        text: "Filtro Pasa Bajas"
                        font.bold: true
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignHCenter
                        color: "#000000"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "lightgray"
                        border.color: "#2196F3"
                        border.width: 2

                        Image {
                            id: lowpassImg
                            anchors.fill: parent
                            anchors.margins: 5
                            fillMode: Image.PreserveAspectFit
                            cache: false
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        text: "Filtro Pasa Altas"
                        font.bold: true
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignHCenter
                        color: "#000000"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "lightgray"
                        border.color: "#F44336"
                        border.width: 2

                        Image {
                            id: highpassImg
                            anchors.fill: parent
                            anchors.margins: 5
                            fillMode: Image.PreserveAspectFit
                            cache: false
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                border.color: "gray"
                color: "#F5F5F5"

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    columns: 3
                    rowSpacing: 8
                    columnSpacing: 10

                    Label { text: "Métrica"; font.bold: true; font.pixelSize: 14; color: "#000000" }
                    Label { text: "Pasa Bajas"; font.bold: true; font.pixelSize: 14; color: "#2196F3" }
                    Label { text: "Pasa Altas"; font.bold: true; font.pixelSize: 14; color: "#F44336" }

                    Label { text: "MSE"; font.bold: true; color: "#000000" }
                    Label { id: lowMseVal; text: "-"; font.family: "Monospace"; color: "#000000" }
                    Label { id: highMseVal; text: "-"; font.family: "Monospace"; color: "#000000" }

                    Label { text: "PSNR"; font.bold: true; color: "#000000" }
                    Label { id: lowPsnrVal; text: "-"; font.family: "Monospace"; color: "#000000" }
                    Label { id: highPsnrVal; text: "-"; font.family: "Monospace"; color: "#000000" }

                    Label { text: "Nitidez"; font.bold: true; color: "#000000" }
                    Label { id: lowSharpVal; text: "-"; font.family: "Monospace"; color: "#000000" }
                    Label { id: highSharpVal; text: "-"; font.family: "Monospace"; color: "#000000" }

                    Label { text: "Similitud Global"; font.bold: true; font.pixelSize: 14; color: "#000000" }
                    Label {
                        id: similarityVal
                        text: "-"
                        font.bold: true
                        font.pixelSize: 16
                        Layout.columnSpan: 2
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Button {
                text: "Cerrar"
                Layout.alignment: Qt.AlignHCenter
                onClicked: comparisonDialog.close()

                background: Rectangle {
                    radius: 6
                    color: parent.hovered ? "#5D4037" : "#795548"
                    border.color: "#4E342E"
                    border.width: 1
                }

                contentItem: Label {
                    text: parent.text
                    color: "white"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Dialog {
        id: errorDialog
        property alias text: errorLabel.text
        title: "Error"
        standardButtons: Dialog.Ok

        Label {
            id: errorLabel
            color: "#000000"
        }
    }

    FileDialog {
        id: fileDialog
        fileMode: FileDialog.OpenFile
        nameFilters: ["Imágenes (*.png *.jpg *.jpeg *.bmp)"]
        onAccepted: fourierController.loadImage(selectedFile)
    }
}