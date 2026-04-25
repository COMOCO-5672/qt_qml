import QtQuick 2.15
import QtQuick.Controls 2.15

Row {
    id: root

    property alias label: labelItem.text
    default property alias content: slot.data

    width: parent ? parent.width : implicitWidth
    spacing: 12

    Label {
        id: labelItem
        width: 120
        anchors.verticalCenter: parent.verticalCenter
        color: "#546e7a"
    }

    Row {
        id: slot
        width: root.width - labelItem.width - root.spacing
        spacing: 8
    }
}
