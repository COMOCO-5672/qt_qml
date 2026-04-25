# QML Quick Start for QtWidget Developers

这个仓库是一个从 0 搭好的 QML 入门项目，目标读者是已经熟悉 QtWidget 的开发者。示例代码覆盖:

- QML 基础控件: `Button`、`TextField`、`CheckBox`、`ComboBox`、`Slider`、`ListView`
- 布局方式: `Row` / `Column` / `RowLayout` / `anchors`
- 属性绑定: QML 声明式绑定、手动赋值断开绑定、`Qt.binding()` 恢复绑定
- 样式: `background` / `contentItem`、`State` / `Transition`
- JavaScript: 内联 JS、外部 `.js` 工具文件
- C++ 绑定: `QObject` ViewModel、`Q_PROPERTY`、`Q_INVOKABLE`、`QAbstractListModel`

## 构建

```powershell
cmake -S . -B build
cmake --build build --config Debug
.\build\Debug\QmlQuickStart.exe
```

如果你的生成器不是 Visual Studio，最后的 exe 路径可能是:

```powershell
.\build\QmlQuickStart.exe
```

## 代码入口

- [src/main.cpp](src/main.cpp): 创建 `QGuiApplication`、加载 QML、向 QML 注入 C++ ViewModel。
- [src/AppViewModel.h](src/AppViewModel.h): `QObject` + `Q_PROPERTY` 示例。
- [src/TodoListModel.h](src/TodoListModel.h): `QAbstractListModel` 示例。
- [qml/main.qml](qml/main.qml): 主窗口和左侧导航。
- [qml/pages](qml/pages): 每个 QML 学习主题一个页面。
- [docs/QML_CODE_STANDARD.md](docs/QML_CODE_STANDARD.md): QML 项目代码规范、架构边界、发布注意事项。
- [docs/QML_DEPLOYMENT_PROTECTION.md](docs/QML_DEPLOYMENT_PROTECTION.md): QML/JS 发布、qrc 打包和源码保护边界。

## 和 QtWidget 的关键区别

### 1. 编程模型

QtWidget 偏命令式:

```cpp
connect(button, &QPushButton::clicked, this, [=] {
    label->setText(QString::number(++count));
});
```

QML 偏声明式:

```qml
Label {
    text: appVM.count
}
Button {
    onClicked: appVM.increase()
}
```

你不需要手动 `setText()`，只要 `countChanged()` 发出，绑定会自动刷新。

### 2. ViewModel 推荐方式

把业务状态放在 C++ `QObject` 中:

```cpp
Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
Q_INVOKABLE void increase();
```

在 QML 中直接使用:

```qml
TextField {
    text: appVM.userName
    onTextEdited: appVM.userName = text
}
Button {
    onClicked: appVM.increase()
}
```

这很接近 MVVM/ViewModel 思路: QML 是 View，C++ `AppViewModel` 是状态和行为。

### 3. Model/View

Widget 中常见:

- `QListView` + `QAbstractListModel`
- `QStyledItemDelegate`

QML 中保留 `QAbstractListModel`，但 delegate 直接写 QML:

```qml
ListView {
    model: todoModel
    delegate: CheckBox {
        text: title
        checked: done
    }
}
```

`title`、`done` 来自 C++ 模型的 `roleNames()`。

### 4. 样式

QtWidget 常用 `QStyleSheet` 或自定义绘制；QML 常用:

- 全局样式: `QQuickStyle::setStyle("Material")`
- 局部样式: 替换控件的 `background` / `contentItem`
- 状态动画: `states` + `transitions`

## 学习路线

1. 先看 `qml/pages/ControlsPage.qml`，建立控件和布局直觉。
2. 再看 `qml/pages/BindingPage.qml`，理解 QML 最核心的属性绑定。
3. 看 `src/AppViewModel.*` 和 `qml/pages/CppPage.qml`，掌握 C++ 和 QML 如何互通。
4. 最后看 `TodoListModel.*`，这是实际项目里列表、表格、树形数据的基础。

## 官方文档关键词

建议按这些关键词查 Qt 官方文档:

- Qt Quick
- QML Syntax
- Qt Quick Controls 2
- Property Binding
- QML JavaScript Host Environment
- QQmlContext setContextProperty
- qmlRegisterType
- QAbstractListModel QML roleNames
