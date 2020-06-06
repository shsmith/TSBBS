@ECHO OFF
echo Top level ProNet batch file

tm start /log /L 'Net mail started' >>pronet.err
del c:\tmp\*.arc
del c:\tmp\*.txt

mark
fakey ^M !G "pronet" ^M
telix
release

hstreset 1
tm report /log /L 'End of net mail run' >>pronet.err
echo. >>pronet.err

pkunpak c:\tmp\* c:\tmp
for %%f in (c:\tmp\*.txt) do c:\pcb\unarcm c:\pcb\unarcm.cnf c:\pcb %%f Agreed

