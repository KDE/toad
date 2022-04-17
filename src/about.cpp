// SPDX-License-Identifier: GPL-2.0-or-later
// PDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>

#include "about.h"

KAboutData AboutType::aboutData() const
{
    return KAboutData::applicationData();
}
