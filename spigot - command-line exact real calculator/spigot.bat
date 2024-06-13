@ECHO off
spigot.exe --version
:START
ECHO.
ECHO Enter arguments.
SET /p "args="
spigot.exe %args%
GOTO START