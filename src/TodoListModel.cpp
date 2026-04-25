#include "TodoListModel.h"

TodoListModel::TodoListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_items = {
        {QStringLiteral("认识 Rectangle/Text/Button"), true},
        {QStringLiteral("练习属性绑定和信号"), false},
        {QStringLiteral("把 C++ ViewModel 暴露给 QML"), false}
    };
}

int TodoListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }

    return m_items.size();
}

QVariant TodoListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size()) {
        return {};
    }

    const TodoItem &item = m_items.at(index.row());
    switch (role) {
    case TitleRole:
        return item.title;
    case DoneRole:
        return item.done;
    default:
        return {};
    }
}

bool TodoListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size()) {
        return false;
    }

    TodoItem &item = m_items[index.row()];
    switch (role) {
    case TitleRole:
        item.title = value.toString();
        break;
    case DoneRole:
        item.done = value.toBool();
        break;
    default:
        return false;
    }

    emit dataChanged(index, index, {role});
    return true;
}

Qt::ItemFlags TodoListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }

    return Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
}

QHash<int, QByteArray> TodoListModel::roleNames() const
{
    return {
        {TitleRole, "title"},
        {DoneRole, "done"}
    };
}

void TodoListModel::addTodo(const QString &title)
{
    const QString trimmed = title.trimmed();
    if (trimmed.isEmpty()) {
        return;
    }

    const int row = m_items.size();
    beginInsertRows(QModelIndex(), row, row);
    m_items.push_back({trimmed, false});
    endInsertRows();
}

void TodoListModel::removeTodo(int row)
{
    if (row < 0 || row >= m_items.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    m_items.removeAt(row);
    endRemoveRows();
}

void TodoListModel::toggleDone(int row)
{
    if (row < 0 || row >= m_items.size()) {
        return;
    }

    const QModelIndex itemIndex = index(row, 0);
    setData(itemIndex, !m_items.at(row).done, DoneRole);
}
