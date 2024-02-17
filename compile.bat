@Echo off
@setlocal
@set PATH=%PATH%;..\MAD-Pascal\;..\MADS\bin\windows\
echo Compiling
mp.exe shon.pas -define:DEBUG -ipath:..\MAD-Pascal\lib\
if exist shon.a65 mads.exe shon.a65 -x -i:..\MAD-Pascal\base -o:shon.xex
rem if not %ERRORLEVEL%==0 pause
rem echo.
pause
