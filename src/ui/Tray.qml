// SPDX-FileCopyrightText: 2024 Thiago Sueto <herzenschein@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import Qt.labs.platform

SystemTrayIcon {
    id: "tray"
    visible: false
    icon.name: "org.kde.tasks"
    onActivated: toggleVisibility()
    menu: Menu {
        MenuItem {
            text: "Show/hide Tasks"
            onTriggered: toggleVisibility()
        }
        MenuItem {
            text: "Quit"
            onTriggered: Qt.quit()
        }
    }

    function toggleVisibility() {
        if (applicationWindow().visible) {
            applicationWindow().hide()
        } else {
            applicationWindow().show()
            applicationWindow().raise()
            applicationWindow().requestActivate()
        }
    }
}
