// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QJsonObject>
#include <QString>

class Task
{
public:
    Task(QString title, bool checked);

    QString title();
    bool checked();

    void setTitle(const QString &title);
    void setChecked(const bool &checked);

    static Task fromJson(const QJsonObject &obj);
    QJsonObject toJson() const;

private:
    QString m_title;
    bool m_checked;
};
