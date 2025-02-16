<!--
    SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
    SPDX-License-Identifier: CC0-1.0
-->

# Tasks

Tasks is a to-do application. You can add, edit, and delete tasks and
Tasks will save your changes automatically. Tasks works on desktop and
mobile.

![tasks window](https://cdn.kde.org/screenshots/tasks/tasks.png)

## How to get it
You can get a nightly flatpak by adding the
[nightly flatpak repository](https://cdn.kde.org/flatpak/toad-nightly/toad-nightly.flatpakrepo)
to your app store. To install on Android you can use the
[nightly KDE F-Droid repository](https://cdn.kde.org/android/nightly/fdroid/repo/).

### Build Flatpak

To build a flatpak bundle of Tasks use the following instructions:

```bash
$ git clone https://invent.kde.org/utilities/toad.git
$ cd toad
$ flatpak-builder --repo=repo build-dir --force-clean org.kde.tasks.json
$ flatpak build-bundle repo tasks.flatpak org.kde.tasks
```

Now you can either double-click the `tasks.flatpak` file to open it with
some app store (discover, gnome-software, etc...) or run:

```bash
$ flatpak install tasks.flatpak
```
