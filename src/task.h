#pragma once

#include <QJsonObject>
#include <QString>

class Task
{
public:
    Task(QString title, bool checked);
    Task();

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
