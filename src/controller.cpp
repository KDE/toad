// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <QQuickWindow>

#include <KConfig>
#include <KConfigGroup>
#include <KWindowConfig>

#include "controller.h"

Controller::Controller(QObject *parent)
    : QObject(parent)
{
}

Controller::~Controller()
{
}

void Controller::restoreWindowGeometry(QQuickWindow *window)
{
    KConfig dataResource(QStringLiteral("data"), KConfig::SimpleConfig, QStandardPaths::AppDataLocation);
    KConfigGroup windowGroup(&dataResource, "Window");
    KWindowConfig::restoreWindowSize(window, windowGroup);
    KWindowConfig::restoreWindowPosition(window, windowGroup);
}

void Controller::saveWindowGeometry(QQuickWindow *window)
{
    KConfig dataResource(QStringLiteral("data"), KConfig::SimpleConfig, QStandardPaths::AppDataLocation);
    KConfigGroup windowGroup(&dataResource, "Window");
    KWindowConfig::saveWindowPosition(window, windowGroup);
    KWindowConfig::saveWindowSize(window, windowGroup);
    dataResource.sync();
}
