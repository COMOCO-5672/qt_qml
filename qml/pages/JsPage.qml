import QtQuick 2.15
import QtQuick.Controls 2.15
import "../components"
import "../js/mathTools.js" as MathTools

ScrollView {
    contentWidth: availableWidth

    Column {
        width: parent.width
        padding: 20
        spacing: 14

        Section {
            id: priceSection
            width: parent.width - 40
            title: "QML 内联 JS: 适合界面逻辑"

            property int quantity: 2
            property real unitPrice: 19.9

            SpinBox {
                from: 1
                to: 20
                value: priceSection.quantity
                onValueModified: priceSection.quantity = value
            }

            Label {
                text: "含税价格: " + MathTools.priceWithTax(priceSection.quantity * priceSection.unitPrice, 0.13)
            }

            Button {
                text: "随机数量"
                onClicked: priceSection.quantity = MathTools.clamp(Math.round(Math.random() * 25), 1, 20)
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: "建议: UI 展示、格式化、轻量计算可以放 JS；业务规则、IO、模型数据、线程任务仍放 C++ ViewModel/Service。"
            }
        }

        Section {
            width: parent.width - 40
            title: "信号处理器就是 JS 函数体"

            Slider {
                id: level
                width: 320
                from: 0
                to: 100
                value: 55
            }

            Label {
                text: "等级: " + MathTools.levelText(level.value)
            }
        }
    }
}
