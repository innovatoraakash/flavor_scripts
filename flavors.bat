@echo off
setlocal

set "BASH_PATH=C:\Program Files\Git\bin\bash.exe"
set "SCRIPT_PATH=E:\flavor_scripts"


if "%1"=="list" (
    set "SCRIPT_NAME=flavor_list.sh"
) else if "%1"=="setup" (
    set "SCRIPT_NAME=setup_folder.sh"
) else if "%1"=="add" (
    set "SCRIPT_NAME=add_flavor.sh"
) else if "%1"=="publish" (
    set "SCRIPT_NAME=publish.sh"
) else if "%1"=="build" (
    set "SCRIPT_NAME=build.sh"
) else if "%1"=="--help" (
    @REM echo Usage: script_name [list|setup|--help]
    echo.
    echo list    - List out all the flavors available in current directory
    echo setup   - build required project structure for flavors 
    echo add   - add new flavor to current project directory
    echo publish   - publish all or selected flavors to store 
    echo build   - build release apk for all or selected flavors 
    echo --help  - Display this help message
    exit /b
) else (
    echo Invalid command
      echo Type script_name --help for usage information
    exit /b
)



"%BASH_PATH%" "%SCRIPT_PATH%\%SCRIPT_NAME%"
endlocal