# SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause

add_executable(${CMAKE_PROJECT_NAME}
    main.cpp
    about.cpp
    controller.cpp
    task.cpp
    tasksmodel.cpp
    resources.qrc)

target_link_libraries(${CMAKE_PROJECT_NAME}
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
    KF5::ItemModels)

if (NOT ANDROID)
    target_link_libraries(${CMAKE_PROJECT_NAME} KF5::DBusAddons KF5::WindowSystem)
else()
    kirigami_package_breeze_icons(ICONS
        entry-edit
        entry-delete
        edit-none
        edit-clear-all
        search
        help-about
        checkmark
        application-exit
        tools-report-bug
        help-about
    )
endif()

kconfig_add_kcfg_files(${CMAKE_PROJECT_NAME} GENERATE_MOC config.kcfgc)
install(TARGETS ${CMAKE_PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
