// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

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

    Loader {
        active: !Kirigami.Settings.isMobile
        source: Qt.resolvedUrl("qrc:/GlobalMenu.qml")
    }

    pageStack.initialPage: Kirigami.Page {
        id: page

        padding: 0
        titleDelegate: RowLayout {
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

        QQC2.ScrollView {
            anchors.fill: parent

            ListView {
                id: list
                model: TasksModel { id: tasksModel }
                delegate: Kirigami.AbstractListItem {
                    id: taskItem

                    activeBackgroundColor: "transparent"
                    activeTextColor: Kirigami.Theme.textColor
                    separatorVisible: false

                    implicitHeight: titleText.implicitHeight

                    RowLayout {
                        QQC2.CheckBox {
                            checked: model.checked
                            onToggled: {
                                model.checked = !model.checked
                            }
                        }

                        QQC2.TextField {
                            id: titleText
                            Layout.fillWidth: true

                            property string fullText: model.title

                            background: Item {}

                            horizontalAlignment: Text.AlignLeft
                            text: metrics.elidedText
                            readOnly: model.checked

                            font.strikeout: model.checked
                            opacity: model.checked ? 0.5 : 1

                            onEditingFinished: {
                                model.title = text
                            }

                            TextMetrics {
                                id: metrics
                                font: titleText.font
                                text: titleText.fullText
                                elide: Qt.ElideRight
                                elideWidth: titleText.width - Kirigami.Units.gridUnit
                            }
                        }

                        QQC2.ToolButton {
                            id: removeButton
                            Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.5)
                            icon.name: "entry-delete"
                            opacity: taskItem.hovered ? 1 : 0
                            onClicked: {
                                tasksModel.remove(index)
                            }
                        }
                    }

                    QQC2.ToolTip.visible: titleText.fullText != metrics.elidedText && taskItem.hovered
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
            placeholderText: i18n("Type the new task's title here…")
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
                tooltip: i18n("Add Task")
                onTriggered: textField.addTask()
            }
            onAccepted: textField.addTask()
        }
    }
}
