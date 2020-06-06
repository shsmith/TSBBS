const
   maxnumfiles =  200;
   null =         #0;
type
   filestring =   string [64];
   filearray =    array [1.. maxnumfiles] of filestring;
var
   filetable:     filearray;
   filecount:     integer;
