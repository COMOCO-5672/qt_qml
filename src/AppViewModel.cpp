#include "AppViewModel.h"

AppViewModel::AppViewModel(QObject *parent)
    : QObject(parent)
    , m_userName(QStringLiteral("QML Learner"))
{
}

QString AppViewModel::userName() const
{
    return m_userName;
}

void AppViewModel::setUserName(const QString &userName)
{
    if (m_userName == userName) {
        return;
    }

    m_userName = userName;
    emit userNameChanged();
    emitStatusChanged();
}

int AppViewModel::count() const
{
    return m_count;
}

void AppViewModel::setCount(int count)
{
    if (m_count == count) {
        return;
    }

    m_count = count;
    emit countChanged();
    emitStatusChanged();
}

bool AppViewModel::busy() const
{
    return m_busy;
}

void AppViewModel::setBusy(bool busy)
{
    if (m_busy == busy) {
        return;
    }

    m_busy = busy;
    emit busyChanged();
    emitStatusChanged();
}

QString AppViewModel::statusText() const
{
    return QStringLiteral("%1 clicked %2 time(s)%3")
        .arg(m_userName)
        .arg(m_count)
        .arg(m_busy ? QStringLiteral(" - busy") : QString());
}

void AppViewModel::increase()
{
    setCount(m_count + 1);
}

void AppViewModel::reset()
{
    setCount(0);
    setBusy(false);
}

QString AppViewModel::greet(const QString &prefix) const
{
    return QStringLiteral("%1, %2").arg(prefix, m_userName);
}

void AppViewModel::emitStatusChanged()
{
    emit statusTextChanged();
}
