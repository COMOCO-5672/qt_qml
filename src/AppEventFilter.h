#pragma once

#include <QObject>

class EventViewModel;

class AppEventFilter : public QObject
{
    Q_OBJECT

public:
    explicit AppEventFilter(EventViewModel *eventViewModel, QObject *parent = nullptr);

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    EventViewModel *m_eventViewModel = nullptr;
};
