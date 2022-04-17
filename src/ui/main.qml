// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

import org.kde.tasks 1.0

// add global menu

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Tasks")

    width: Kirigami.Units.gridUnit * 26
    height: Kirigami.Units.gridUnit * 36
    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: true

        actions: [
            Kirigami.Action {
                text: i18n("About Tasks")
                icon.name: "help-about"
                onTriggered: pageStack.layers.push("About.qml")
                enabled: pageStack.layers.depth <= 1
            }
        ]
    }

    pageStack.initialPage: Kirigami.Page {
        id: page

        padding: 0

        QQC2.ScrollView {
            anchors.fill: parent

            ListView {
                id: list
                 model: TasksModel { id: tasksModel }
                delegate: Kirigami.CheckableListItem {
                    id: taskItem

                    label: model.title
                    separatorVisible: false
                    reserveSpaceForIcon: false
                    checkable: false

                    labelItem.font.strikeout: model.checked
                    labelItem.opacity: model.checked ? 0.5 : 1

                    checked: model.checked
                    action: Kirigami.Action {
                        onTriggered: {
                            model.checked = !model.checked
                        }
                    }

                    trailing: QQC2.ToolButton {
                        icon.name: "entry-delete"
                        visible: taskItem.hovered
                        onClicked: {
                            tasksModel.remove(index)
                        }
                    }

                    QQC2.ToolTip.visible: labelItem.truncated && taskItem.hovered
                    QQC2.ToolTip.text: model.title
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                }

                Kirigami.PlaceholderMessage {
                    visible: list.count <= 0
                    anchors.centerIn: parent
                    text: i18n("Empty List")
                    explanation: i18n("Type the new task below.")
                }
            }
        }

        footer: Kirigami.ActionTextField {
            id: textField
            placeholderText: i18n("Create Task…")
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

            function addTask() {
                if (text.length > 0 && text.trim()) {
                    tasksModel.add(text)
                }
                text = ""
            }

            rightActions: Kirigami.Action {
                icon.name: "list-add"
                tooltip: i18n("Create Task")
                onTriggered: textField.addTask()
            }
            onAccepted: textField.addTask()
        }
    }
}
