echo off
REM upload to Wildcat 2.15
cd \wildcat\ep
if exist transfer.bad del transfer.bad
mkdir scratch
hslink -P%2 -HS -Uscratch
if errorlevel 1 copy hs-u.bat transfer.bad
copy scratch\*.* %4
for %%f in (scratch\*.*) do del %%f
rmdir scratch
