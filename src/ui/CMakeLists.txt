# SPDX-FileCopyrightText: 2024 Thiago Sueto <herzenschein@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause

add_library(ui)

ecm_add_qml_module(ui
    URI
    org.kde.tasks.ui
    GENERATE_PLUGIN_SOURCE
)

ecm_target_qml_sources(ui
    SOURCES
    GlobalMenu.qml
    PageHeader.qml
    TasksPage.qml
    Tray.qml
)

target_link_libraries(ui PRIVATE
    KF6::ItemModels
    models
)

ecm_finalize_qml_module(ui)

install(TARGETS ui ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
