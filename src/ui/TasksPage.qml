// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
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

    property bool searching
    property string currentSearchText

    titleDelegate: PageHeader {}

    ListView {
        id: list

        model: KSortFilterProxyModel {
            id: filteredModel
            sourceModel: TasksModel
            filterRoleName: "title"
            filterRegularExpression: {
                if (page.currentSearchText === "") {
                    page.searching = false
                    return new RegExp()
                }
                return new RegExp("%1".arg(page.currentSearchText), "i")
            }
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

    footer: Kirigami.SearchField {
        onAccepted: {
            page.searching = true;
            page.currentSearchText = text;
        }
    }
}
