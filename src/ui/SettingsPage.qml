// SPDX-FileCopyrightText: 2025 Mark Penner <mrp@markpenner.space>
// SPDX-License-Identifier: GPL-3.0-or-later

import org.kde.kirigamiaddons.formcard as FormCard

import org.kde.tasks.config
import org.kde.tasks.models

FormCard.FormCardPage {
    id: root

    title: i18n("Settings")

    FormCard.FormCard {
        FormCard.FormSwitchDelegate {
            text: i18n("Use default file location")
            description: checked ? Config.url : ""
            checked: Config.defaultLocation
            onToggled: {
                Config.defaultLocation = checked;
                TasksModel.updatePath();
            }
        }
    }
}
