// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

import org.kde.tasks 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Tasks")

    required property TasksModel tasksModel

    width: Kirigami.Units.gridUnit * 26
    height: Kirigami.Units.gridUnit * 36
    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    Loader {
        active: !Kirigami.Settings.isMobile
        sourceComponent: GlobalMenu {
            tasksModel: root.tasksModel
        }
    }

    pageStack.initialPage: Kirigami.Page {
        id: page

        padding: 0
        titleDelegate: PageHeader {
            tasksModel: root.tasksModel
        }

        QQC2.ScrollView {
            anchors.fill: parent

            ListView {
                id: list
                interactive: contentHeight > height
                model: root.tasksModel
                delegate: Kirigami.AbstractListItem {
                    id: taskItem

                    activeBackgroundColor: "transparent"
                    activeTextColor: Kirigami.Theme.textColor
                    separatorVisible: false

                    implicitHeight: titleField.implicitHeight

                    RowLayout {
                        QQC2.CheckBox {
                            enabled: !titleField.visible
                            checked: model.checked
                            onToggled: model.checked = !model.checked
                        }

                        QQC2.Label {
                            id: titleLabel
                            Layout.fillWidth: true
                            Layout.preferredHeight: titleField.implicitHeight
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                            text: model.title
                            elide: Text.ElideRight

                            Behavior on opacity {
                                OpacityAnimator {
                                    duration: Kirigami.Units.longDuration
                                    easing.type: Easing.OutQuad
                                }
                            }

                            font.strikeout: model.checked
                            opacity: model.checked ? 0.5 : 1
                        }

                        QQC2.TextField {
                            id: titleField
                            visible: false
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                            text: model.title

                            horizontalAlignment: Text.AlignLeft
                            readOnly: model.checked

                            onEditingFinished: {
                                model.title = text
                                titleField.visible = false
                                titleLabel.visible = true
                            }
                        }

                        QQC2.ToolButton {
                            id: editButton
                            visible: !model.checked && !titleField.visible

                            Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.5)

                            icon.name: "entry-edit"
                            opacity: taskItem.hovered ? 1 : 0

                            onClicked: {
                                titleField.visible = true
                                titleLabel.visible = false
                                titleField.forceActiveFocus()
                                titleField.selectAll()
                            }
                        }
                        QQC2.ToolButton {
                            id: removeButton
                            visible: !titleField.visible

                            Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.5)

                            icon.name: "entry-delete"
                            opacity: taskItem.hovered ? 1 : 0
                            onClicked: {
                                root.tasksModel.remove(index)
                            }
                        }
                    }

                    QQC2.ToolTip.visible: !titleField.visible && titleLabel.truncated && taskItem.hovered
                    QQC2.ToolTip.text: model.title
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                }

                add: Transition {
                    OpacityAnimator {
                        from: 0
                        to: 1
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.OutQuad
                    }
                }
                remove: Transition {
                    OpacityAnimator {
                        from: 1
                        to: 0
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.OutQuad
                    }
                }

                Kirigami.PlaceholderMessage {
                    visible: list.count <= 0
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.gridUnit * 8)
                    text: i18n("All tasks completed!")
                    icon.name: "checkmark"
                    explanation: i18n("Add some more by typing in the text field at the bottom of the window")
                }
            }
        }

        footer: Footer {
            tasksModel: root.tasksModel
        }
    }
}
