NET STOP SPOOLER
COPY /Y D:\proj\mfilemon\Win32\debug\mfilemon.dll C:\Windows\System32
COPY /Y D:\proj\mfilemon\Win32\debug\mfilemonui.dll C:\Windows\System32
NET START SPOOLER
PAUSE