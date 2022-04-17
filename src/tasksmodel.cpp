#include "tasksmodel.h"

TasksModel::TasksModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

QHash<int, QByteArray> TasksModel::roleNames() const
{
    return {
        {Roles::TitleRole, QByteArrayLiteral("title")},
        {Roles::CheckedRole, QByteArrayLiteral("checked")}
    };
}

QVariant TasksModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tasks.count()) {
        return {};
    }

    auto task = m_tasks.at(index.row());

    switch (role) {
    case Roles::TitleRole:
        return task.title();
    case Roles::CheckedRole:
        return task.isChecked();
    }

    return {};
}

int TasksModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_tasks.size();
}

void TasksModel::setChecked(int index, bool checked)
{
    beginInsertRows({}, index, index);

    auto task = m_tasks.at(index);
    task.setChecked(checked);

    endInsertRows();
}

void TasksModel::add(const QString &title)
{
    Task t(title, false);

    beginInsertRows(QModelIndex(), m_tasks.count(), m_tasks.count());

    m_tasks.append(t);

    endInsertRows();
}

void TasksModel::remove(const int &index)
{
    if (index < 0 || index > m_tasks.count()) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);

    m_tasks.removeAt(index);

    endRemoveRows();
}
