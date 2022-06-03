// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <QIcon>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>
#include <QQuickStyle>
#include <QQuickWindow>

#include "about.h"
#include "version-tasks.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>

#ifndef Q_OS_ANDROID
#include <QApplication>

#include <KDBusService>
#include <KWindowSystem>
#else
#include <QGuiApplication>
#endif

constexpr auto APPLICATION_ID = "org.kde.tasks";

#include "config.h"
#include "controller.h"
#include "tasksmodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#ifndef Q_OS_ANDROID
    QApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
#else
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("org.kde.breeze"));
#endif
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
                         i18n("Simple task list"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18n("© 2022 Felipe Kinoshita"));
    aboutData.addAuthor(i18nc("@info:credit", "Felipe Kinoshita"), i18nc("@info:credit", "Author"), QStringLiteral("kinofhek@gmail.com"), QStringLiteral("https://fhek.gitlab.io"));
    aboutData.setBugAddress("https://invent.kde.org/utilities/toad/-/issues/new");
    KAboutData::setApplicationData(aboutData);
    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.tasks")));

    QQmlApplicationEngine engine;

    auto config = Config::self();

    qmlRegisterSingletonInstance(APPLICATION_ID, 1, 0, "Config", config);

    AboutType about;
    qmlRegisterSingletonInstance(APPLICATION_ID, 1, 0, "AboutType", &about);

    Controller controller;
    qmlRegisterSingletonInstance(APPLICATION_ID, 1, 0, "Controller", &controller);

    qmlRegisterUncreatableType<TasksModel>(APPLICATION_ID, 1,0 , "TasksModel", QStringLiteral("Must be created from C++"));
    auto tasksModel = new TasksModel(qApp);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.setInitialProperties(
        /* QMap<QString, QVariant> or QVariantMap */ {
            { "tasksModel", QVariant::fromValue(tasksModel) }
        }
    );
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

#ifndef Q_OS_ANDROID
    KDBusService service(KDBusService::Unique);

    // Raise window when new instance is requested e.g middle click on taskmanager
    QObject::connect(&service, &KDBusService::activateRequested, &engine, [&engine](const QStringList & /*arguments*/, const QString & /*workingDirectory*/) {
        const auto rootObjects = engine.rootObjects();
        for (auto obj : rootObjects) {
            auto view = qobject_cast<QQuickWindow *>(obj);
            if (view) {
                KWindowSystem::updateStartupId(view);
                KWindowSystem::activateWindow(view);
                return;
            }
        }
    });
#endif

    // Restore window size and position
    const auto rootObjects = engine.rootObjects();
    for (auto obj : rootObjects) {
        auto view = qobject_cast<QQuickWindow *>(obj);
        if (view) {
            if (view->isVisible()) {
                controller.restoreWindowGeometry(view);
            }
            break;
        }
    }

    return app.exec();
}
