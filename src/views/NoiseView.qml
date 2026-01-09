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
        function onErrorOccurred(message) {
            console.error("Error:", message)
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Panel izquierdo - Imagen Original
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
                        onDropped: (drop) => {
                            if (drop.hasUrls) {
                                noiseController.loadImage(drop.urls[0])
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

        // Panel de controles
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
                    model: noiseController.availableNoises
                    enabled: originalImagePath !== ""

                    onCurrentTextChanged: {
                        if (currentText !== "") {
                            noiseController.selectNoise(currentText)
                        }
                    }

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

                // Parámetros dinámicos
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            id: paramRepeater
                            model: {
                                if (!noiseController.currentNoiseParameters) return []
                                var params = noiseController.currentNoiseParameters
                                var paramList = []
                                for (var key in params) {
                                    paramList.push({
                                        name: key,
                                        info: params[key]
                                    })
                                }
                                return paramList
                            }

                            delegate: ColumnLayout {
                                readonly property string paramName: modelData.name
                                readonly property var paramInfo: modelData.info

                                Layout.fillWidth: true
                                spacing: 5

                                Label {
                                    text: paramName + (paramInfo.required ? " *" : "")
                                    font.bold: paramInfo.required
                                    font.pixelSize: 12
                                    color: "#000000"
                                }

                                Loader {
                                    Layout.fillWidth: true
                                    sourceComponent: {
                                        if (paramInfo.type === "bool") return boolComponent
                                        if (paramInfo.type === "int" || paramInfo.type === "float") return numberComponent
                                        return textComponent
                                    }

                                    onLoaded: {
                                        item.paramName = paramName
                                        item.paramInfo = paramInfo
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: "#E0E0E0"
                                }
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Selecciona un tipo de ruido para configurar parámetros"
                            font.italic: true
                            font.pixelSize: 12
                            visible: paramRepeater.count === 0
                            color: "#757575"
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: "⚡ Aplicar Ruido"
                    enabled: originalImagePath !== "" && noiseTypeCombo.currentText !== ""

                    background: Rectangle {
                        radius: 8
                        color: parent.enabled ? (parent.hovered ? "#00897B" : "#009688") : "#BDBDBD"
                        border.color: parent.enabled ? "#00695C" : "#9E9E9E"
                        border.width: 2
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
                        noiseController.applyNoise()
                    }
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
                        cache: false
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
    // Validadores
    IntValidator {
        id: intValidator
    }

    DoubleValidator {
        id: doubleValidator
        decimals: 6
        notation: DoubleValidator.StandardNotation
    }

    // Componentes de parámetros
    Component {
        id: textComponent

        TextField {
            property var paramInfo: ({})
            property string paramName: ""

            placeholderText: paramInfo.default !== null ? String(paramInfo.default) : "Ingrese valor"

            background: Rectangle {
                radius: 6
                color: "white"
                border.color: "#BDBDBD"
                border.width: 1
            }

            onTextChanged: noiseController.setParameterValue(paramName, text)
        }
    }

    Component {
        id: numberComponent

        RowLayout {
            property var paramInfo: ({})
            property string paramName: ""

            TextField {
                id: numberField
                Layout.fillWidth: true
                text: paramInfo.default !== null ? String(paramInfo.default) : "0"
                placeholderText: paramInfo.type === "float" ? "0.0" : "0"
                validator: paramInfo.type === "float" ? doubleValidator : intValidator

                background: Rectangle {
                    radius: 6
                    color: numberField.acceptableInput ? "white" : "#FFEBEE"
                    border.color: numberField.acceptableInput ? "#BDBDBD" : "#EF5350"
                    border.width: 1
                }

                onTextChanged: {
                    if (acceptableInput) {
                        var value = paramInfo.type === "float" ? parseFloat(text) : parseInt(text)
                        noiseController.setParameterValue(paramName, value)
                    }
                }
            }

            Label {
                text: paramInfo.type === "float" ? "⚠️ Decimal" : "🔢 Entero"
                font.pixelSize: 10
                color: "#757575"
            }
        }
    }

    Component {
        id: boolComponent

        CheckBox {
            property var paramInfo: ({})
            property string paramName: ""

            checked: paramInfo.default !== null ? paramInfo.default : false
            text: "Activar"

            contentItem: Label {
                text: parent.text
                color: "#000000"
                leftPadding: parent.indicator.width + parent.spacing
                verticalAlignment: Text.AlignVCenter
            }

            onCheckedChanged: noiseController.setParameterValue(paramName, checked)
        }
    }
}
