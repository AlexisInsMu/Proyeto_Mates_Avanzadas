import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Procesamiento Digital de Imágenes"

    // Gradiente de fondo global
    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#E3F2FD" }  // Azul muy claro
            GradientStop { position: 0.5; color: "#90CAF9" }  // Azul medio
            GradientStop { position: 1.0; color: "#42A5F5" }  // Azul intenso
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homeView
    }

    Component {
        id: homeView

        Page {
            background: Rectangle {
                color: "transparent"
            }

            header: ToolBar {
                background: Rectangle {
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1976D2" }
                        GradientStop { position: 1.0; color: "#1565C0" }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20

                    Image {
                        source: "qrc:/icons/logo.png"
                        sourceSize.height: 32
                        fillMode: Image.PreserveAspectFit
                        visible: false // Cambiar a true si tienes logo
                    }

                    Label {
                        text: "Procesamiento Digital de Imágenes"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "v1.0"
                        font.pixelSize: 12
                        color: "#BBDEFB"
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 30

                // Título principal
                Label {
                    text: "Sistema de Procesamiento de Imágenes"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#0D47A1"
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "Seleccione una herramienta para comenzar"
                    font.pixelSize: 16
                    color: "#1565C0"
                    Layout.alignment: Qt.AlignHCenter
                }

                // Grid de botones principales

                GridLayout {
                    columns: 2
                    rowSpacing: 20
                    columnSpacing: 20
                    Layout.alignment: Qt.AlignHCenter

                    // Botón Filtros Espaciales
                    Button {
                        Layout.preferredWidth: 280
                        Layout.preferredHeight: 120

                        background: Rectangle {
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: parent.parent.hovered ? "#1E88E5" : "#2196F3" }
                                GradientStop { position: 1.0; color: parent.parent.hovered ? "#1565C0" : "#1976D2" }
                            }
                            border.color: "#0D47A1"
                            border.width: 2
                        }

                        contentItem: ColumnLayout {
                            spacing: 10

                            Label {
                                text: "🔲"
                                font.pixelSize: 40
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Label {
                                text: "Filtros Matemáticos"
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Label {
                                text: "Convolución, morfología"
                                font.pixelSize: 12
                                color: "#BBDEFB"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        onClicked: stackView.push(Qt.resolvedUrl("FilterView.qml"))
                    }

                    // Botón Transformada de Fourier
                    Button {
                        Layout.preferredWidth: 280
                        Layout.preferredHeight: 120

                        background: Rectangle {
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: parent.parent.hovered ? "#5E35B1" : "#673AB7" }
                                GradientStop { position: 1.0; color: parent.parent.hovered ? "#4527A0" : "#512DA8" }
                            }
                            border.color: "#311B92"
                            border.width: 2
                        }

                        contentItem: ColumnLayout {
                            spacing: 10

                            Label {
                                text: "📊"
                                font.pixelSize: 40
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Label {
                                text: "Análisis de Fourier"
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Label {
                                text: "Filtros frecuenciales"
                                font.pixelSize: 12
                                color: "#D1C4E9"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        onClicked: stackView.push(Qt.resolvedUrl("FourierView.qml"))
                    }

                    // Botón Generación de Ruido
                    Button {
                        Layout.preferredWidth: 280
                        Layout.preferredHeight: 120

                        background: Rectangle {
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: parent.parent.hovered ? "#00897B" : "#009688" }
                                GradientStop { position: 1.0; color: parent.parent.hovered ? "#00695C" : "#00796B" }
                            }
                            border.color: "#004D40"
                            border.width: 2
                        }

                        contentItem: ColumnLayout {
                            spacing: 10

                            Label {
                                text: "🔊"
                                font.pixelSize: 40
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Label {
                                text: "Generación de Ruido"
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Label {
                                text: "Gaussiano, sal y pimienta"
                                font.pixelSize: 12
                                color: "#B2DFDB"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        onClicked: stackView.push(Qt.resolvedUrl("NoiseView.qml"))
                    }

                    // Botón Comparación
                    Button {
                        Layout.preferredWidth: 280
                        Layout.preferredHeight: 120

                        background: Rectangle {
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: parent.parent.hovered ? "#E64A19" : "#FF5722" }
                                GradientStop { position: 1.0; color: parent.parent.hovered ? "#D84315" : "#E64A19" }
                            }
                            border.color: "#BF360C"
                            border.width: 2
                        }

                        contentItem: ColumnLayout {
                            spacing: 10

                            Label {
                                text: "⚖️"
                                font.pixelSize: 40
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Label {
                                text: "Comparación"
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Label {
                                text: "Métricas y análisis"
                                font.pixelSize: 12
                                color: "#FFCCBC"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        onClicked: stackView.push(Qt.resolvedUrl("ComparativeView.qml"))
                    }
                }

                // Información adicional
                Rectangle {
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 80
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    radius: 10
                    color: "#FFFFFF"
                    opacity: 0.9
                    border.color: "#1976D2"
                    border.width: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Label {
                            text: "ℹ️"
                            font.pixelSize: 32
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Label {
                                text: "Consejo:"
                                font.bold: true
                                font.pixelSize: 14
                                color: "#1976D2"
                            }

                            Label {
                                text: "Puedes arrastrar imágenes directamente a las áreas de carga"
                                font.pixelSize: 12
                                color: "#424242"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            footer: ToolBar {
                background: Rectangle {
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1565C0" }
                        GradientStop { position: 1.0; color: "#0D47A1" }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20

                    Label {
                        text: "Equipo, no tenemos nombres aún, Matemáticas Avanzadas 2026"
                        font.pixelSize: 11
                        color: "#BBDEFB"
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        text: "Desarrollado con PySide6 + OpenCV"
                        font.pixelSize: 11
                        color: "#BBDEFB"
                    }
                }
            }
        }
    }
}