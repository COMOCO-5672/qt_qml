# QML for QtWidget Developers

这份笔记配合项目代码阅读，重点不是罗列 API，而是把 QtWidget 经验迁移到 QML 的写法上。

## 1. 程序入口

Widget 项目通常创建 `QApplication` 和一个主窗口:

```cpp
QApplication app(argc, argv);
MainWindow w;
w.show();
return app.exec();
```

QML 项目通常创建 `QGuiApplication`，再用 `QQmlApplicationEngine` 加载入口 QML:

```cpp
QGuiApplication app(argc, argv);
QQmlApplicationEngine engine;
engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
return app.exec();
```

本项目入口在 `src/main.cpp`。

## 2. ViewModel 暴露给 QML

推荐先用 `setContextProperty` 入门:

```cpp
AppViewModel appViewModel;
engine.rootContext()->setContextProperty(QStringLiteral("appVM"), &appViewModel);
```

然后 QML 里直接访问:

```qml
Label {
    text: appVM.statusText
}

Button {
    onClicked: appVM.increase()
}
```

实际大型项目也可以用 `qmlRegisterType` 注册类型，让 QML 自己创建对象:

```cpp
qmlRegisterType<AppViewModel>("Demo", 1, 0, "AppViewModel");
```

```qml
import Demo 1.0

AppViewModel {
    id: vm
}
```

入门阶段 `setContextProperty` 更直观；模块化阶段 `qmlRegisterType` 更清晰。

## 3. Q_PROPERTY 是绑定的基础

C++:

```cpp
Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
```

QML:

```qml
Label {
    text: appVM.count
}
```

当 `setCount()` 发出 `countChanged()`，所有依赖 `appVM.count` 的绑定都会重新计算。这个机制替代了大量 Widget 里手写的 `setText()`、`setEnabled()`、`update()`。

## 4. 控件映射速查

| QtWidget | QML / Qt Quick Controls |
| --- | --- |
| `QMainWindow` | `ApplicationWindow` |
| `QPushButton` | `Button` |
| `QLineEdit` | `TextField` |
| `QTextEdit` | `TextArea` |
| `QCheckBox` | `CheckBox` |
| `QRadioButton` | `RadioButton` |
| `QComboBox` | `ComboBox` |
| `QSlider` | `Slider` |
| `QLabel` | `Label` / `Text` |
| `QListView` | `ListView` |
| `QTableView` | `TableView` |
| `QHBoxLayout` | `RowLayout` / `Row` |
| `QVBoxLayout` | `ColumnLayout` / `Column` |

## 5. 属性绑定

Widget 写法:

```cpp
connect(slider, &QSlider::valueChanged, this, [=](int value) {
    box->setFixedWidth(value);
});
```

QML 写法:

```qml
Slider {
    id: slider
    from: 60
    to: 220
}

Rectangle {
    width: slider.value
}
```

注意: 直接给绑定属性赋值会断开原绑定。

```qml
sampleBox.width = 200
```

恢复绑定:

```qml
sampleBox.width = Qt.binding(function() {
    return slider.value
})
```

## 6. 信号处理

QML 里 `onClicked`、`onTextEdited`、`onToggled` 都是信号处理器:

```qml
Button {
    text: "Add"
    onClicked: todoModel.addTodo(input.text)
}
```

它对应 Widget 里的 `connect(button, &QPushButton::clicked, ...)`。

## 7. JavaScript 放哪里

适合放 QML/JS:

- UI 格式化
- 简单计算
- 根据控件状态决定显示
- 动画和交互胶水代码

适合放 C++:

- 业务规则
- 文件、网络、数据库
- 多线程和耗时任务
- 可测试的核心逻辑
- 复杂模型数据

本项目的 JS 示例在 `qml/js/mathTools.js`。

## 8. QAbstractListModel 到 ListView

C++ 模型通过 `roleNames()` 把字段名暴露给 QML:

```cpp
QHash<int, QByteArray> TodoListModel::roleNames() const
{
    return {
        {TitleRole, "title"},
        {DoneRole, "done"}
    };
}
```

QML delegate 里可以直接使用:

```qml
ListView {
    model: todoModel

    delegate: CheckBox {
        text: title
        checked: done
    }
}
```

对 Widget 开发者来说，可以把 QML delegate 理解成更轻、更声明式的 `QStyledItemDelegate`。

## 9. 样式

全局样式在 C++ 入口设置:

```cpp
QQuickStyle::setStyle(QStringLiteral("Material"));
```

局部样式在控件上覆盖:

```qml
Button {
    contentItem: Label {
        text: parent.text
        color: "white"
    }

    background: Rectangle {
        radius: 6
        color: parent.down ? "#00695c" : "#00897b"
    }
}
```

Widget 的 `QStyleSheet` 更像统一 CSS；QML 的样式更组件化，适合把样式也拆成可复用 QML 组件。

## 10. 建议的项目分层

```text
src/
  AppViewModel.h/.cpp      C++ 状态和命令
  TodoListModel.h/.cpp     C++ 列表模型
qml/
  main.qml                 主窗口和导航
  pages/                   页面
  components/              可复用控件
  js/                      轻量 UI JS
```

保持一个原则: QML 管 View，C++ 管状态、模型、业务行为。
