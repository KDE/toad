/*
    SPDX-License-Identifier: GPL-2.0-or-later
    SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
*/

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>

#include "about.h"
#include "version-tasks.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#include "tasksconfig.h"

#include "tasksmodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setApplicationName(QStringLiteral("tasks"));

    KAboutData aboutData(
                         // The program name used internally.
                         QStringLiteral("tasks"),
                         // A displayable program name string.
                         i18nc("@title", "Tasks"),
                         // The program version string.
                         QStringLiteral(TASKS_VERSION_STRING),
                         // Short description of what the app does.
                         i18n("Application Description"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18n("(c) 2022"));
    aboutData.addAuthor(i18nc("@info:credit", "AUTHOR"), i18nc("@info:credit", "Author Role"), QStringLiteral("kinofhek@gmail.com"), QStringLiteral("https://yourwebsite.com"));
    KAboutData::setApplicationData(aboutData);

    QQmlApplicationEngine engine;

    auto config = tasksConfig::self();

    qmlRegisterSingletonInstance("org.kde.tasks", 1, 0, "Config", config);

    AboutType about;
    qmlRegisterSingletonInstance("org.kde.tasks", 1, 0, "AboutType", &about);

    qmlRegisterType<TasksModel>("org.kde.tasks", 1, 0, "TasksModel");

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
