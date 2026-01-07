import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

GradientPage {
    pageTitle: "Filtros Espaciales"
    accentColor: "#2196F3"

    property string originalImagePath: ""
    property string processedImagePath: ""

    Connections {
        target: filterController

        function onImageLoaded(path) {
            originalImagePath = path
        }

        function onFilterApplied(path) {
            processedImagePath = ""
            processedImagePath = path
        }

        function onErrorOccurred(message) {
            errorDialog.text = message
            errorDialog.open()
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
                    Layout.fillHeight: true
                    color: "transparent"
                    border.color: "#BDBDBD"
                    border.width: 1
                    radius: 8

                    Image {
                        id: originalImage
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
                                filterController.loadImage(drop.urls[0])
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
                        processedImagePath = ""
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

        // Panel central - Filtros y Parámetros
        Rectangle {
            Layout.preferredWidth: 380
            Layout.fillHeight: true
            radius: 10
            color: "#FFFFFF"
            border.color: "#2196F3"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Label {
                    text: "🔲 Filtros Disponibles"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#000000"
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200

                    ListView {
                        id: filterList
                        model: filterController.availableFilters
                        spacing: 5
                        clip: true

                        delegate: ItemDelegate {
                            width: ListView.view.width
                            text: modelData
                            highlighted: ListView.isCurrentItem

                            background: Rectangle {
                                radius: 6
                                color: parent.highlighted ? "#2196F3" : (parent.hovered ? "#E3F2FD" : "white")
                                border.color: parent.highlighted ? "#1565C0" : "#BDBDBD"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            contentItem: Label {
                                text: parent.text
                                color: parent.highlighted ? "white" : "#000000"
                                font: parent.font
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                filterList.currentIndex = index
                                filterController.selectFilter(modelData)
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#BDBDBD"
                }

                Label {
                    text: "⚙️ Parámetros del Filtro"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#000000"
                    visible: paramRepeater.count > 0
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            id: paramRepeater
                            model: {
                                if (!filterController.currentFilterParameters) return []
                                var params = filterController.currentFilterParameters
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
                            text: "No hay parámetros para este filtro"
                            font.italic: true
                            font.pixelSize: 12
                            visible: paramRepeater.count === 0
                            color: "#757575"
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: "⚡ Aplicar Filtro"
                    enabled: filterList.currentIndex >= 0 && originalImagePath !== ""

                    background: Rectangle {
                        radius: 8
                        color: parent.enabled ? (parent.hovered ? "#1976D2" : "#2196F3") : "#BDBDBD"
                        border.color: parent.enabled ? "#1565C0" : "#9E9E9E"
                        border.width: 2

                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    contentItem: Label {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 16
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: filterController.applyFilter()
                }
            }
        }

        // Panel derecho - Imagen procesada
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: "#F5F5F5"
            border.color: "#673AB7"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Label {
                    text: "🎨 Imagen Procesada"
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
                        id: processedImage
                        anchors.fill: parent
                        anchors.margins: 5
                        source: processedImagePath
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        visible: processedImagePath !== ""
                    }

                    Label {
                        anchors.centerIn: parent
                        text: "⚙️\n\nSelecciona un filtro\ny configura los parámetros"
                        horizontalAlignment: Text.AlignHCenter
                        color: "#757575"
                        font.pixelSize: 14
                        visible: processedImagePath === ""
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: "💾 Guardar Resultado"
                    visible: processedImagePath !== ""

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

            onTextChanged: filterController.setParameterValue(paramName, text)
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
                        filterController.setParameterValue(paramName, value)
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

            onCheckedChanged: filterController.setParameterValue(paramName, checked)
        }
    }

    // Diálogos
    Dialog {
        id: errorDialog
        property alias text: errorLabel.text

        title: "❌ Error"
        standardButtons: Dialog.Ok

        Label {
            id: errorLabel
            color: "#000000"
        }
    }

    FileDialog {
        id: fileDialog
        title: "Seleccionar Imagen"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Imágenes (*.png *.jpg *.jpeg *.bmp *.tiff)"]
        onAccepted: filterController.loadImage(selectedFile)
    }

    FileDialog {
        id: saveDialog
        title: "Guardar Imagen Procesada"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "png"
        nameFilters: ["PNG (*.png)", "JPEG (*.jpg)"]
        onAccepted: filterController.saveImage(selectedFile)
    }
}