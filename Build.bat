@echo off
setlocal

set CONFIG=Debug

:: Delete build directory
if "%1"=="clean" (
    echo Cleaning build directory...
    rmdir /s /q build
    goto :eof
)

:: Build Clean
if "%1"=="rebuild" (
    echo Rebuilding %CONFIG%...
    cmake --build build --config %CONFIG% --target clean
)

:: Build Engine
if not exist build (
    echo Configuring project...
    cmake -S . -B build -G "Visual Studio 17 2022" -A x64 -Wno-dev
)

:: Build TITEN
echo Building TITEN (%CONFIG%)...
cmake --build build --config %CONFIG% --target TITEN

endlocal