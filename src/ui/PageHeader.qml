// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

import org.kde.tasks
import org.kde.tasks.models

RowLayout {
    id: pageHeader

    Layout.fillWidth: true
    spacing: 0

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

        QQC2.ToolTip.visible: hoverHandler.hovered && TasksModel.completedTasks > 0
        QQC2.ToolTip.text: i18np("1 task completed", "%1 tasks completed", TasksModel.completedTasks)
        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
    }
}
