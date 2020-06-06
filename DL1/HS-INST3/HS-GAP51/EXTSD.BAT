@if exist %DSZLOG% del %DSZLOG%
@flistcnv.exe
@HSLINK -P%1 -E%2 -NU @FILELIST