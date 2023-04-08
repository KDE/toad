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
    KF${QT_MAJOR_VERSION}::I18n
    KF${QT_MAJOR_VERSION}::CoreAddons
    KF${QT_MAJOR_VERSION}::ConfigCore
    KF${QT_MAJOR_VERSION}::ConfigGui
    KF${QT_MAJOR_VERSION}::ItemModels)

if (NOT ANDROID)
    target_link_libraries(${CMAKE_PROJECT_NAME} Qt::Widgets KF${QT_MAJOR_VERSION}::DBusAddons KF${QT_MAJOR_VERSION}::WindowSystem)
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
