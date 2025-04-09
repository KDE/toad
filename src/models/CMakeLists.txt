# SPDX-FileCopyrightText: 2024 Thiago Sueto <herzenschein@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause

add_library(models)

ecm_add_qml_module(models
    URI
    org.kde.tasks.models
    GENERATE_PLUGIN_SOURCE
)

target_sources(models
    PRIVATE
    task.h task.cpp
    tasksmodel.h tasksmodel.cpp
)

target_link_libraries(models
    PRIVATE
    Qt6::Core
    config
    logging
)
if (NOT ANDROID)
    target_link_libraries(models PRIVATE KF6::CoreAddons)
endif()

ecm_finalize_qml_module(models)

install(TARGETS models ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
