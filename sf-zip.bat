@SET VERSION=1.4.1
@IF EXIST "..\mfilemon-%VERSION%-sources.zip" DEL "..\mfilemon-%VERSION%-sources.zip"
REM @IF EXIST "..\mfilemon-%VERSION%-x86.zip" DEL "..\mfilemon-%VERSION%-x86.zip"
REM @IF EXIST "..\mfilemon-%VERSION%-x64.zip" DEL "..\mfilemon-%VERSION%-x64.zip"
@C:\Programmi\7-zip\7z.exe a -tzip "..\mfilemon-%VERSION%-sources.zip" -ir!*.cpp -ir!*.h -ir!*.rc -ir!*.en -ir!*.it -ir!*.sln -ir!*.suo -ir!*.vcproj -ir!*.def -ir!*.inf -ir!*.iss -ir!*.rules -ir!docs\*.* INSTALL.txt LICENSE.txt README.txt
REM @C:\Programmi\7-zip\7z.exe a -tzip "..\mfilemon-%VERSION%-x86.zip" -ir!win32\release*\mfilemon*.dll win32\release\regmon.exe win32\release*\monitor.inf -ir!docs\*.* INSTALL.txt LICENSE.txt README.txt
REM @C:\Programmi\7-zip\7z.exe a -tzip "..\mfilemon-%VERSION%-x64.zip" -ir!x64\release*\mfilemon*.dll x64\release\regmon.exe x64\release*\monitor.inf -ir!docs\*.* INSTALL.txt LICENSE.txt README.txt