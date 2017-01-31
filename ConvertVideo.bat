set roku_dir=

rem ---------------------------------------------------------
rem Convert the video to mp4
rem----------------------------------------------------------

rem - new Convert the video and keep aspect ratio - by Gilgamesh
rem "%roku_dir%\Third Party\HandBrakeCLI\HandBrakeCLI.exe" -i %1 -o "%~dpn1.mp4" -b 1500 -B 128 -R 48 --custom-anamorphic --keep-display-aspect  -O -r 29.97

rem - Convert the video and stretch it to fit widescreen 16:9 aspect ratio
"%roku_dir%\Third Party\HandBrakeCLI\HandBrakeCLI.exe" -i %1 -o "%~dpn1.mp4" -b 1500 -B 128 -R 48 -w 720 -l 400 -O -r 29.97 --custom-anamorphic --crop 0:0:0:0 --display-width 720

rem - delete the old video (.ts file)
del /Q /A:R /A:S /A:H /A:A %1


rem ---------------------------------------------------------
rem Create the video thumnail png
rem----------------------------------------------------------

"%roku_dir%\Third Party\ffmpeg\ffmpeg.exe" -i "%~dpn1.mp4" -vframes 1 -ss 400 -s 224x158 -f image2 "%~dpn1_sd.png"
"%roku_dir%\Third Party\ffmpeg\ffmpeg.exe" -i "%~dpn1.mp4" -vframes 1 -ss 400 -s 304x238 -f image2 "%~dpn1_hd.png"


rem ---------------------------------------------------------
rem Create the bif files
rem----------------------------------------------------------

mkdir "%~dpn1_sd"
mkdir "%~dpn1_hd

"%roku_dir%\Third Party\ffmpeg\ffmpeg.exe" -i "%~dpn1.mp4" -r .1 -s 240x180 "%~dpn1_sd\%%08d.jpg"
"%roku_dir%\reindex.exe" "%~dpn1_sd" > "%roku_dir%\logs\sdlog.txt"
"%roku_dir%\Third Party\ffmpeg\ffmpeg.exe" -i "%~dpn1.mp4" -r .1 -s 320x240 "%~dpn1_hd\%%08d.jpg"
"%roku_dir%\reindex.exe" "%~dpn1_hd" > "%roku_dir%\logs\hdlog.txt"

pushd "%~dp1"

"%roku_dir%\Third Party\Roku\biftool.exe" -t 10000 "%~dpn1_sd"
"%roku_dir%\Third Party\Roku\biftool.exe" -t 10000 "%~dpn1_hd"

popd

rmdir /s /q "%~dpn1_sd"
rmdir /s /q "%~dpn1_hd"
