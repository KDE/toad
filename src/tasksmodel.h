// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QAbstractListModel>
#include <QJsonObject>

#include "task.h"

class TasksModel : public QAbstractListModel
{
    Q_OBJECT

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
    Q_INVOKABLE void remove(const int &index);
    Q_INVOKABLE void clear();

protected:
    bool saveTasks() const;
    bool loadTasks();

private:
    QList<Task> m_tasks;
};
