import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

GradientPage {
    pageTitle: "Comparación de Imágenes"
    accentColor: "#FF5722"

    property string img1Path: ""
    property string img2Path: ""
    property string diffPath: ""
    property string hist1Path: ""
    property string hist2Path: ""

    Connections {
        target: comparativeController
        function onImage1Loaded(path) {
            img1Path = path
        }
        function onImage2Loaded(path) {
            img2Path = path
        }
        function onDiffImageReady(path) {
            diffPath = path
        }
        function onHistogram1Ready(path) {
            hist1Path = path
        }
        function onHistogram2Ready(path) {
            hist2Path = path
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 20

            // Carga de imágenes
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 20

                // Imagen 1
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    radius: 10
                    color: dropArea1.containsDrag ? "#E3F2FD" : "#F5F5F5"
                    border.color: dropArea1.containsDrag ? "#2196F3" : "#BDBDBD"
                    border.width: 2

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Label {
                            text: "📷 Imagen 1"
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
                                source: img1Path
                                fillMode: Image.PreserveAspectFit
                                visible: img1Path !== ""
                            }

                            Label {
                                anchors.centerIn: parent
                                text: "📁\n\nArrastra una imagen\no haz clic"
                                horizontalAlignment: Text.AlignHCenter
                                color: "#757575"
                                font.pixelSize: 14
                                visible: img1Path === ""
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: fileDialog1.open()
                                cursorShape: Qt.PointingHandCursor
                            }

                            DropArea {
                                id: dropArea1
                                anchors.fill: parent
                                onDropped: (drop) => {
                                    if (drop.hasUrls) {
                                        comparativeController.loadImage1(drop.urls[0])
                                    }
                                }
                            }
                        }

                        Button {
                            text: "🗂️ Seleccionar"
                            Layout.fillWidth: true
                            onClicked: fileDialog1.open()

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
                            visible: img1Path !== ""
                            onClicked: img1Path = ""

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

                // Imagen 2 (mismo diseño)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    radius: 10
                    color: dropArea2.containsDrag ? "#E3F2FD" : "#F5F5F5"
                    border.color: dropArea2.containsDrag ? "#2196F3" : "#BDBDBD"
                    border.width: 2

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Label {
                            text: "📷 Imagen 2"
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
                                source: img2Path
                                fillMode: Image.PreserveAspectFit
                                visible: img2Path !== ""
                            }

                            Label {
                                anchors.centerIn: parent
                                text: "📁\n\nArrastra una imagen\no haz clic"
                                horizontalAlignment: Text.AlignHCenter
                                color: "#757575"
                                font.pixelSize: 14
                                visible: img2Path === ""
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: fileDialog2.open()
                                cursorShape: Qt.PointingHandCursor
                            }

                            DropArea {
                                id: dropArea2
                                anchors.fill: parent
                                onDropped: (drop) => {
                                    if (drop.hasUrls) {
                                        comparativeController.loadImage2(drop.urls[0])
                                    }
                                }
                            }
                        }

                        Button {
                            text: "🗂️ Seleccionar"
                            Layout.fillWidth: true
                            onClicked: fileDialog2.open()

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
                            visible: img2Path !== ""
                            onClicked: img2Path = ""

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
            }

            // Métricas
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: metricsLayout.implicitHeight + 40
                radius: 10
                color: "#FFFFFF"
                border.color: "#FF5722"
                border.width: 2

                ColumnLayout {
                    id: metricsLayout
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Label {
                        text: "📊 Métricas de Comparación"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#000000"
                    }

                    GridLayout {
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 30
                        Layout.fillWidth: true

                        Label { text: "MSE:"; font.bold: true; color: "#000000" }
                        Label { text: comparativeController.mse.toString(); color: "#000000" }

                        Label { text: "PSNR:"; font.bold: true; color: "#000000" }
                        Label {
                            text: comparativeController.psnr
                            color: comparativeController.psnr.includes("∞") ? "#4CAF50" : "#000000"
                        }

                        Label { text: "MAE:"; font.bold: true; color: "#000000" }
                        Label { text: comparativeController.mae.toString(); color: "#000000" }

                        Label { text: "SSIM:"; font.bold: true; color: "#000000" }
                        Label {
                            text: comparativeController.ssim
                            color: parseFloat(comparativeController.ssim) > 0.95 ? "#4CAF50" : "#000000"
                        }

                        Label { text: "Correlación:"; font.bold: true; color: "#000000" }
                        Label { text: comparativeController.correlation; color: "#000000" }

                        Label { text: "Diferencia de Color:"; font.bold: true; color: "#000000" }
                        Label { text: comparativeController.colorDiff.toString(); color: "#000000" }

                        Label { text: "Resolución 1:"; font.bold: true; color: "#000000" }
                        Label { text: comparativeController.resolution1; color: "#000000" }

                        Label { text: "Resolución 2:"; font.bold: true; color: "#000000" }
                        Label { text: comparativeController.resolution2; color: "#000000" }

                        Label { text: "Estado:"; font.bold: true; color: "#000000" }
                        Label {
                            text: comparativeController.sizeMatch
                            color: comparativeController.sizeMatch.includes("idénticos") ? "#4CAF50" : "#FF9800"
                        }
                    }
                }
            }

            // Mapa de diferencias
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: 350
                radius: 10
                color: "#F5F5F5"
                border.color: "#FF5722"
                border.width: 2
                visible: diffPath !== ""

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    Label {
                        text: "🔥 Mapa de Diferencias (Heatmap)"
                        font.bold: true
                        font.pixelSize: 16
                        color: "#000000"
                    }

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: diffPath
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }

            // Histogramas
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 20
                visible: hist1Path !== "" || hist2Path !== ""

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    radius: 10
                    color: "#F5F5F5"
                    border.color: "#2196F3"
                    border.width: 2
                    visible: hist1Path !== ""

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Label {
                            text: "📈 Histograma Imagen 1"
                            font.bold: true
                            color: "#000000"
                        }

                        Image {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            source: hist1Path
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    radius: 10
                    color: "#F5F5F5"
                    border.color: "#673AB7"
                    border.width: 2
                    visible: hist2Path !== ""

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Label {
                            text: "📈 Histograma Imagen 2"
                            font.bold: true
                            color: "#000000"
                        }

                        Image {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            source: hist2Path
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }
            }

            // Botón reset
            Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 20
                text: "🔄 Reiniciar Comparación"

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

                onClicked: {
                    comparativeController.reset()
                    img1Path = ""
                    img2Path = ""
                    diffPath = ""
                    hist1Path = ""
                    hist2Path = ""
                }
            }
        }
    }

    FileDialog {
        id: fileDialog1
        title: "Seleccionar Imagen 1"
        nameFilters: ["Imágenes (*.png *.jpg *.jpeg *.bmp *.tiff)"]
        onAccepted: comparativeController.loadImage1(selectedFile)
    }

    FileDialog {
        id: fileDialog2
        title: "Seleccionar Imagen 2"
        nameFilters: ["Imágenes (*.png *.jpg *.jpeg *.bmp *.tiff)"]
        onAccepted: comparativeController.loadImage2(selectedFile)
    }
}
