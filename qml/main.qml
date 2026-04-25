import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    id: window

    width: 1100
    height: 720
    visible: true
    title: "QML Quick Start for QtWidget Developers"

    property var pages: [
        { title: "基础控件", source: "pages/ControlsPage.qml" },
        { title: "属性绑定", source: "pages/BindingPage.qml" },
        { title: "样式", source: "pages/StylePage.qml" },
        { title: "JS", source: "pages/JsPage.qml" },
        { title: "事件处理", source: "pages/EventsPage.qml" },
        { title: "C++ ViewModel", source: "pages/CppPage.qml" }
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ListView {
            id: nav
            Layout.preferredWidth: 190
            Layout.fillHeight: true
            clip: true
            model: window.pages
            currentIndex: 0

            delegate: ItemDelegate {
                width: nav.width
                text: modelData.title
                highlighted: ListView.isCurrentItem
                onClicked: nav.currentIndex = index
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: "#d8dee9"
        }

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: window.pages[nav.currentIndex].source
        }
    }
}
