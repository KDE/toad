// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-FileCopyrightText: 2025 Mark Penner <mrp@markpenner.space>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.delegates as Delegates
import org.kde.kitemmodels

import org.kde.tasks.models

Kirigami.ScrollablePage {
    id: page

    property bool searching: searchField.length
    property string currentSearchText: searchField.text

    title: page.searching ? i18np("1 result", "%1 results", list.count) : i18np("1 task", "%1 tasks", list.count)

    header: Kirigami.SearchField {
        id: searchField
        visible: searchAction.checked
    }

    actions: [
        QQC2.Action {
            text: i18n("Add Task")
            icon.name: "list-add"
            shortcut: StandardKey.New
            onTriggered: {
                TasksModel.add("");
                list.forceLayout();
                list.currentIndex = list.count - 1;
                list.currentItem.edit();
            }
        },
        QQC2.Action {
            id: searchAction
            Accessible.name: i18n("Search")
            text: Kirigami.Settings.isMobile ? i18n("Search") : ""
            icon.name: "search"
            shortcut: StandardKey.Find
            checkable: true
            onCheckedChanged: searchAction.checked ? searchField.forceActiveFocus() : searchField.clear()
        },
        Kirigami.Action {
            text: i18n("Clear Completed")
            icon.name: "edit-clear-all"
            displayHint: Kirigami.DisplayHint.AlwaysHide // destructive action shouldn't be directly in the UI
            onTriggered: TasksModel.clearCompleted()
            enabled: TasksModel.completedTasks > 0
        },
        // global actions below; displayHint: AlwaysHide so they'll go in the overflow menu
        Kirigami.Action {
            separator: true
            displayHint: Kirigami.DisplayHint.AlwaysHide
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "About Tasks")
            icon.name: "help-about"
            shortcut: StandardKey.HelpContents
            displayHint: Kirigami.DisplayHint.AlwaysHide
            onTriggered: pageStack.layers.push(aboutPage)
            enabled: pageStack.layers.depth <= 1
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "Enable tray icon")
            icon.name: "org.kde.tasks"
            displayHint: Kirigami.DisplayHint.AlwaysHide
            onTriggered: tray.visible ? tray.hide() : tray.show()
        },
        Kirigami.Action {
            text: i18nc("@action:inmenu", "Quit")
            icon.name: "application-exit"
            shortcut: StandardKey.Quit
            displayHint: Kirigami.DisplayHint.AlwaysHide
            onTriggered: Qt.quit()
        }
    ]

    ListView {
        id: list

        model: KSortFilterProxyModel {
            id: filteredModel
            sourceModel: TasksModel
            filterRoleName: "title"
            filterRegularExpression: RegExp("%1".arg(page.currentSearchText), "i")
        }

        delegate: Delegates.RoundedItemDelegate {
            id: taskItem

            contentItem: RowLayout {
                QQC2.CheckBox {
                    enabled: !titleField.visible
                    checked: model.checked
                    onToggled: model.checked = !model.checked
                }

                QQC2.Label {
                    id: titleLabel
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    text: model.title
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    maximumLineCount: taskItem.ListView.isCurrentItem ? Number.MAX_SAFE_INTEGER : 1

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.OutQuad
                        }
                    }

                    font.strikeout: model.checked
                    opacity: model.checked ? 0.5 : 1
                }

                QQC2.TextArea {
                    id: titleField
                    visible: false
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    text: model.title
                    wrapMode: Text.Wrap

                    horizontalAlignment: Text.AlignLeft
                    readOnly: model.checked

                    onEditingFinished: {
                        model.title = text
                        titleField.visible = false
                        titleLabel.visible = true
                    }
                    // pressing tab will finish editing instead of entering a tab character
                    KeyNavigation.priority: KeyNavigation.BeforeItem
                    KeyNavigation.tab: doneButton
                }
                Shortcut {
                    id: doneShortcut
                    enabled: titleField.visible
                    sequence: "Ctrl+Return"
                    onActivated: doneButton.click()
                }
                QQC2.ToolButton {
                    id: doneButton
                    visible: titleField.visible
                    hoverEnabled: true

                    icon.name: "checkmark"
                    onClicked: titleField.editingFinished()

                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                    QQC2.ToolTip.text: doneShortcut.nativeText
                }

                QQC2.ToolButton {
                    id: editButton
                    visible: !model.checked && !titleField.visible

                    Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.5)

                    icon.name: "entry-edit"
                    onClicked: edit()
                }
                QQC2.ToolButton {
                    id: removeButton
                    visible: !titleField.visible

                    Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.5)

                    icon.name: "entry-delete"
                    onClicked: {
                        const originalIndex = filteredModel.index(index, 0)
                        TasksModel.remove(filteredModel.mapToSource(originalIndex))
                    }
                }
            }

            onClicked: ListView.view.currentIndex = index;

            QQC2.ToolTip.visible: !titleField.visible && titleLabel.truncated && taskItem.hovered
            QQC2.ToolTip.text: model.title
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

            function edit () {
                titleField.visible = true;
                titleLabel.visible = false;
                titleField.forceActiveFocus();
                titleField.selectAll();
            }
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
            explanation: page.searching ? i18n("Your search did not match any results") : ""
        }
    }
}
