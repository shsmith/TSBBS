type
   readbas_bufrec = array[1..$2200] of char;
var
   readbas_buf: ^readbas_bufrec;
   curfd:       text;
const
   readbas_comment: char = '#';
