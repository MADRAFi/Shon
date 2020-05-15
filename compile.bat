@Echo off
echo Comiling
c:\Users\MADRAFi\Dropbox\Atari\DEV\MADS\mp.exe shon.pas -define:DEBUG
if exist shon.a65 c:\Users\MADRAFi\Dropbox\Atari\DEV\MADS\mads.exe shon.a65 -x -i:c:\Users\MADRAFi\Dropbox\Atari\DEV\MADS\base -o:shon_uncmp.xex
if not %ERRORLEVEL%==0 pause
echo.

