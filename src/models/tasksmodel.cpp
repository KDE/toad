// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "tasksmodel.h"
#include "tasks_debug.h"

#include <QDir>
#include <QFile>
#include <QStandardPaths>

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

TasksModel::TasksModel(QObject *parent)
    : QAbstractListModel(parent)
{
    loadTasks();
}

QHash<int, QByteArray> TasksModel::roleNames() const
{
    return {
        {Roles::TitleRole, QByteArrayLiteral("title")},
        {Roles::CheckedRole, QByteArrayLiteral("checked")},
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
        return task.checked();
    }

    return {};
}

int TasksModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_tasks.size();
}

bool TasksModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.row() < 0 || index.row() >= m_tasks.count()) {
        return false;
    }

    auto &task = m_tasks[index.row()];

    switch (role) {
    case Roles::CheckedRole:
        task.setChecked(value.toBool());
        Q_EMIT completedTasksChanged();
        break;
    case Roles::TitleRole:
        task.setTitle(value.toString());
        break;
    }

    Q_EMIT dataChanged(index, index, {role});

    saveTasks();

    return true;
}

void TasksModel::add(const QString &title)
{
    Task t(title, false);

    beginInsertRows(QModelIndex(), m_tasks.count(), m_tasks.count());
    m_tasks.append(t);
    endInsertRows();

    saveTasks();
}

void TasksModel::remove(const QModelIndex &index)
{
    const int row = index.row();
    if (row < 0 || row > m_tasks.count()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    m_tasks.removeAt(row);
    endRemoveRows();
    Q_EMIT completedTasksChanged();

    saveTasks();
}

void TasksModel::clearCompleted()
{
    beginResetModel();
    m_tasks.removeIf([](const Task &t) {
        return t.checked();
    });
    endResetModel();
    Q_EMIT completedTasksChanged();

    saveTasks();
}

bool TasksModel::saveTasks() const
{
    const QString outputDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    QFile outputFile(outputDir + QStringLiteral("/tasks.json"));
    if (!QDir(outputDir).mkpath(QStringLiteral("."))) {
        qCWarning(TASKS_LOG) << "Destdir doesn't exist and I can't create it: " << outputDir;
        return false;
    }
    if (!outputFile.open(QIODevice::WriteOnly)) {
        qCWarning(TASKS_LOG) << "Failed to write tabs to disk";
    }

    QJsonArray tasksArray;
    std::transform(m_tasks.cbegin(), m_tasks.cend(), std::back_inserter(tasksArray), [](const Task &task) {
        return task.toJson();
    });

    qCDebug(TASKS_LOG) << "Wrote to file" << outputFile.fileName() << "(" << tasksArray.count() << "tasks" << ")";

    const QJsonDocument document(QJsonObject{
        {QLatin1String("tasks"), tasksArray},
    });

    outputFile.write(document.toJson());

    return true;
}

bool TasksModel::loadTasks()
{
    beginResetModel();

    const QString input = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QStringLiteral("/tasks.json");

    QFile inputFile(input);
    if (!inputFile.exists()) {
        return false;
    }

    if (!inputFile.open(QIODevice::ReadOnly)) {
        qCWarning(TASKS_LOG) << "Failed to load tabs from disk";
    }

    const auto tasksStorage = QJsonDocument::fromJson(inputFile.readAll()).object();
    m_tasks.clear();

    const auto tasks = tasksStorage.value(QLatin1String("tasks")).toArray();

    std::transform(tasks.cbegin(), tasks.cend(), std::back_inserter(m_tasks), [](const QJsonValue &task) {
        return Task::fromJson(task.toObject());
    });

    qCDebug(TASKS_LOG) << "loaded from file:" << m_tasks.count() << input;

    endResetModel();

    return true;
}
