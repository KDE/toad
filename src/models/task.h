// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <QJsonObject>
#include <QString>

class Task
{
public:
    explicit Task(const QString &title, bool checked);

    [[nodiscard]] QString title() const;
    [[nodiscard]] bool checked() const;

    void setTitle(const QString &title);
    void setChecked(const bool &checked);

    static Task fromJson(const QJsonObject &obj);
    [[nodiscard]] QJsonObject toJson() const;

private:
    QString m_title;
    bool m_checked;
};
