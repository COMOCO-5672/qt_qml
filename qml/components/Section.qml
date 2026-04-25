import QtQuick 2.15
import QtQuick.Controls 2.15

Pane {
    id: root

    property alias title: titleLabel.text
    default property alias content: body.data

    padding: 16

    background: Rectangle {
        color: "#ffffff"
        border.color: "#d8dee9"
        radius: 6
    }

    Column {
        anchors.fill: parent
        spacing: 10

        Label {
            id: titleLabel
            font.pixelSize: 18
            font.bold: true
            color: "#263238"
        }

        Column {
            id: body
            width: parent.width
            spacing: 8
        }
    }
}
