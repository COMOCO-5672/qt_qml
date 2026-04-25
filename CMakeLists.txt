cmake_minimum_required(VERSION 3.16)

project(QmlQuickStart LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Qml QuickControls2)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick Qml QuickControls2)

add_executable(QmlQuickStart
    src/main.cpp
    src/AppViewModel.cpp
    src/AppViewModel.h
    src/AppEventFilter.cpp
    src/AppEventFilter.h
    src/EventViewModel.cpp
    src/EventViewModel.h
    src/TodoListModel.cpp
    src/TodoListModel.h
    qml.qrc
)

target_link_libraries(QmlQuickStart PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::QuickControls2
)

if(MSVC)
    target_compile_options(QmlQuickStart PRIVATE /utf-8)
endif()

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(QmlQuickStart)
endif()
