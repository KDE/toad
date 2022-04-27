// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

import org.kde.tasks 1.0

Kirigami.Page {
    id: page

    title: i18n("Settings")

    Kirigami.FormLayout {
        anchors.fill: parent

        QQC2.CheckBox {
            text: i18n("Automatically delete checked tasks")
            checked: Config.deleteWhenChecked
            onClicked: {
                Config.deleteWhenChecked = !Config.deleteWhenChecked;
                Config.save();
            }
        }
    }
}
