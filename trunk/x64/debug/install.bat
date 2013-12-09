NET STOP SPOOLER
COPY /Y mfilemon.dll C:\Windows\System32
COPY /Y mfilemonui.dll C:\Windows\System32
NET START SPOOLER
PAUSE