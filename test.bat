@echo off


setlocal enableextensions enabledelayedexpansion
for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"
echo test
echo this is a bunhc of bc
echo yuppers
echo.
:loop
set increasing=!increasing!a
<nul set /p"=!increasing! !CR!"
goto loop

<nul set /p"=hellooo "
pause>nul