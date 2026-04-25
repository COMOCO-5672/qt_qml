# Qt QML Code Standard

这份规范面向有 QtWidget 背景的团队，目标是避免 QML 项目后期变成“大量 JS + 到处事件 + 难维护状态”的局面。

依据包括:

- Qt 官方 QML Coding Conventions: https://doc.qt.io/qt-6/qml-codingconventions.html
- Qt 官方 QML Deployment: https://doc.qt.io/qt-6/qtquick-deployment.html
- Qt 官方 qmlcachegen: https://doc.qt.io/qt-6/qtqml-tool-qmlcachegen.html

## 1. 总原则

QML 只负责 View:

- 页面结构
- 控件布局
- 视觉状态
- 动画和过渡
- 用户事件入口
- 轻量格式化

C++ 负责 Model / ViewModel / Service:

- 业务规则
- 数据校验
- 文件、网络、数据库
- 多线程和耗时任务
- 权限、授权、加密、许可证
- 复杂列表/表格模型

禁止把核心业务写在 QML/JS 中。QML 文件天然更容易被看到或逆向，不能保存商业秘密、密钥、算法核心。

## 2. 推荐目录结构

```text
src/
  viewmodels/          QObject ViewModel
  models/              QAbstractListModel / table model
  services/            IO、网络、数据库、业务服务
  main.cpp

qml/
  main.qml
  pages/               页面级组件
  components/          可复用基础组件
  controls/            项目自定义控件
  dialogs/
  js/                  只放轻量 UI 工具函数
  styles/              色板、字体、尺寸 token

docs/
  QML_CODE_STANDARD.md
```

当前项目为了入门较简单，没有强制拆 `viewmodels/`、`models/` 子目录；真实项目建议拆。

## 3. QML 对象声明顺序

遵循 Qt 官方推荐顺序:

```qml
Rectangle {
    id: root

    property int count: 0
    property alias title: titleLabel.text

    signal accepted(string text)

    function reset() {
        count = 0
    }

    width: 320
    height: 160
    color: "#ffffff"

    Label {
        id: titleLabel
    }
}
```

顺序固定为:

```text
id
property
signal
function
普通属性
states/transitions
子对象
```

## 4. 命名规则

文件:

- 页面: `UserListPage.qml`
- 组件: `PrimaryButton.qml`
- 对话框: `UserEditDialog.qml`
- JS 工具: `formatTools.js`

对象:

- 根对象统一用 `id: root`
- 控件 id 使用语义名: `saveButton`、`nameField`、`userList`
- 禁止 `rect1`、`btn2`、`aaa`

ViewModel:

- QML 上下文名使用 `xxxVM`: `appVM`、`userVM`
- C++ 类名使用 `XxxViewModel`
- 列表模型使用 `XxxModel`

## 5. 属性绑定规则

推荐:

```qml
Button {
    enabled: userVM.canSave
    text: userVM.busy ? "Saving..." : "Save"
}
```

谨慎:

```qml
Button {
    enabled: nameField.text.length > 0 && ageField.value >= 18 && !userVM.busy
}
```

超过一个业务判断时，放到 C++ ViewModel:

```cpp
Q_PROPERTY(bool canSave READ canSave NOTIFY canSaveChanged)
```

禁止在多个 QML 文件复制同一套判断逻辑。

直接赋值会覆盖绑定:

```qml
sampleBox.width = 200
```

需要恢复绑定时使用:

```qml
sampleBox.width = Qt.binding(function() {
    return sizeSlider.value + 40
})
```

规范要求: 只有在示例、临时交互、动画控制中允许主动断开绑定；业务页面不要依赖这种写法管理长期状态。

## 6. 事件处理规则

QML 事件处理器只做三件事:

1. 读取 UI 输入
2. 调用 ViewModel 命令
3. 发送组件信号

推荐:

```qml
Button {
    text: "Save"
    enabled: userVM.canSave
    onClicked: userVM.save()
}
```

推荐组件封装:

```qml
ClickableCard {
    onClicked: userVM.openDetail(model.id)
}
```

禁止:

```qml
Button {
    onClicked: {
        if (nameField.text.length === 0) {
            errorLabel.text = "Name is required"
            return
        }

        if (modeBox.currentIndex === 2) {
            // dozens of business branches
        }

        // network / file / database / license logic
    }
}
```

经验阈值:

- `onClicked` 超过 5 行，考虑提取函数。
- 函数超过 15 行，考虑挪到 ViewModel。
- 同一逻辑出现 2 次，提取组件或 ViewModel 属性。

## 7. eventFilter 思路迁移

局部控件事件:

- 鼠标点击: `TapHandler` / `MouseArea`
- 悬停: `HoverHandler`
- 拖拽: `DragHandler`
- 滚轮: `WheelHandler`
- 键盘: `Keys.onPressed`

跨页面快捷键:

- `Action`
- `Shortcut`

底层或全局事件:

- C++ `installEventFilter`
- 自定义 `QQuickItem`

规则:

- 局部 UI 交互优先 QML handler。
- 全局拦截、复杂输入法、原生窗口事件、硬件输入，放 C++。
- 不要为了模拟 Widget 写法，把所有 QML 事件都绕回一个全局 eventFilter。

## 8. 组件封装规则

当同类 UI 出现两次，优先封装 QML 组件:

```qml
// components/FormRow.qml
Row {
    id: root

    property alias label: labelItem.text
    default property alias content: slot.data

    Label {
        id: labelItem
        width: 120
    }

    Row {
        id: slot
    }
}
```

