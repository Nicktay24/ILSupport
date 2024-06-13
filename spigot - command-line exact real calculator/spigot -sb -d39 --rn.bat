@ECHO off
spigot.exe --version

:INIT
SET prec=-d39
SET rounding=--rn

:READ_EXPR
SET "expr="
ECHO.
ECHO spigot - Enter expression or args. Args: %prec% %rounding%
SET /p "expr=> "
IF /i "%expr%" == "-q" GOTO EOF
	IF /i "%expr%" == "-quit" GOTO EOF
	IF /i "%expr%" == "-x" GOTO EOF
	IF /i "%expr%" == "-exit" GOTO EOF
IF /i "%expr%" == "-help" GOTO HELP
	IF /i "%expr%" == "--help" GOTO HELP
IF /i "%expr:~0,2%" == "-d" GOTO SET_PREC
IF /i "%expr:~0,3%" == "--r" GOTO SET_ROUNDING

REM evaluate expression
spigot.exe %prec% %rounding% "(%expr%)"
spigot.exe -sb %prec% %rounding% "(%expr%)"
GOTO READ_EXPR

:HELP
spigot.exe --help
GOTO READ_EXPR

REM set args
:SET_PREC
CALL :IS_INT %expr:~2% IS_INT_result
IF /a %IS_INT_result% == 0 (ECHO Integer expected after -d.) ELSE (SET prec=-d%expr:~2% & ECHO Precision: %prec:~2% (base 10^))
GOTO READ_EXPR

:SET_ROUNDING
CALL :SET_ROUNDING_CASE_SWITCH
GOTO READ_EXPR
:SET_ROUNDING_CASE_SWITCH
SETLOCAL EnableExtensions DisableDelayedExpansion
GOTO SET_ROUNDING_CASE_%expr:~3% 2>NUL || (ECHO Unknown rounding mode. Rounding modes: z (To Zero^), i (Away From Zero^), u (Up^), d (Down^), n/ne (To Nearest Even^), no (To Nearest Odd^), nz (To Nearest, To Zero^), ni (To Nearest, Away From Zero^), nu (To Nearest, Up^), nd (To Nearest, Down^).)
:SET_ROUNDING_CASE_z
SET "rounding=To Zero"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_i
SET "rounding=Away From Zero"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_u
SET "rounding=Up"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_d
SET "rounding=Down"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_n
:SET_ROUNDING_CASE_ne
SET "rounding=To Nearest Even"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_no
SET "rounding=To Nearest Odd"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_nz
SET "rounding=To Nearest, To Zero"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_ni
SET "rounding=To Nearest, Away From Zero"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_nu
SET "rounding=To Nearest, Up"
GOTO SET_ROUNDING_END
:SET_ROUNDING_CASE_nd
SET "rounding=To Nearest, Down"
:SET_ROUNDING_END
ECHO Rounding mode: %rounding%
SET rounding=--r%expr:~3%
GOTO EOF

REM functions
:IS_INT IS_INT_arg IS_INT_result
SETLOCAL EnableExtensions DisableDelayedExpansion
REM IF NOT DEFINED IS_INT_arg GOTO IS_INT_F
REM IF "%1" == "" GOTO IS_INT_F
SET IS_INT_arg=%~1
SET /a "IS_INT_var=1"
FOR /f "delims=0123456789" %%i IN ("%IS_INT_arg%") DO SET /a "IS_INT_var=0"
SET /a %~2=%IS_INT_var%
ENDLOCAL
GOTO EOF

:EVAL_ARGS EVAL_ARGS_arg
SETLOCAL EnableExtensions DisableDelayedExpansion
spigot.exe %1
ENDLOCAL
:EOF
EXIT /B 0