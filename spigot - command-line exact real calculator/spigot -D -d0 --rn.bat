@ECHO off
spigot.exe --version
:START
ECHO.
ECHO spigot - Enter expression.
SET /p "expr="
spigot.exe -D -d0 --rn "(%expr%)"
GOTO START