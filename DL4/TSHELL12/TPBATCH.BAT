echo off
break on

echo !
echo ! tpbatch - turbo pascal batch compile
echo !           under double-dos

if .%1 == . goto usage

keyahead M%1^MOCI200^MQCQ
tshell BTURBO.COM
goto exit

:usage
echo !
echo ! usage: tpbatch MAINAME       ;to compile MAINAME.pas

:exit


