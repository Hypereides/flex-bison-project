@echo off
setlocal

where bison >nul 2>nul
if errorlevel 1 set PATH=C:\msys64\usr\bin;C:\msys64\ucrt64\bin;%PATH%

where bison >nul 2>nul
if errorlevel 1 goto :notools
where flex  >nul 2>nul
if errorlevel 1 goto :notools
where gcc   >nul 2>nul
if errorlevel 1 goto :notools

bison -d -o parser.tab.c parser.y || goto :fail
flex  -o lex.yy.c lexer.l         || goto :fail
gcc -Wall -Wextra -O2 -o myParser.exe parser.tab.c lex.yy.c symtab.c || goto :fail

echo.
echo Built myParser.exe
echo Usage: myParser.exe ^<file_name^>
goto :eof

:notools
echo.
echo bison, flex or gcc not found in PATH.
echo On Windows install MSYS2 and run:
echo     pacman -S flex bison mingw-w64-ucrt-x86_64-gcc
echo then add its bin folders to PATH and run this script again.
exit /b 1

:fail
echo.
echo BUILD FAILED
exit /b 1
