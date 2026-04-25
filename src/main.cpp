#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "AppEventFilter.h"
#include "AppViewModel.h"
#include "EventViewModel.h"
#include "TodoListModel.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("Material"));

    AppViewModel appViewModel;
    EventViewModel eventViewModel;
    TodoListModel todoListModel;
    AppEventFilter appEventFilter(&eventViewModel);
    app.installEventFilter(&appEventFilter);

    QQmlApplicationEngine engine;

    // QtWidget 对照:
    // QWidget 常把状态直接放在控件里; QML 推荐把状态放进 QObject/ViewModel,
    // 再通过属性绑定让界面自动刷新。
    engine.rootContext()->setContextProperty(QStringLiteral("appVM"), &appViewModel);
    engine.rootContext()->setContextProperty(QStringLiteral("eventVM"), &eventViewModel);
    engine.rootContext()->setContextProperty(QStringLiteral("todoModel"), &todoListModel);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}
