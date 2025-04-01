// SPDX-FileCopyrightText: 2025 Mark Penner <mrp@markpenner.space>
// SPDX-License-Identifier: GPL-3.0-or-later

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
    }
}
