rem NOTE: THIS FILE MUST BE EDITED FOR YOUR SYSTEM CONFIGURATION!
echo off
J:
cd \prod
set extuser=u:\prod\extuser
set confinfo=u:\prod\confinfo
proedit J:\pcb4 -C -R -U -Q %1 %2 %3 %4 %5 %6 %7 %8 %9
