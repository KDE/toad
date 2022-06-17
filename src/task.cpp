// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "task.h"

Task::Task(QString title, bool checked)
{
    m_title = title;
    m_checked = checked;
}

QString Task::title()
{
    return m_title;
}

bool Task::checked()
{
    return m_checked;
}

void Task::setTitle(const QString &title)
{
    m_title = title;
}

void Task::setChecked(const bool &checked)
{
    m_checked = checked;
}

Task Task::fromJson(const QJsonObject &obj)
{
    Task task(obj.value(QStringLiteral("title")).toString(), obj.value(QStringLiteral("checked")).toBool());

    return task;
}

QJsonObject Task::toJson() const
{
    return {
        {QStringLiteral("title"), m_title},
        {QStringLiteral("checked"), m_checked}
    };
}
