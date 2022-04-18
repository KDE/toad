// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

Kirigami.ActionTextField {
    id: control

    placeholderText: i18n("Type the new task's title here…")

    function addTask() {
        if (text.length > 0 && text.trim()) {
            tasksModel.add(text)
        }
        text = ""
    }

    rightActions: Kirigami.Action {
        icon.name: "list-add"
        tooltip: i18n("Add Task")
        onTriggered: control.addTask()
    }
    onAccepted: control.addTask()

    background: Rectangle {
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        color: Kirigami.Theme.backgroundColor
        Kirigami.Separator {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }
    }
}
