import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

ScrollView {
    id: root

    contentWidth: availableWidth

    Action {
        id: clearLogAction

        text: "Clear"
        shortcut: StandardKey.Refresh
        onTriggered: eventVM.clear()
    }

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: eventVM.recordEvent("Shortcut", "Ctrl+S 被触发，类似 QWidget/QAction 快捷键")
    }

    Column {
        width: root.width
        padding: 20
        spacing: 14

        Section {
            width: parent.width - 40
            title: "事件总览: QML 负责入口，C++ 负责决策"

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "这个页面演示局部事件、键盘事件、快捷键和 C++ eventFilter。QML 事件处理器只记录或转发事件，不在这里写业务逻辑。"
            }

            RowLayout {
                width: parent.width

                Label {
                    Layout.fillWidth: true
                    text: "最近事件: " + eventVM.lastEvent
                    elide: Text.ElideRight
                }

                Button {
                    action: clearLogAction
                }
            }
        }

        Section {
            width: parent.width - 40
            title: "MouseArea: 鼠标按下、释放、移动、滚轮"

            Rectangle {
                id: mouseBox

                width: 360
                height: 150
                radius: 6
                color: mouseArea.containsMouse ? "#dcedc8" : "#f5f5f5"
                border.color: "#90a4ae"

                Label {
                    anchors.centerIn: parent
                    text: "MouseArea\n点击、拖动、滚轮"
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onPressed: function(mouse) {
                        eventVM.recordEvent("MouseArea", "pressed x=" + Math.round(mouse.x) + ", y=" + Math.round(mouse.y))
                    }

                    onReleased: function(mouse) {
                        eventVM.recordEvent("MouseArea", "released button=" + mouse.button)
                    }

                    onClicked: function(mouse) {
                        eventVM.recordEvent("MouseArea", "clicked button=" + mouse.button)
                    }

                    onPositionChanged: function(mouse) {
                        if (pressed) {
                            eventVM.recordEvent("MouseArea", "drag move x=" + Math.round(mouse.x) + ", y=" + Math.round(mouse.y))
                        }
                    }

                    onWheel: function(wheel) {
                        eventVM.recordEvent("MouseArea", "wheel delta=" + wheel.angleDelta.y)
                        wheel.accepted = true
                    }
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "QtWidget 对照: mousePressEvent/mouseReleaseEvent/mouseMoveEvent/wheelEvent。QML 里通常铺一层 MouseArea，anchors.fill: parent 表示事件区域填满父控件。"
            }
        }

        Section {
            width: parent.width - 40
            title: "Pointer Handlers: hover、tap、drag"

            Rectangle {
                id: handlerBox

                width: 360
                height: 150
                radius: 6
                color: hoverHandler.hovered ? "#bbdefb" : "#eeeeee"
                border.color: tapHandler.pressed ? "#1565c0" : "#90a4ae"

                Label {
                    anchors.centerIn: parent
                    text: dragHandler.active ? "Dragging" : "Hover / Tap / Drag"
                }

                HoverHandler {
                    id: hoverHandler

                    onHoveredChanged: eventVM.recordEvent("HoverHandler", hovered ? "entered" : "exited")
                }

                TapHandler {
                    id: tapHandler

                    onTapped: eventVM.recordEvent("TapHandler", "tapped")
                }

                DragHandler {
                    id: dragHandler

                    onActiveChanged: eventVM.recordEvent("DragHandler", active ? "drag started" : "drag finished")
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Pointer Handler 更像现代输入抽象，适合鼠标、触摸和触控板统一处理。简单项目 MouseArea 够用，复杂交互优先考虑 Handler。"
            }
        }

        Section {
            width: parent.width - 40
            title: "Keys / Shortcut / C++ eventFilter"

            Rectangle {
                id: keyBox

                width: 360
                height: 110
                radius: 6
                color: activeFocus ? "#fff9c4" : "#fafafa"
                border.color: activeFocus ? "#f9a825" : "#b0bec5"
                focus: true

                Label {
                    anchors.centerIn: parent
                    text: keyBox.activeFocus ? "按 Enter / Space / Escape / F2 / Ctrl+S" : "点击这里获取键盘焦点"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: keyBox.forceActiveFocus()
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        eventVM.recordEvent("Keys", "Enter 被当前控件处理")
                        event.accepted = true
                    } else if (event.key === Qt.Key_Space) {
                        eventVM.recordEvent("Keys", "Space 被当前控件处理")
                        event.accepted = true
                    }
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Enter/Space 在当前焦点控件里处理；Ctrl+S 用 Shortcut；F2/Escape 会被 C++ AppEventFilter 记录。eventFilter 返回 false，所以不会吞掉事件。"
            }
        }

        Section {
            width: parent.width - 40
            title: "事件日志"

            TextArea {
                width: parent.width
                height: 210
                readOnly: true
                wrapMode: TextArea.NoWrap
                text: eventVM.eventLog
            }
        }
    }
}
