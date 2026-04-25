#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class EventViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastEvent READ lastEvent NOTIFY lastEventChanged)
    Q_PROPERTY(QString eventLog READ eventLog NOTIFY eventLogChanged)
    Q_PROPERTY(int eventCount READ eventCount NOTIFY eventCountChanged)

public:
    explicit EventViewModel(QObject *parent = nullptr);

    QString lastEvent() const;
    QString eventLog() const;
    int eventCount() const;

    Q_INVOKABLE void recordEvent(const QString &source, const QString &detail);
    Q_INVOKABLE void clear();

signals:
    void lastEventChanged();
    void eventLogChanged();
    void eventCountChanged();

private:
    void pushLine(const QString &line);

    QStringList m_lines;
};
