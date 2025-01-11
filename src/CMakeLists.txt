    # SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause



add_executable(${CMAKE_PROJECT_NAME}
    main.cpp
)

ecm_add_qml_module(${CMAKE_PROJECT_NAME}
    URI
    org.kde.tasks
)

ecm_target_qml_sources(${CMAKE_PROJECT_NAME}
    SOURCES
    Main.qml
)

target_link_libraries(${CMAKE_PROJECT_NAME}
    PRIVATE
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
    KF6::I18n
    KF6::I18nQml
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::ItemModels
    logging
    models
    ui
)

add_library(logging STATIC)
set_target_properties(logging PROPERTIES POSITION_INDEPENDENT_CODE ON)

ecm_qt_declare_logging_category(logging
    HEADER ${CMAKE_PROJECT_NAME}_debug.h
    IDENTIFIER ${CMAKE_PROJECT_NAME_UPPERCASE}_LOG
    CATEGORY_NAME org.kde.${CMAKE_PROJECT_NAME}
    DESCRIPTION "tasl (knotes)"
    EXPORT ${CMAKE_PROJECT_NAME}_EXPORT
)

target_link_libraries(logging
    PRIVATE
    Qt6::Core
)

ecm_qt_install_logging_categories(
        EXPORT ${CMAKE_PROJECT_NAME}_EXPORT
        FILE ${CMAKE_PROJECT_NAME}.categories
        DESTINATION ${KDE_INSTALL_LOGGINGCATEGORIESDIR}
)

if (NOT ANDROID)
    target_link_libraries(${CMAKE_PROJECT_NAME}
        PRIVATE
        Qt::Widgets
        KF6::DBusAddons
        KF6::WindowSystem
    )
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

kconfig_target_kcfg_file(${CMAKE_PROJECT_NAME} FILE config.kcfg CLASS_NAME Config MUTATORS GENERATE_PROPERTIES GENERATE_MOC DEFAULT_VALUE_GETTERS PARENT_IN_CONSTRUCTOR QML_REGISTRATION SINGLETON)

install(TARGETS ${CMAKE_PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

if (ANDROID)
    install(FILES ../org.kde.tasks.svg  DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/breeze-internal/icons/ RENAME org.kde.tasks.svg)
endif()

add_subdirectory(models)
add_subdirectory(ui)
