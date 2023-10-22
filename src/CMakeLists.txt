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
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    KF6::I18n
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::ItemModels)

if (NOT ANDROID)
    target_link_libraries(${CMAKE_PROJECT_NAME} Qt::Widgets KF6::DBusAddons KF6::WindowSystem)
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
