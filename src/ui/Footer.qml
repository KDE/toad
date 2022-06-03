// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

import org.kde.tasks 1.0

Kirigami.ActionTextField {
    id: control

    required property TasksModel tasksModel
    property bool searching: page.searching

    onSearchingChanged: {
        if (page.searching) {
            forceActiveFocus()

            if (text == "/") {
                return
            }
            text = text.length <= 0 ? "/" : `/${text}`
        } else {
            text = text.slice(1)
        }
    }

    placeholderText: i18n("Type the new task's title here…")

    function addTask() {
        if (page.searching) {
            return
        }
        if (text.length > 0 && text.trim()) {
            control.tasksModel.add(text)
        }
        text = ""
    }

    rightActions: Kirigami.Action {
        id: rightAction
        icon.name: "list-add"
        visible: control.text.length > 0
        tooltip: i18n("Add Task")
        onTriggered: control.addTask()
    }
    onAccepted: control.addTask()
    onTextChanged: {
        if (text.startsWith("/")) {
            page.searching = true
            rightAction.visible = false
            page.currentSearchText = text
        } else {
            page.searching = false
            rightAction.visible = true
        }
    }

    background: Rectangle {
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View
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
