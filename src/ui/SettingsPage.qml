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
        FormCard.FormTextDelegate {
            text: i18n("Current Location")
            description: Config.url
        }
        FormCard.FormSwitchDelegate {
            text: i18n("Use default location")
            checked: Config.defaultLocation
            onToggled: {
                Config.defaultLocation = checked;
                TasksModel.updatePath();
            }
        }
        FormCard.AbstractFormDelegate {
            visible: !Config.defaultLocation
            contentItem: RowLayout {
                QQC2.Button {
                    Layout.fillWidth: true
                    text: i18n("Open...")
                    icon.name: "document-open"
                    onClicked: openDialog.open()
                }
                QQC2.Button {
                    Layout.fillWidth: true
                    text: i18n("Save as...")
                    icon.name: "document-save-as"
                    onClicked: saveDialog.open()
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

    FileDialog {
        id: openDialog
        currentFolder: Config.url
        nameFilters: [i18n("JSON files (*.json)")]
        onAccepted: {
            if (!TasksModel.open(selectedFile)) {
                inlineMessage.type = Kirigami.MessageType.Warning;
                inlineMessage.text = i18nc("warning, could not open a file", "Could not open %1", selectedFile);
                inlineMessage.visible = true;
            } else {
                inlineMessage.visible = false;
            }
        }
    }

    FileDialog {
        id: saveDialog
        defaultSuffix: "json"
        fileMode: FileDialog.SaveFile
        currentFolder: Config.url
        nameFilters: [i18n("JSON files (*.json)")]
        onAccepted: {
            if (!TasksModel.saveAs(selectedFile)) {
                inlineMessage.type = Kirigami.MessageType.Warning;
                inlineMessage.text = i18nc("warning, could not save a file", "Could not save %1", selectedFile);
                inlineMessage.visible = true;
            } else {
                inlineMessage.visible = false;
            }
        }
    }
}
