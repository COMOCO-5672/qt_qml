# QML / JS 发布与源码保护

这份文档回答一个现实问题: QML/JS 发布后会不会被用户看到？能不能加密？

结论先说:

```text
QRC、qmlcachegen、Qt Quick Compiler 都不是严格意义的加密。
```

它们可以减少源码散落、提升启动性能、增加直接查看成本，但不能保护真正敏感的业务逻辑。授权、密钥、核心算法、协议细节不要放在 QML/JS。

## 1. 最低要求: 不发布 QML/JS 散文件

本项目已经把 QML/JS 放进 Qt Resource System:

```xml
<!-- qml.qrc -->
<RCC>
    <qresource prefix="/">
        <file>qml/main.qml</file>
        <file>qml/pages/ControlsPage.qml</file>
        <file>qml/js/mathTools.js</file>
    </qresource>
</RCC>
```

C++ 从 qrc 加载:

```cpp
engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
```

这样发布目录里不需要带你的项目 `.qml` / `.js` 文件。

## 2. CMake / Qt 5 当前项目发布

当前项目是 Qt 5.15 兼容写法，构建 Release:

```powershell
cmake -S . -B build-release -DCMAKE_BUILD_TYPE=Release
cmake --build build-release --config Release
```

Visual Studio 生成器下通常是:

```powershell
.\build-release\Release\QmlQuickStart.exe
```

Windows 部署 Qt 依赖:

```powershell
windeployqt --release .\build-release\Release\QmlQuickStart.exe
```

检查发布目录时:

- 可以出现 Qt 自带 QML 模块文件，例如 `QtQuick`、`QtQuick.2`、`QtQuick.Controls.2`。
- 不应该出现你项目自己的 `qml/pages/*.qml`、`qml/js/*.js` 散文件。

## 3. Qt 5 的 Qt Quick Compiler

如果是 qmake 项目，可使用:

```qmake
CONFIG += qtquickcompiler
```

CMake + Qt 5 是否可用取决于安装版本和商业/开源配置。不要为了“加密”强依赖它。当前项目更重要的是先用 qrc 避免散文件。

## 4. Qt 6 推荐方式

Qt 6 项目推荐用:

```cmake
qt_add_qml_module(app
    URI MyApp
    VERSION 1.0
    QML_FILES
        qml/main.qml
        qml/pages/ControlsPage.qml
)
```

Qt 6 构建系统会配合 QML Module、资源系统、qmlcachegen/qmltc 做更多编译期检查和 AOT 优化。

但仍然要记住:

```text
AOT 编译不是安全边界。
```

## 5. 真正敏感内容怎么处理

不要放 QML/JS:

- 许可证校验核心
- 私钥、token、固定密钥
- 加密算法关键参数
- 收费功能判断核心
- 商业算法
- 私有协议细节

推荐:

- 放 C++，并减少导出符号。
- 放服务端，由客户端请求结果。
- 本地授权使用成熟授权方案，不把全部校验逻辑放 UI 层。
- Release 关闭 QML debugging/profiling。
- 对二进制做签名、完整性校验、反篡改时要按安全产品思路设计。

## 6. 发布检查清单

发布前检查:

- `engine.load()` 使用 `qrc:/` 或 `qrc:///`。
- 自己项目的 QML/JS 都在 qrc 或 Qt 6 QML module 中。
- Release 包没有携带项目源码目录。
- 没有把密钥、授权、核心算法写在 QML/JS。
- 没有开启 QML 调试端口。
- 用 `windeployqt` 后人工检查一次发布目录。

## 7. 和 QtWidget 的类比

QtWidget 的 UI 通常编译在 C++ 二进制里，但仍然可能被逆向。

QML 的额外风险是:

```text
UI 和 JS 逻辑更接近文本资源，更容易被直接查看或提取。
```

所以 QML 项目更需要分层:

```text
QML = View
C++ ViewModel/Service = 逻辑
Server = 真正敏感规则
```
