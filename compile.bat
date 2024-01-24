@Echo off
@setlocal
rem @set PATH=%PATH%;D:\Dropbox\Atari\DEV\MAD-Pascal\;D:\Dropbox\Atari\DEV\MADS\
echo Compiling
mp.exe shon.pas -define:DEBUG -ipath:D:\Dropbox\Atari\DEV\MAD-Pascal\lib
if exist shon.a65 mads.exe shon.a65 -x -i:D:\Dropbox\Atari\DEV\MAD-Pascal\base -o:shon_uncmp.xex
rem if not %ERRORLEVEL%==0 pause
rem echo.
pause
