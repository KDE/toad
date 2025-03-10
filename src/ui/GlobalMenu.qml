// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import Qt.labs.platform 1.1 as Labs
import org.kde.kirigami 2.19 as Kirigami
import org.kde.coreaddons as KCoreAddons

import org.kde.tasks
import org.kde.tasks.models

Labs.MenuBar {
    id: menuBar

    Labs.Menu {
        title: i18nc("@menu", "File")

        Labs.MenuItem {
            text: i18nc("@menu-action", "Quit")
            icon.name: "application-exit"
            onTriggered: Qt.quit()
        }
    }

    Labs.Menu {
        title: i18nc("@menu", "Edit")

        Labs.MenuItem {
            text: i18nc("@menu-action", "Clear Completed")
            icon.name: "edit-clear-all"
            onTriggered: TasksModel.clearCompleted()
            enabled: TasksModel.completedTasks > 0
        }
    }

    Labs.Menu {
        title: i18nc("@menu", "Help")

        Labs.MenuItem {
            text: i18nc("@menu-action", "Report Bug…")
            icon.name: "tools-report-bug"
            onTriggered: Qt.openUrlExternally(KCoreAddons.AboutData.bugAddress);
        }

        Labs.MenuItem {
            text: i18nc("@menu-action", "About Tasks")
            icon.name: "help-about"
            onTriggered: pageStack.layers.push(aboutPage)
            enabled: pageStack.layers.depth <= 1
        }
    }
}
