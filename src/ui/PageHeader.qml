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

    QQC2.Label {
        Layout.alignment: Qt.AlignLeft
        Layout.leftMargin: Kirigami.Units.largeSpacing
        text: {
            if (list.count == 0) {
                return ""
            } else {
                return i18np("1 task", "%1 tasks", list.count)
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
            text: i18n("Configure Tasks")
            icon.name: "settings-configure"
            shortcut: StandardKey.Preferences
            onTriggered: pageStack.layers.push("Settings.qml")
            enabled: pageStack.layers.depth <= 1
        }

        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: text
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
    }

    QQC2.ToolButton {
        display: QQC2.AbstractButton.IconOnly
        action: Kirigami.Action {
            text: i18n("About Tasks")
            icon.name: "help-about"
            shortcut: StandardKey.HelpContents
            onTriggered: pageStack.layers.push("About.qml")
            enabled: pageStack.layers.depth <= 1
        }

        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: text
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
    }
}
