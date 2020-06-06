@if exist %DSZLOG% del %DSZLOG%
@rem  batch upload
@if "%3" == "" HSLINK -P%1 -E%2 -NU  -UD:\NEWUP\WORK0
@rem  single file upload
@if not "%3" == "" HSLINK -P%1 -E%2 -NU  -UD:\NEWUP