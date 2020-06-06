copy %1 %1.old
fixdir -ul -hi -da +fi %1
copy %1 %1.bak
del %1
pdc %1.bak %1
