import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root
    property alias pageTitle: titleLabel.text
    property color accentColor: "#2196F3"

    // Estilo global para Labels
    property color defaultTextColor: "#000000"

    // Aplicar a todos los Labels hijos
    Component.onCompleted: {
        for (var i = 0; i < children.length; i++) {
            if (children[i] instanceof Label) {
                children[i].color = defaultTextColor;
            }
        }
    }

    background: Rectangle {
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#E3F2FD" }
            GradientStop { position: 0.5; color: "#90CAF9" }
            GradientStop { position: 1.0; color: "#42A5F5" }
        }
    }

    header: ToolBar {
        background: Rectangle {
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.accentColor }
                GradientStop { position: 1.0; color: Qt.darker(root.accentColor, 1.2) }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            ToolButton {
                text: "← Volver"
                font.bold: true
                onClicked: stackView.pop()

                background: Rectangle {
                    radius: 6
                    color: parent.hovered ? Qt.lighter(root.accentColor, 1.2) : "transparent"
                    border.color: "white"
                    border.width: parent.hovered ? 2 : 0

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                contentItem: Label {
                    text: parent.text
                    color: "#000000"
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                font.pixelSize: 20
                font.bold: true
                color: "#000000"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
            }

            Label {
                text: new Date().toLocaleDateString()
                font.pixelSize: 11
                color: "#BBDEFB"
            }
        }
    }
}