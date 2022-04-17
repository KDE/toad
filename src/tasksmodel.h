#pragma once

#include <QAbstractListModel>
#include <QJsonObject>

class Task
{
public:
    Task(QString title, bool checked)
    {
        m_title = title;
        m_checked = checked;
    }

    Task() = default;

    QString title()
    {
        return m_title;
    }

    bool isChecked()
    {
        return m_checked;
    }

    void setTitle(const QString &title)
    {
        m_title = title;
    }

    void setChecked(const bool &checked)
    {
        m_checked = checked;
    }

    static Task fromJson(const QJsonObject &obj)
    {
        Task task;
        task.setTitle(obj.value(QStringLiteral("title")).toString());
        task.setChecked(obj.value(QStringLiteral("checked")).toBool());
        
        return task;
    }

    QJsonObject toJson() const
    {
        return {
            {QStringLiteral("title"), m_title},
            {QStringLiteral("checked"), m_checked},
        };
    }

private:
    QString m_title;
    bool m_checked;
};

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

    Q_INVOKABLE void add(const QString &title);
    Q_INVOKABLE void remove(const int &index);

protected:
    bool saveTasks() const;
    bool loadTasks();

private:
    QList<Task> m_tasks;
};
