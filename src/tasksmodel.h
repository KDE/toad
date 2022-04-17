#pragma once

#include <QAbstractListModel>

class Task
{
public:
    Task(QString title, bool checked)
    {
        m_title = title;
        m_checked = checked;
    }

    QString title()
    {
        return m_title;
    }

    bool isChecked()
    {
        return m_checked;
    }

    void setChecked(bool checked)
    {
        m_checked = checked;
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

    Q_INVOKABLE void setChecked(int index, bool checked);

    Q_INVOKABLE void add(const QString &title);
    Q_INVOKABLE void remove(const int &index);

private:
    QList<Task> m_tasks;
};
