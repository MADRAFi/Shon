export PATH="$PATH:/Users/madrafi/Library/Mobile Documents/com~apple~CloudDocs/Atari/DEV/MADS/bin/macosx_aarch64/:/Users/madrafi/Library/Mobile Documents/com~apple~CloudDocs/Atari/DEV/MAD-Pascal/bin/macosx_aarch64/"
echo Compiling
rm -f ./shon.a65
mp shon.pas -define:DEBUG -ipath:/Users/madrafi/Library/Mobile\ Documents/com~apple~CloudDocs/Atari/DEV/MAD-Pascal/lib/
mads shon.a65 -x -i:/Users/madrafi/Library/Mobile\ Documents/com~apple~CloudDocs/Atari/DEV/MAD-Pascal/base/ -o:shon.xex