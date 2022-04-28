# SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause

add_executable(tasks
    main.cpp
    about.cpp
    task.cpp
    tasksmodel.cpp
    resources.qrc)

target_link_libraries(tasks
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n
    KF5::CoreAddons
    KF5::ConfigCore
    KF5::ConfigGui
    KF5::DBusAddons)

kconfig_add_kcfg_files(tasks GENERATE_MOC tasksconfig.kcfgc)
install(TARGETS tasks ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
