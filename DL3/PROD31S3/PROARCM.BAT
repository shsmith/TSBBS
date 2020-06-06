echo off
rem. process message ZIPM request - for ProDOOR 3.1
rem. %1-logfile, %2-mailarc, %3-mailtext
chkpath pkzip %0 >>%1
pkZIP -es -m %2 %3 >>%1
pkZIP -v %2 >>%1
