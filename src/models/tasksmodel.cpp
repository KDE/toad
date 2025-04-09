// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-FileCopyrightText: 2025 Mark Penner <mrp@markpenner.space>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include "tasksmodel.h"

#include "config.h"
#include "tasks_debug.h"

#include <QDir>
#include <QFile>
#include <QStandardPaths>

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
using namespace Qt::Literals::StringLiterals;

TasksModel::TasksModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_config(Config::self())
{
#ifndef Q_OS_ANDROID
    m_watcher = std::make_unique<KDirWatch>(this);
    connect(m_watcher.get(), &KDirWatch::dirty, this, &TasksModel::loadTasks);
    connect(m_watcher.get(), &KDirWatch::created, this, &TasksModel::loadTasks);
#endif
    setLocation();
}

QHash<int, QByteArray> TasksModel::roleNames() const
{
    return {
        {Roles::TitleRole, QByteArrayLiteral("title")},
        {Roles::CheckedRole, QByteArrayLiteral("checked")},
    };
}

QVariant TasksModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tasks.count()) {
        return {};
    }

    auto task = m_tasks.at(index.row());

    switch (role) {
    case Roles::TitleRole:
        return task.title();
    case Roles::CheckedRole:
        return task.checked();
    }

    return {};
}

int TasksModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_tasks.size();
}

bool TasksModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.row() < 0 || index.row() >= m_tasks.count()) {
        return false;
    }

    auto &task = m_tasks[index.row()];

    switch (role) {
    case Roles::CheckedRole:
        task.setChecked(value.toBool());
        Q_EMIT completedTasksChanged();
        break;
    case Roles::TitleRole:
        task.setTitle(value.toString());
        break;
    }

    Q_EMIT dataChanged(index, index, {role});

    saveTasks();

    return true;
}

void TasksModel::add(const QString &title)
{
    Task t(title, false);

    beginInsertRows(QModelIndex(), m_tasks.count(), m_tasks.count());
    m_tasks.append(t);
    endInsertRows();

    saveTasks();
}

void TasksModel::remove(const QModelIndex &index)
{
    const int row = index.row();
    if (row < 0 || row > m_tasks.count()) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);
    m_tasks.removeAt(row);
    endRemoveRows();
    Q_EMIT completedTasksChanged();

    saveTasks();
}

void TasksModel::clearCompleted()
{
    beginResetModel();
    m_tasks.removeIf([](const Task &t) {
        return t.checked();
    });
    endResetModel();
    Q_EMIT completedTasksChanged();

    saveTasks();
}

bool TasksModel::setLocation(const QString &stringurl)
{
    auto url = QUrl(stringurl);
    if (url.isRelative()) {
        // the string we got does not have a scheme, might be a local path
        url = QUrl::fromLocalFile(stringurl);
    }
    return setLocation(url);
}

bool TasksModel::setLocation(const QUrl &url)
{
    QUrl oldurl = m_url;
    auto filename = "tasks.json"_L1;

    if (url.isValid() && !m_config->defaultLocation()) {
        if (!QFileInfo(getPath(url)).isDir()) {
            qCWarning(TASKS_LOG) << url << "is not a directory";
            return false;
        }
        m_url = QUrl(url.toString() + '/'_L1 + filename);
        // if the file exists, try to open it, otherwise try to save as
        if (QFile::exists(getPath(m_url))) {
            if (!loadTasks()) {
                m_url = oldurl;
                return false;
            }
        } else {
            if (!saveTasks()) {
                m_url = oldurl;
                return false;
            }
        }
    } else if (!m_config->defaultLocation() && !m_config->location().isEmpty()) {
        m_url = QUrl(m_config->location().toString() + '/'_L1 + filename);
    } else {
        // use default location
        m_url = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + '/'_L1 + filename);
    }

    if (!QFileInfo::exists(getPath(m_url))) {
        if (!QDir(getPath(m_url.adjusted(QUrl::RemoveFilename))).mkpath(u"."_s)) {
            qCWarning(TASKS_LOG) << "Failed to create path to" << m_url;
            m_url = oldurl;
            return false;
        }
        if (!saveTasks()) {
            m_url = oldurl;
            return false;
        }
    }

    if (m_url != oldurl) {
        loadTasks();
        m_config->setLocation(m_url.adjusted(QUrl::RemoveFilename | QUrl::StripTrailingSlash));
#ifndef Q_OS_ANDROID
        m_watcher->removeFile(getPath(oldurl));
        m_watcher->addFile(getPath(m_url));
#endif
    }
    return true;
}

bool TasksModel::saveTasks() const
{
    QFile outputFile(getPath(m_url));
    if (!outputFile.open(QIODevice::WriteOnly)) {
        qCWarning(TASKS_LOG) << "Failed to write to" << outputFile.fileName();
        return false;
    }

    QJsonArray tasksArray;
    std::transform(m_tasks.cbegin(), m_tasks.cend(), std::back_inserter(tasksArray), [](const Task &task) {
        return task.toJson();
    });

    const QJsonDocument document(QJsonObject{
        {QLatin1String("tasks"), tasksArray},
    });

    // truncate, since it seems that opening with Truncate on Android doesn't actually truncate the file?
    outputFile.resize(0);
    outputFile.write(document.toJson());
    qCDebug(TASKS_LOG) << "Wrote to file" << outputFile.fileName() << "(" << tasksArray.count() << "tasks" << ")";

    return true;
}

bool TasksModel::loadTasks()
{
    QFile inputFile(getPath(m_url));
    if (!inputFile.exists()) {
        return false;
    }

    if (!inputFile.open(QIODevice::ReadOnly)) {
        qCWarning(TASKS_LOG) << "Failed to read from" << inputFile.fileName();
        return false;
    }

    const auto tasksStorage = QJsonDocument::fromJson(inputFile.readAll()).object();

    const auto tasks = tasksStorage.value(QLatin1String("tasks")).toArray();

    beginResetModel();
    m_tasks.clear();
    std::transform(tasks.cbegin(), tasks.cend(), std::back_inserter(m_tasks), [](const QJsonValue &task) {
        return Task::fromJson(task.toObject());
    });
    endResetModel();

    qCDebug(TASKS_LOG) << "loaded from file:" << m_tasks.count() << m_url;

    return true;
}
