// SPDX-FileCopyrightText: 2025 Mark Penner <mrp@markpenner.space>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.tasks.config
import org.kde.tasks.models

FormCard.FormCardPage {
    id: root

    title: i18n("Settings")

    FormCard.FormHeader {
        title: i18nc("@title", "Storage Location")
    }
    FormCard.FormCard {
        FormCard.FormSwitchDelegate {
            text: i18n("Use default location")
            checked: Config.defaultLocation
            onToggled: {
                Config.defaultLocation = checked;
                TasksModel.setLocation();
            }
        }
        FormCard.AbstractFormDelegate {
            enabled: !Config.defaultLocation
            contentItem: RowLayout {
                QQC2.Label {
                    text: i18nc("@label file location", "Location:")
                }
                QQC2.TextField {
                    Layout.fillWidth: true
                    text: Config.location
                    onEditingFinished: setLocation(text)
                }
                QQC2.Button {
                    text: i18n("Select...")
                    icon.name: "document-open"
                    onClicked: locationDialog.open()
                }
            }
        }
    }

    footer: Kirigami.InlineMessage {
        id: inlineMessage
        Layout.fillWidth: true
        position: Kirigami.InlineMessage.Position.Footer
        showCloseButton: true
    }

    FolderDialog {
        id: locationDialog
        currentFolder: Config.location
        onAccepted: setLocation(selectedFolder)
    }

    function setLocation(location) {
        if (!TasksModel.setLocation(location)) {
            inlineMessage.type = Kirigami.MessageType.Warning;
            inlineMessage.text = i18nc("warning", "Could not open %1", location);
            inlineMessage.visible = true;
        } else {
            inlineMessage.visible = false;
        }
    }
}
