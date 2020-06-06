
type
   readbas_bufrec = array[1..$2200] of char;

var
   curfd:               text;
   readbas_name:        filenames;
   readbas_count:       integer;

const
   readbas_comment:     char = '#';
   readbas_buf:         ^readbas_bufrec = nil;

