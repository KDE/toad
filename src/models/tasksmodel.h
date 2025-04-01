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

    // set location from a string: converts the string to a url and calls the setLocation that takes a url
    Q_INVOKABLE bool setLocation(const QString &stringurl);
    Q_INVOKABLE bool setLocation(const QUrl &url = QUrl());

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
    QUrl m_url = QUrl();
    std::unique_ptr<Config> m_config;

    // helper function to convert URL to string
    QString getPath(const QUrl &url) const
    {
        return url.isLocalFile() ? url.toLocalFile() : url.toString();
    }
};
