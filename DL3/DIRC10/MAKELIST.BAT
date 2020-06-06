rem Update full list of files available

set WORK=c:\$work$
mkdir %WORK%

rem ---------------------------------------------------
rem copy subset of DIR files to be included in listing
rem ---------------------------------------------------
for %%f in (    1  2  3  4     6  7  8  9) do copy u:\pcb\gen\dldir%%f %WORK%
for %%f in (10 11                        ) do copy u:\pcb\gen\dldir%%f %WORK%
for %%f in (20 21 22 23 24 25 26 27    29) do copy u:\pcb\gen\dldir%%f %WORK%
for %%f in (30    32 33 34 35 36 37 38 39) do copy u:\pcb\gen\dldir%%f %WORK%
for %%f in (40 41 42 43    45 46 47 48 49) do copy u:\pcb\gen\dldir%%f %WORK%
for %%f in (50 51 52 53 54 55 56 57 58 59) do copy u:\pcb\gen\dldir%%f %WORK%
for %%f in (60 61 62    64 65 66 67 68 69) do copy u:\pcb\gen\dldir%%f %WORK%
for %%f in (70    72 73 74 75    77    79) do copy u:\pcb\gen\dldir%%f %WORK%
copy u:\pcb\gen\upload    %WORK%

for %%f in ( 1  2  3  4  5  6            ) do copy u:\pcb\gen\dlGIF%%f %WORK%
copy u:\pcb\gen\GIFUL     %WORK%

rem ---------------------------------------------------
rem create sorted master files listing
rem ---------------------------------------------------
call tmp c:
copy %WORK%\*.* temp-1
dirc -concat temp-1 temp-2
qsort /t <temp-2 >temp-1
del temp-2
dirc -expand temp-1 temp-3
del temp-1
noulby temp-3
dircount u:\pcb\toolsort.cnf
del *.bak
del toolsort
del temp-3.bak
ren temp-3 toolsort

copy u:\pcb\gen\welcome .
copy u:\pcb\event\order.frm .

copy u:\pcb\event\!file2.txt %WORK%\!
if exist toolsort.lzh del toolsort.lzh
lha a toolsort.lzh %WORK%\!
lha a toolsort.lzh welcome order.frm toolsort
lha s toolsort
copy toolsort.exe u:\DL1
del toolsort.*

rem ---------------------------------------------------
rem create unsorted master files listing
rem ---------------------------------------------------
if exist toolshop.lzh del toolshop.lzh
copy u:\pcb\event\!file.txt %WORK%\!
copy u:\pcb\gen\welcome   %WORK%
copy u:\pcb\event\order.frm .
lha a toolshop.lzh %WORK%\!
lha a toolshop.lzh welcome order.frm
lha a toolshop.lzh %WORK%\*.*
lha s toolshop
copy toolshop.exe u:\DL1
del toolshop.exe
del toolshop.lzh

rem ---------------------------------------------------
rem clean up and update DIR listing with new datestamp
rem ---------------------------------------------------
cd \
echo Y|del %WORK%\*.*
rmdir %WORK%

call Ufdir U:\pcb\gen\dldir1 U:\DL1\

call pcb
