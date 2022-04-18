// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

RowLayout {
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
    }

    Item {
        Layout.fillWidth: true
    }

    QQC2.ToolButton {
        text: i18n("Clear Tasks")
        icon.name: "edit-clear-all"
        onClicked: tasksModel.clear()
        enabled: list.count > 0
    }

    QQC2.ToolButton {
        text: i18n("About Tasks")
        icon.name: "help-about"
        display: QQC2.AbstractButton.IconOnly
        onClicked: pageStack.layers.push("About.qml")
        enabled: pageStack.layers.depth <= 1
    }
}
