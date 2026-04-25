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
            title: "属性绑定: 少写槽函数，多描述关系"

            Slider {
                id: sizeSlider
                width: 320
                from: 60
                to: 220
                value: 120
            }

            Rectangle {
                width: sizeSlider.value
                height: sizeSlider.value * 0.55
                radius: 6
                color: mouseArea.containsMouse ? "#80cbc4" : "#b2dfdb"

                Label {
                    anchors.centerIn: parent
                    text: Math.round(parent.width) + " x " + Math.round(parent.height)
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: appVM.increase()
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "区别: QWidget 里通常 connect(slider, valueChanged, widget, setFixedWidth)。QML 里 width: sizeSlider.value 就是一条实时绑定。"
            }
        }

        Section {
            width: parent.width - 40
            title: "Binding 断开与恢复"

            property int manualWidth: 180

            Button {
                text: "手动赋值会覆盖绑定"
                onClicked: sampleBox.width = 80 + Math.random() * 260
            }

            Button {
                text: "恢复绑定 Qt.binding(...)"
                onClicked: sampleBox.width = Qt.binding(function() { return sizeSlider.value + 40 })
            }

            Rectangle {
                id: sampleBox
                width: sizeSlider.value + 40
                height: 42
                radius: 4
                color: "#c5cae9"
            }
        }
    }
}
