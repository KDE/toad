// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QtQml>

#include "about.h"
#include "version-tasks.h"
#include <KAboutData>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KDBusService>

constexpr auto APPLICATION_ID = "org.kde.tasks";

#include "config.h"

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
                         i18n("Simple task list"),
                         // The license this code is released under.
                         KAboutLicense::GPL,
                         // Copyright Statement.
                         i18n("© 2022"));
    aboutData.addAuthor(i18nc("@info:credit", "Felipe Kinoshita"), i18nc("@info:credit", "Author"), QStringLiteral("kinofhek@gmail.com"), QStringLiteral("https://fhek.gitlab.io"));
    aboutData.setBugAddress("https://invent.kde.org/utilities/toad/-/issues/new");
    KAboutData::setApplicationData(aboutData);
    QGuiApplication::setWindowIcon(QIcon::fromTheme(QStringLiteral("org.kde.tasks")));

    QQmlApplicationEngine engine;

    auto config = Config::self();

    qmlRegisterSingletonInstance(APPLICATION_ID, 1, 0, "Config", config);

    AboutType about;
    qmlRegisterSingletonInstance(APPLICATION_ID, 1, 0, "AboutType", &about);

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

    KDBusService service(KDBusService::Unique);

    return app.exec();
}
