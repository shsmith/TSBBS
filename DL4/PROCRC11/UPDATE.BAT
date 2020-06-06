rem Update CRC for all monitored files
copy files.crc files.lst
ProCrc files.lst -U >files.crc
