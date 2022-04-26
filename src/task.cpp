#include "task.h"

Task::Task(QString title, bool checked)
{
    m_title = title;
    m_checked = checked;
}

Task::Task()
{

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
    task.setTitle(obj.value(QStringLiteral("title")).toString());
    task.setChecked(obj.value(QStringLiteral("checked")).toBool());

    return task;
}

QJsonObject Task::toJson() const
{
    return {
        {QStringLiteral("title"), m_title},
        {QStringLiteral("checked"), m_checked}
    };
}
