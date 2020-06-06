echo off
rem. process library disk request - for ProDOOR 2.6
rem.   %1=logfile  %2=subdir on cd-rom %3=disk on cd-rom
rem.   %4=homedir  %5=com port

%4proecho %5 ~Searching for subdirectories on CD-ROM...
%4proctree E:%2 xcopy >%4arctree.bat

%4proecho %5 ~Copy CD-ROM files into RAM...
%COMSPEC% /c %4arctree nul

%4proecho %5 ~Archiving CD-ROM files...
if exist C:\ARC\CD-%3.ARC del C:\ARC\CD-%3.ARC
pkarc m C:\ARC\CD-%3.ARC C:\PLAYPEN\*.* >%1

%4proecho %5 ~~~Thank you for waiting!~
%4proecho %5 ~Disk %3 is now stored in CD-%3.ARC for you!~~~

