@Echo off
@setlocal
@set PATH=%PATH%;D:\iCloud\iCloudDrive\Atari\DEV\MAD-Pascal\bin\windows\;D:\iCloud\iCloudDrive\Atari\DEV\MADS\bin\windows\
echo Compiling
mp.exe shon.pas -define:DEBUG -ipath:d:\iCloud\iCloudDrive\Atari\DEV\MAD-Pascal\lib\
if exist shon.a65 mads.exe shon.a65 -x -i:d:\iCloud\iCloudDrive\Atari\DEV\MAD-Pascal\base -o:shon.xex
rem if not %ERRORLEVEL%==0 pause
rem echo.
pause
