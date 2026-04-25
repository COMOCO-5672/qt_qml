#pragma once

#include <QObject>
#include <QString>

class AppViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(bool busy READ busy WRITE setBusy NOTIFY busyChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)

public:
    explicit AppViewModel(QObject *parent = nullptr);

    QString userName() const;
    void setUserName(const QString &userName);

    int count() const;
    void setCount(int count);

    bool busy() const;
    void setBusy(bool busy);

    QString statusText() const;

    Q_INVOKABLE void increase();
    Q_INVOKABLE void reset();
    Q_INVOKABLE QString greet(const QString &prefix) const;

signals:
    void userNameChanged();
    void countChanged();
    void busyChanged();
    void statusTextChanged();

private:
    void emitStatusChanged();

    QString m_userName;
    int m_count = 0;
    bool m_busy = false;
};
