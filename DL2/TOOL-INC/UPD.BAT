pkzip -u -! tool-inc *.dcl *.doc *.in? d.dat upd.bat
pkzip -u -! tool-pas *.pas
pkzip -f -! tool-use *.pas \pro\*.pas *.tpu
bac tool-inc.zip u:\dl2
bac tool-pas.zip u:\dl2
bac tool-use.zip u:\dl2
ufdir u:\pcb\gen\dldir2 u:\dl2
