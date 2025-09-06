cmake_minimum_required(VERSION 3.24)
project(Titus-Engine LANGUAGES C CXX)

# Global output dirs
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/$<CONFIG>)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/$<CONFIG>)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/$<CONFIG>)

if (MSVC)
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ============================================================
# Dependencies
# ============================================================

add_subdirectory(Titus-Engine/vendor/glfw)
add_subdirectory(Titus-Engine/vendor/Vulkan-Headers)
add_subdirectory(Titus-Engine/vendor/Vulkan-Loader)
add_subdirectory(Titus-Engine/vendor/glm)
add_subdirectory(Titus-Engine/vendor/spdlog)
add_subdirectory(Titus-Engine/vendor/entt)
add_subdirectory(Titus-Engine/vendor/assimp)

add_library(asio INTERFACE)
target_include_directories(asio INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/asio
)

add_library(miniaudio INTERFACE)
target_include_directories(miniaudio INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/miniaudio
)

add_library(stb INTERFACE)
target_include_directories(stb INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/stb
)

if (TARGET vulkan)
  add_library(Vulkan::Vulkan ALIAS vulkan)
endif()

if (NOT TARGET Vulkan::Headers)
  add_library(Vulkan::Headers INTERFACE)
  target_include_directories(Vulkan::Headers INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/Vulkan-Headers/include
  )
endif()

set(IMGUI_SRC
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/imgui.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/imgui_demo.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/imgui_draw.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/imgui_tables.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/imgui_widgets.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/backends/imgui_impl_glfw.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/backends/imgui_impl_vulkan.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/backends/imgui_impl_dx11.cpp
)

add_library(imgui STATIC ${IMGUI_SRC})
target_include_directories(imgui PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/backends
  ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/Vulkan-Headers/include
)
target_link_libraries(imgui PUBLIC glfw Vulkan::Vulkan d3d11 dxgi)

# ============================================================
# Titus-Engine
# ============================================================

file(GLOB_RECURSE TE_SOURCES CONFIGURE_DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/src/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/src/*.h
)

add_library(Titus-Engine STATIC ${TE_SOURCES})
target_compile_features(Titus-Engine PUBLIC cxx_std_20)

target_include_directories(Titus-Engine PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/src
    ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/imgui/backends
    ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/Vulkan-Headers/include
    ${CMAKE_CURRENT_SOURCE_DIR}/Titus-Engine/vendor/glfw/include
)

target_link_libraries(Titus-Engine
  PUBLIC
    imgui
    glfw
    Vulkan::Vulkan
    Vulkan::Headers
    glm::glm
    spdlog::spdlog_header_only
    stb
    EnTT::EnTT
    assimp
    asio
    miniaudio
)

target_compile_definitions(Titus-Engine
   #PRIVATE TE_BUILD_DLL
    PUBLIC  TE_PLATFORM_WINDOWS
)

#if (WIN32)
#  target_compile_definitions(Titus-Engine PRIVATE TE_PLATFORM_WINDOWS)
#endif()

# ============================================================
# TITEN
# ============================================================

file(GLOB_RECURSE TITEN_SOURCES CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/TITEN/src/*.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/TITEN/src/*.h
)

add_executable(TITEN ${TITEN_SOURCES})

target_link_libraries(TITEN PRIVATE Titus-Engine)
set_target_properties(TITEN PROPERTIES WIN32_EXECUTABLE FALSE)

target_compile_definitions(TITEN
    PUBLIC  TE_PLATFORM_WINDOWS
)

# Copy engine DLL next to TITEN.exe
add_custom_command(TARGET TITEN POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<TARGET_FILE:Titus-Engine>
    $<TARGET_FILE_DIR:TITEN>
)