    # SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause



add_executable(${CMAKE_PROJECT_NAME}
    main.cpp
    controller.cpp
    controller.h
    task.cpp
    task.h
    tasksmodel.cpp
    tasksmodel.h
    resources.qrc)

ecm_qt_declare_logging_category(${CMAKE_PROJECT_NAME} HEADER ${CMAKE_PROJECT_NAME}_debug.h IDENTIFIER ${CMAKE_PROJECT_NAME_UPPERCASE}_LOG CATEGORY_NAME org.kde.${CMAKE_PROJECT_NAME}
        DESCRIPTION "tasl (knotes)"
        EXPORT ${CMAKE_PROJECT_NAME}_EXPORT
    )


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
        license
        arrow-right
        list-add
    )
    ecm_add_android_apk(${CMAKE_PROJECT_NAME} ANDROID_DIR ${CMAKE_SOURCE_DIR}/android)
endif()

kconfig_add_kcfg_files(${CMAKE_PROJECT_NAME} GENERATE_MOC config.kcfgc)
install(TARGETS ${CMAKE_PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
