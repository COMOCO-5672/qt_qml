#include "AppEventFilter.h"

#include "EventViewModel.h"

#include <QEvent>
#include <QKeyEvent>

AppEventFilter::AppEventFilter(EventViewModel *eventViewModel, QObject *parent)
    : QObject(parent)
    , m_eventViewModel(eventViewModel)
{
}

bool AppEventFilter::eventFilter(QObject *watched, QEvent *event)
{
    Q_UNUSED(watched)

    if (!m_eventViewModel || event->type() != QEvent::KeyPress) {
        return false;
    }

    const auto *keyEvent = static_cast<QKeyEvent *>(event);
    if (keyEvent->key() == Qt::Key_F2) {
        m_eventViewModel->recordEvent(QStringLiteral("C++ eventFilter"),
                                      QStringLiteral("捕获全局 F2，但不拦截"));
    } else if (keyEvent->key() == Qt::Key_Escape) {
        m_eventViewModel->recordEvent(QStringLiteral("C++ eventFilter"),
                                      QStringLiteral("捕获全局 Escape，但不拦截"));
    }

    return false;
}
