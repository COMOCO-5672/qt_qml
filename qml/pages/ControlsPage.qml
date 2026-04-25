import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

ScrollView {
    contentWidth: availableWidth

    Column {
        width: parent.width
        padding: 20
        spacing: 14

        Section {
            width: parent.width - 40
            title: "基础控件: QWidget 到 QML 的第一层映射"

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "QML 的控件是声明式对象。你描述状态和关系，界面由绑定自动更新；QtWidget 更常见的是在槽函数里手动 setText/setEnabled。"
            }

            FormRow {
                label: "LineEdit"
                TextField {
                    width: 260
                    placeholderText: "类似 QLineEdit"
                    text: appVM.userName
                    onTextEdited: appVM.userName = text
                }
            }

            FormRow {
                label: "Button"
                Button {
                    text: "调用 C++ increase()"
                    onClicked: appVM.increase()
                }
                Button {
                    text: "Reset"
                    onClicked: appVM.reset()
                }
            }

            FormRow {
                label: "CheckBox"
                CheckBox {
                    text: "busy"
                    checked: appVM.busy
                    onToggled: appVM.busy = checked
                }
            }

            FormRow {
                label: "ComboBox"
                ComboBox {
                    width: 180
                    model: ["Primary", "Accent", "Warning"]
                }
            }

            FormRow {
                label: "Slider"
                Slider {
                    id: slider
                    width: 220
                    from: 0
                    to: 100
                    value: 35
                }
                Label {
                    text: Math.round(slider.value)
                }
            }
        }

        Section {
            width: parent.width - 40
            title: "布局: anchors / Row / Column / Layout"

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "QtWidget 常用 QHBoxLayout/QVBoxLayout；QML 有 Row/Column/Grid 这类轻量定位，也有 QtQuick.Layouts 里更接近 Widget Layout 的 RowLayout/ColumnLayout。"
            }

            RowLayout {
                width: parent.width
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: 4
                    color: "#e3f2fd"
                    Label {
                        anchors.centerIn: parent
                        text: "Layout.fillWidth"
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 150
                    height: 48
                    radius: 4
                    color: "#fff3e0"
                    Label {
                        anchors.centerIn: parent
                        text: "固定宽度"
                    }
                }
            }
        }
    }
}
