// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-FileCopyrightText: 2025 Mark Penner <mrp@markpenner.space>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include "config.h"
#include "task.h"

#include <QAbstractListModel>
#include <QQmlEngine>

#include <memory>

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
    Q_INVOKABLE void clearCompleted();

    Q_INVOKABLE void updatePath();
    Q_INVOKABLE bool saveAs(const QUrl &url);

    [[nodiscard]] int completedTasks() const
    {
        return std::count_if(m_tasks.constBegin(), m_tasks.constEnd(), [](const Task &t) {
            return t.checked();
        });
    }
    Q_SIGNAL void completedTasksChanged();

protected:
    bool saveTasks() const;
    bool loadTasks();

private:
    QList<Task> m_tasks;
    QUrl m_url;
    std::unique_ptr<Config> m_config;

    // helper function to convert URL to string
    QString getPath(const QUrl &url) const
    {
        return url.isLocalFile() ? url.toLocalFile() : url.toString();
    }
};
