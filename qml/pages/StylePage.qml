import QtQuick 2.15
import QtQuick.Controls 2.15
import "../components"

ScrollView {
    contentWidth: availableWidth

    Column {
        width: parent.width
        padding: 20
        spacing: 14

        Section {
            width: parent.width - 40
            title: "样式: 局部 background/contentItem 覆盖"

            Button {
                id: customButton
                text: "自定义 Button"
                padding: 12

                contentItem: Label {
                    text: customButton.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }

                background: Rectangle {
                    radius: 6
                    color: customButton.down ? "#00695c" : "#00897b"
                }
            }

            TextField {
                width: 300
                placeholderText: "自定义输入框背景"
                background: Rectangle {
                    radius: 4
                    border.color: parent.activeFocus ? "#00897b" : "#b0bec5"
                    border.width: 1
                    color: "#ffffff"
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "QtWidget 常用 QStyleSheet 或重写 paintEvent；QML 常在控件上替换 background/contentItem，或切换全局 style。"
            }
        }

        Section {
            width: parent.width - 40
            title: "状态驱动样式: State + Transition"

            Rectangle {
                id: card
                width: 280
                height: 90
                radius: 6
                color: "#eceff1"
                border.color: "#b0bec5"

                Label {
                    anchors.centerIn: parent
                    text: area.containsMouse ? "hover" : "normal"
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                }

                states: State {
                    name: "hovered"
                    when: area.containsMouse
                    PropertyChanges {
                        target: card
                        color: "#ffe082"
                        scale: 1.03
                    }
                }

                transitions: Transition {
                    NumberAnimation {
                        properties: "scale"
                        duration: 120
                    }
                    ColorAnimation {
                        duration: 120
                    }
                }
            }
        }
    }
}
