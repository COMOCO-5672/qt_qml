#pragma once

#include <QAbstractListModel>
#include <QVector>

struct TodoItem
{
    QString title;
    bool done = false;
};

class TodoListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum TodoRoles {
        TitleRole = Qt::UserRole + 1,
        DoneRole
    };
    Q_ENUM(TodoRoles)

    explicit TodoListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addTodo(const QString &title);
    Q_INVOKABLE void removeTodo(int row);
    Q_INVOKABLE void toggleDone(int row);

private:
    QVector<TodoItem> m_items;
};
