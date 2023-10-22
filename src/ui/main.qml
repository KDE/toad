// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kitemmodels 1.0

import org.kde.tasks 1.0

Kirigami.ApplicationWindow {
    id: root

    title: i18n("Tasks")

    required property TasksModel tasksModel

    width: Kirigami.Units.gridUnit * 26
    height: Kirigami.Units.gridUnit * 36
    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20

    Timer {
        id: saveWindowGeometryTimer
        interval: 1000
        onTriggered: Controller.saveWindowGeometry(root)
    }

    Connections {
        id: saveWindowGeometryConnections
        enabled: false // Disable on startup to avoid writing wrong values if the window is hidden
        target: root

        function onClosing() { Controller.saveWindowGeometry(root); }
        function onWidthChanged() { saveWindowGeometryTimer.restart(); }
        function onHeightChanged() { saveWindowGeometryTimer.restart(); }
        function onXChanged() { saveWindowGeometryTimer.restart(); }
        function onYChanged() { saveWindowGeometryTimer.restart(); }
    }

    Loader {
        active: !Kirigami.Settings.isMobile
        sourceComponent: GlobalMenu {
            tasksModel: root.tasksModel
        }
    }

    pageStack.initialPage: Kirigami.Page {
        id: page

        property bool searching
        property string currentSearchText

        padding: 0
        titleDelegate: PageHeader {
            tasksModel: root.tasksModel
        }

        QQC2.ScrollView {
            anchors.fill: parent

            ListView {
                id: list
                interactive: contentHeight > height
                model: KSortFilterProxyModel {
                    id: filteredModel
                    sourceModel: root.tasksModel
                    filterRoleName: "title"
                    filterRegularExpression: {
                        if (page.currentSearchText === "") return new RegExp()
                        return new RegExp("%1".arg(page.currentSearchText.slice(1)), "i")
                    }
                }
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
                                const originalIndex = filteredModel.index(index, 0)
                                root.tasksModel.remove(filteredModel.mapToSource(originalIndex))
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
                    text: page.searching ? i18n("Nothing Found") : i18n("All tasks completed!")
                    icon.name: page.searching ? "edit-none" : "checkmark"
                    explanation: page.searching ? i18n("Your search did not match any results") : i18n("Add some more by typing in the text field at the bottom of the window")
                }
            }
        }

        footer: Footer {
            focus: !Kirigami.InputMethod.willShowOnActive
            tasksModel: root.tasksModel
        }
    }

    Component.onCompleted: {
        if (!Kirigami.Settings.isMobile) {
            saveWindowGeometryConnections.enabled = true
        }
    }
}
