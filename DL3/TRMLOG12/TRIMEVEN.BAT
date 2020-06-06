rem Event.sys sequence to automatically trim callers log to the last 21 days

trimlog 21 \pcb\main\caller \pcb\main\caller.tmp
if errorlevel 1 goto no_disk_space

del \pcb\main\caller
ren \pcb\main\caller.tmp caller

:no_disk_space