外部使用:

```qml
FormRow {
    label: "User name"

    TextField {
        text: userVM.name
        onTextEdited: userVM.name = text
    }
}
```

组件只暴露必要属性和信号，不暴露内部 id。

## 9. JavaScript 使用边界

允许:

- 显示格式化
- 简单数学计算
- UI 状态转换
- 小型纯函数

不允许:

- 文件读写
- 网络协议
- 数据库
- 授权和许可证
- 复杂业务规则
- 密钥或算法核心

JS 文件建议使用 `.pragma library`:

```js
.pragma library

function priceWithTax(price, taxRate) {
    return (price * (1 + taxRate)).toFixed(2)
}
```

## 10. C++ ViewModel 规则

每个暴露给 QML 的状态使用 `Q_PROPERTY`:

```cpp
Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
Q_PROPERTY(bool canSave READ canSave NOTIFY canSaveChanged)
```

setter 必须判断重复值:

```cpp
void UserViewModel::setUserName(const QString &userName)
{
    if (m_userName == userName) {
        return;
    }

    m_userName = userName;
    emit userNameChanged();
    emit canSaveChanged();
}
```

QML 可调用函数使用 `Q_INVOKABLE` 或 slot:

```cpp
Q_INVOKABLE void save();
```

规则:

- 有绑定就必须有准确的 `NOTIFY`。
- 派生属性变化时也要发通知，例如 `userName` 变化可能影响 `canSave`。
- QML 不直接操作 Service，只通过 ViewModel。

## 11. Model/View 规则

列表、表格、树形数据优先 C++ Model:

- `QAbstractListModel`
- `QAbstractTableModel`
- `QSortFilterProxyModel`

QML delegate 只展示和转发事件:

```qml
delegate: TodoRow {
    title: model.title
    done: model.done
    onToggleRequested: todoModel.toggleDone(index)
}
```

不要在 delegate 内写复杂业务逻辑。delegate 数量可能很大，逻辑越重越难维护，也更容易影响性能。

## 12. 布局规则

优先使用:

- `RowLayout` / `ColumnLayout` 处理应用界面布局
- `Row` / `Column` 处理简单固定排列
- `anchors` 处理贴边、覆盖、居中

`anchors.fill: parent` 含义:

```text
子对象上下左右全部贴住父对象，等价于填满父对象区域。
```

类似 Widget:

```cpp
child->setGeometry(parent->rect());
```

禁止同一个 item 同时混用 anchors 和 Layout 附加属性控制同一方向的尺寸/位置。

## 13. 样式规则

应用级:

```cpp
QQuickStyle::setStyle(QStringLiteral("Material"));
```

组件级:

```qml
Button {
    contentItem: Label {
        text: parent.text
    }

    background: Rectangle {
        radius: 6
    }
}
```

大型项目建议建立:

```text
qml/styles/Theme.qml
qml/controls/PrimaryButton.qml
qml/controls/DangerButton.qml
```

不要在业务页面里到处散落颜色、字号、圆角。颜色和尺寸应该集中成 token。

## 14. 性能规则

禁止:

- 在绑定表达式里做重计算。
- 在 delegate 里创建大量复杂嵌套对象。
- 在 QML 中频繁操作大数组。
- 在 QML/JS 中做 IO 或耗时任务。

推荐:

- 大数据放 C++ model。
- 计算结果放 ViewModel 属性。
- 页面懒加载使用 `Loader`。
- 列表 delegate 保持薄。
- Qt 6 项目启用 `qt_add_qml_module`，配合 qmlcachegen/qmllint。

## 15. 发布与源码可见性

QML/JS 发布要明确一个事实:

```text
QRC、qmlcachegen、Qt Quick Compiler 都不是严格意义上的加密。
```

推荐发布策略:

1. 自己的 QML/JS 加入 Qt Resource System，不以散文件发布。
2. C++ 从 `qrc:/` 或 `qrc:///` 加载入口 QML。
3. Release 包不要携带项目源码目录。
4. Qt 6 使用 `qt_add_qml_module`，让构建系统自动处理资源和 AOT 编译。
5. Qt 5/qmake 可使用 `CONFIG += qtquickcompiler`。
6. 核心业务、授权、密钥、算法放 C++ 或服务端。
7. Release 关闭 QML 调试入口，不暴露调试端口。

当前项目已使用:

```cpp
engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
```

并通过 `qml.qrc` 把 QML/JS 编进资源。

这可以避免用户直接在安装目录看到你的项目 QML/JS 散文件，但不能阻止有经验的人从二进制或资源中逆向提取。真正敏感的东西不要放 QML。

## 16. Review Checklist

提交 QML 代码前检查:

- 页面事件是否只调用 ViewModel 或发信号？
- 是否有超过 15 行的 QML/JS 函数？
- 是否有业务判断散落在多个 QML 文件？
- 是否有核心逻辑、密钥、授权代码放在 QML/JS？
- 是否有重复 UI 结构可封装组件？
- ViewModel 属性是否都有准确 `NOTIFY`？
- delegate 是否足够薄？
- 是否使用 qrc 加载入口 QML？
- Release 包是否会携带项目 QML/JS 散文件？

## 17. 推荐工具

Qt 6:

```powershell
qmllint qml
qmlformat -i qml
```

Qt 5 项目至少保持:

```powershell
cmake --build build --config Debug
```

并在运行时观察 QML warning。QML warning 不要长期忽略。
