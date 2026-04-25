#include "EventViewModel.h"

#include <QTime>

EventViewModel::EventViewModel(QObject *parent)
    : QObject(parent)
{
    pushLine(QStringLiteral("事件日志已启动"));
}

QString EventViewModel::lastEvent() const
{
    return m_lines.isEmpty() ? QString() : m_lines.last();
}

QString EventViewModel::eventLog() const
{
    return m_lines.join(QLatin1Char('\n'));
}

int EventViewModel::eventCount() const
{
    return m_lines.size();
}

void EventViewModel::recordEvent(const QString &source, const QString &detail)
{
    pushLine(QStringLiteral("[%1] %2: %3")
                 .arg(QTime::currentTime().toString(QStringLiteral("HH:mm:ss")))
                 .arg(source, detail));
}

void EventViewModel::clear()
{
    if (m_lines.isEmpty()) {
        return;
    }

    m_lines.clear();
    emit lastEventChanged();
    emit eventLogChanged();
    emit eventCountChanged();
}

void EventViewModel::pushLine(const QString &line)
{
    m_lines.push_back(line);
    while (m_lines.size() > 30) {
        m_lines.pop_front();
    }

    emit lastEventChanged();
    emit eventLogChanged();
    emit eventCountChanged();
}
