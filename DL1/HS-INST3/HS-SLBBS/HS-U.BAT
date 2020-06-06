@ECHO OFF
HSLINK -P%1 -! -UC:\BBS\UPLOADS.BBS @C:\FILE.TMP
REM
REM Explanation of switches...
REM
REM                 -P%1 : Tells HS/Link which com port to use
REM
REM                   -! : Makes the remote system conform to your setup
REM
REM -UC:\BBS\UPLOADS.BBS : Tells HS/Link to put any received files in this 
REM                        directory.  You MUST have this line for 
REM                        bi-directional transfers to work properly.  
REM                        SLBBS makes the UPLOADS.BBS directory off of 
REM                        your bbs root directory.
REM
REM         @C:\FILE.TMP : This line tells HS/Link where the list of files 
REM                        to be transfered is located and its name.  This 
REM                        MUST match what is in your config.
REM
REM There are some additions to these command line parameters that can be
REM made.  The configuration we have found to give the best performance is
REM below.  Our setup is for BBS's running with locked com ports using the
REM 16550 UART and 9600 Bps modems or HST's.
REM
REM HSLINK -P%1 -! -A -HS -UC:\BBS\UPLOADS.BBS @C:\FILE.TMP
