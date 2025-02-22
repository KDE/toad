# SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
# SPDX-License-Identifier: BSD-2-Clause

cmake_minimum_required(VERSION 3.16)

project(tasks VERSION 0.1)
string(TOUPPER ${CMAKE_PROJECT_NAME} CMAKE_PROJECT_NAME_UPPERCASE)

include(FeatureSummary)

set(QT_MIN_VERSION 6.6)
set(KF_MIN_VERSION 6.8)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(ECMGenerateHeaders)
include(ECMPoQmTools)
include(ECMQtDeclareLoggingCategory)
include(ECMDeprecationSettings)
include(ECMAddAndroidApk)
include(ECMQmlModule)
include(KDEClangFormat)
include(KDEGitCommitHooks)

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX ${CMAKE_PROJECT_NAME_UPPERCASE}
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/src/version-${CMAKE_PROJECT_NAME}.h"
)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core Gui Qml QuickControls2)
find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS Kirigami CoreAddons Config I18n ItemModels)
find_package(KF6KirigamiAddons 1.0 REQUIRED)

if (NOT ANDROID)
    find_package(Qt6 ${QT_MIN_VERSION} REQUIRED COMPONENTS Widgets)
    find_package(KF6 ${KF_MIN_VERSION} REQUIRED COMPONENTS DBusAddons WindowSystem QQC2DesktopStyle)
    set_package_properties(KF6QQC2DesktopStyle PROPERTIES TYPE RUNTIME)
else()
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android/version.gradle.in ${CMAKE_BINARY_DIR}/version.gradle)
endif()

ecm_set_disabled_deprecation_versions(QT ${QT_MIN_VERSION} KF ${KF_MIN_VERSION})


add_subdirectory(src)

install(PROGRAMS org.kde.${CMAKE_PROJECT_NAME}.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES org.kde.${CMAKE_PROJECT_NAME}.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES org.kde.${CMAKE_PROJECT_NAME}.svg DESTINATION ${KDE_INSTALL_FULL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES src/*.cpp src/*.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
