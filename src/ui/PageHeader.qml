// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

import org.kde.tasks 1.0

RowLayout {
    id: pageHeader

    required property TasksModel tasksModel

    Layout.fillWidth: true
    spacing: 0

    Tray { id: tray }

    QQC2.Label {
        Layout.alignment: Qt.AlignLeft
        Layout.leftMargin: Kirigami.Units.largeSpacing
        text: {
            if (list.count == 0) {
                return ""
            } else {
                return page.searching ? i18np("1 result", "%1 results", list.count) : i18np("1 task", "%1 tasks", list.count)
            }
        }

        HoverHandler {
            id: hoverHandler
        }

        QQC2.ToolTip.visible: hoverHandler.hovered && pageHeader.tasksModel.completedTasks > 0
        QQC2.ToolTip.text: i18np("1 task completed", "%1 tasks completed", pageHeader.tasksModel.completedTasks)
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
    }

    Item {
        Layout.fillWidth: true
    }

    QQC2.ToolButton {
        text: i18n("Clear All")
        icon.name: "edit-clear-all"
        onClicked: pageHeader.tasksModel.clear()
        enabled: list.count > 0
    }

    QQC2.ToolButton {
        display: QQC2.AbstractButton.IconOnly
        action: Kirigami.Action {
            text: i18n("Search")
            icon.name: "search"
            checked: page.searching
            onTriggered: page.searching = !page.searching
            enabled: pageStack.layers.depth <= 1
        }

        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: text
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
    }

    QQC2.ToolButton {
        display: QQC2.AbstractButton.IconOnly
        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: text
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

        action: Kirigami.Action {
            text: i18n("Menu")
            icon.name: "open-menu-symbolic"
            onTriggered: menu.open()
        }

        QQC2.Menu {
            id: "menu"
            QQC2.MenuItem {
                action: Kirigami.Action {
                    text: i18n("About Tasks")
                    icon.name: "help-about"
                    shortcut: StandardKey.HelpContents
                    onTriggered: pageStack.layers.push("About.qml")
                    enabled: pageStack.layers.depth <= 1
                }
            }
            QQC2.MenuItem {
                checkable: true
                action: Kirigami.Action {
                    icon.name: "org.kde.tasks"
                    text: "Enable tray icon"}
                    onTriggered: tray.visible ? tray.hide() : tray.show()
            }
            QQC2.MenuItem {
                action: Kirigami.Action {
                    icon.name: "application-exit"
                    text: "Quit"
                    shortcut: StandardKey.Quit
                    onTriggered: Qt.quit()
                }
            }
        }
    }
}
