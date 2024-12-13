// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QAbstractListModel>
#include <QQmlEngine>

#include "task.h"

class TasksModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(int completedTasks READ completedTasks NOTIFY completedTasksChanged)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        CheckedRole
    };

    explicit TasksModel(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent) const final;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    Q_INVOKABLE void add(const QString &title);
    Q_INVOKABLE void remove(const QModelIndex &index);
    Q_INVOKABLE void clear();

    [[nodiscard]] int completedTasks() const
    {
        return m_completedTasks;
    }
    Q_SIGNAL void completedTasksChanged();

protected:
    bool saveTasks() const;
    bool loadTasks();

private:
    QList<Task> m_tasks;
    int m_completedTasks = 0;
};
