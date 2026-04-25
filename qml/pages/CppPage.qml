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
            title: "QObject ViewModel: Q_PROPERTY + NOTIFY"

            FormRow {
                label: "userName"
                TextField {
                    width: 260
                    text: appVM.userName
                    onTextEdited: appVM.userName = text
                }
            }

            FormRow {
                label: "count"
                Button {
                    text: "-"
                    enabled: appVM.count > 0
                    onClicked: appVM.count = appVM.count - 1
                }
                Label {
                    width: 50
                    horizontalAlignment: Text.AlignHCenter
                    text: appVM.count
                }
                Button {
                    text: "+"
                    onClicked: appVM.increase()
                }
            }

            Switch {
                text: "busy"
                checked: appVM.busy
                onToggled: appVM.busy = checked
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: appVM.statusText
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "关键点: Q_PROPERTY 的 NOTIFY 信号相当于通知 QML 重新计算绑定。没有 NOTIFY，QML 可能读得到初值，但界面不会自动刷新。"
            }
        }

        Section {
            width: parent.width - 40
            title: "QAbstractListModel: 类似 Model/View，但 delegate 更轻"

            RowLayout {
                width: parent.width

                TextField {
                    id: todoInput
                    Layout.fillWidth: true
                    placeholderText: "输入待办"
                    onAccepted: {
                        todoModel.addTodo(text)
                        text = ""
                    }
                }

                Button {
                    text: "Add"
                    onClicked: {
                        todoModel.addTodo(todoInput.text)
                        todoInput.text = ""
                    }
                }
            }

            ListView {
                width: parent.width
                height: 220
                clip: true
                model: todoModel
                spacing: 6

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 44
                    radius: 4
                    color: done ? "#e8f5e9" : "#fafafa"
                    border.color: "#d8dee9"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8

                        CheckBox {
                            checked: done
                            onToggled: todoModel.toggleDone(index)
                        }

                        Label {
                            Layout.fillWidth: true
                            text: title
                            elide: Text.ElideRight
                            font.strikeout: done
                        }

                        Button {
                            text: "Remove"
                            onClicked: todoModel.removeTodo(index)
                        }
                    }
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "QtWidget 对照: QTableView/QListView delegate 常写 C++ delegate；QML delegate 是声明式组件，模型 roleNames() 暴露的 role 会直接变成 title/done 变量。"
            }
        }
    }
}
