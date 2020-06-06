rem Build list of all files to monitor
echo c:\ibmbio.com >files.lst
echo c:\ibmdos.com >>files.lst
where *.bat >>files.lst
where *.sys >>files.lst
where *.com >>files.lst
where *.exe >>files.lst
rem Determine initial CRC for all monitored files
ProCrc files.lst -U >files.crc
