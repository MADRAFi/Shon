@Echo off
@setlocal
@set PATH=%PATH%;D:\Dropbox\Atari\DEV\MAD-Pascal\;D:\Dropbox\Atari\DEV\MADS\
echo Compiling
mp.exe shon.pas -define:DEBUG
if exist shon.a65 mads.exe shon.a65 -x -i:D:\Dropbox\Atari\DEV\MAD-Pascal\base -o:shon_uncmp.xex >> compile_shon.txt
rem if not %ERRORLEVEL%==0 pause
rem echo.
pause
