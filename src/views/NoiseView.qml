import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

GradientPage {
    pageTitle: "Generación de Ruido"
    accentColor: "#009688"

    property string originalImagePath: ""
    property string noisyImagePath: ""

    Connections {
        target: noiseController
        function onImageLoaded(path) {
            originalImagePath = path
        }
        function onNoiseApplied(path) {
            noisyImagePath = path
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Panel izquierdo - DropArea estilo ComparativeView
        Rectangle {
            Layout.preferredWidth: 350
            Layout.fillHeight: true
            radius: 10
            color: dropArea.containsDrag ? "#E3F2FD" : "#F5F5F5"
            border.color: dropArea.containsDrag ? "#2196F3" : "#BDBDBD"
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
                    Layout.preferredHeight: 250
                    color: "transparent"
                    border.color: "#BDBDBD"
                    border.width: 1
                    radius: 8

                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        source: originalImagePath
                        fillMode: Image.PreserveAspectFit
                        visible: originalImagePath !== ""
                    }

                    Label {
                        anchors.centerIn: parent
                        text: "📁\n\nArrastra una imagen\no haz clic"
                        horizontalAlignment: Text.AlignHCenter
                        color: "#757575"
                        font.pixelSize: 14
                        visible: originalImagePath === ""
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
                                noiseController.loadImage(drop.urls[0])
                                originalImagePath = drop.urls[0]
                            }
                        }
                    }
                }

                Button {
                    text: "🗂️ Seleccionar Imagen"
                    Layout.fillWidth: true
                    onClicked: fileDialog.open()

                    background: Rectangle {
                        radius: 6
                        color: parent.hovered ? "#1976D2" : "#2196F3"
                        border.color: "#1565C0"
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
                    visible: originalImagePath !== ""
                    onClicked: {
                        originalImagePath = ""
                        noisyImagePath = ""
                    }

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

        // Panel de controles de ruido
        Rectangle {
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            radius: 10
            color: "#FFFFFF"
            border.color: "#009688"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                Label {
                    text: "🔊 Configuración de Ruido"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Tipo de Ruido"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#000000"
                }

                ComboBox {
                    id: noiseTypeCombo
                    Layout.fillWidth: true
                    model: ["Gaussiano", "Sal y Pimienta", "Uniforme", "Poisson"]

                    background: Rectangle {
                        radius: 6
                        border.color: "#009688"
                        border.width: 1
                        color: parent.hovered ? "#E0F2F1" : "white"
                    }

                    contentItem: Label {
                        text: noiseTypeCombo.displayText
                        color: "#000000"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#BDBDBD"
                }

                Label {
                    text: "Intensidad: " + intensitySlider.value.toFixed(2)
                    font.bold: true
                    font.pixelSize: 14
                    color: "#000000"
                }

                Slider {
                    id: intensitySlider
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: 0.1
                    stepSize: 0.01

                    background: Rectangle {
                        x: intensitySlider.leftPadding
                        y: intensitySlider.topPadding + intensitySlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: intensitySlider.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: "#BDBDBD"

                        Rectangle {
                            width: intensitySlider.visualPosition * parent.width
                            height: parent.height
                            color: "#009688"
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: intensitySlider.leftPadding + intensitySlider.visualPosition * (intensitySlider.availableWidth - width)
                        y: intensitySlider.topPadding + intensitySlider.availableHeight / 2 - height / 2
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: intensitySlider.pressed ? "#00796B" : "#009688"
                        border.color: "#004D40"
                        border.width: 2
                    }
                }

                Label {
                    text: "Rango: 0.00 (sin ruido) - 1.00 (máximo)"
                    font.pixelSize: 11
                    color: "#757575"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Item { Layout.fillHeight: true }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: "⚡ Aplicar Ruido"
                    enabled: originalImagePath !== ""

                    background: Rectangle {
                        radius: 8
                        color: parent.enabled ? (parent.hovered ? "#00897B" : "#009688") : "#BDBDBD"
                        border.color: parent.enabled ? "#00695C" : "#9E9E9E"
                        border.width: 2

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    contentItem: Label {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        noiseController.addNoise(
                            noiseTypeCombo.currentText,
                            intensitySlider.value
                        )
                    }
                }

                Label {
                    text: "💡 El ruido se aplicará sobre la imagen original"
                    font.pixelSize: 10
                    color: "#757575"
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Panel de resultado
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: "#F5F5F5"
            border.color: "#FF5722"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Label {
                    text: "🎨 Imagen con Ruido"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#000000"
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#BDBDBD"
                    border.width: 1
                    radius: 8

                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        source: noisyImagePath
                        fillMode: Image.PreserveAspectFit
                        visible: noisyImagePath !== ""
                    }

                    Label {
                        anchors.centerIn: parent
                        text: "⚙️\n\nConfigura y aplica\nun tipo de ruido"
                        horizontalAlignment: Text.AlignHCenter
                        color: "#757575"
                        font.pixelSize: 14
                        visible: noisyImagePath === ""
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "💾 Guardar Resultado"
                    visible: noisyImagePath !== ""

                    background: Rectangle {
                        radius: 6
                        color: parent.hovered ? "#00897B" : "#009688"
                        border.color: "#00695C"
                        border.width: 1
                    }

                    contentItem: Label {
                        text: parent.text
                        color: "white"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: saveDialog.open()
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Seleccionar Imagen"
        nameFilters: ["Imágenes (*.png *.jpg *.jpeg *.bmp *.tiff)"]
        onAccepted: noiseController.loadImage(selectedFile)
    }

    FileDialog {
        id: saveDialog
        title: "Guardar Imagen con Ruido"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Imágenes PNG (*.png)", "Imágenes JPEG (*.jpg)"]
        defaultSuffix: "png"
        onAccepted: noiseController.saveImage(selectedFile)
    }
}