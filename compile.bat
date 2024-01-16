@Echo off
echo Comiling
mp.exe shon.pas -define:DEBUG
if exist shon.a65 mads.exe shon.a65 -x -i:D:\Dropbox\Atari\DEV\MADS\base -o:shon_uncmp.xex
if not %ERRORLEVEL%==0 pause
echo.

