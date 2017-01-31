Before using, please open and edit roku.ini file.

[locals]
local_ip=Auto
server_port=8000
npvr_dir=C:\Users\Public\NPVR\
password=__secret__

Replace "Auto" with your IP:
local_ip=192.168.1.55
If you want the application to configure the IP automatically:
local_ip=Auto

"server_port" is the port this application will listen on for requests from Roku box.

"npvr_dir" the directory where NPVR database and config.xml resides

"password" the password you use to connect to NPVR's web interface


After you have the right values, save the roku.ini file and restart this application (right click on Roku tray icon -> exit)

Add this line at the end of your PostProcessing.bat (replace _path_ with the folder where this application resides, ex: call "d:\Server\ConvertVideo.bat" %1):  

call "_path_\ConvertVideo.bat" %1

