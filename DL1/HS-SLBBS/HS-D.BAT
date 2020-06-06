@ECHO OFF
HSLINK -P%1 -! -UC:\BBS\UPLOADS.BBS
REM
REM Description of switches....
REM
REM                  -P%1 : Gets the active com port from SLBBS
REM                    -! : Forces remote to your configuration
REM  -UC:\BBS\UPLOADS.BBS : This line MUST be used for SLBBS to find
REM                       : the files that are being uploaded.
REM
REM You can use extra switches on the command line that are not outlined
REM here.  Please refer to the HS/Link documentation for more information.
REM Below is the setup we have found to give the best performance.
REM
REM HSLINK -P%1 -! -A -HS -UC:\BBS\UPLOADS.BBS
