# Tasks

Organize your tasks

![tasks window](https://cdn.kde.org/screenshots/tasks/tasks.png)

## Build Flatpak

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
