

(*
 * GMAKE - Generic Global Make
 *
 * This program will operate on a a list of files selected by global
 * filename characters (wildcards).  The operations and relationships
 * are defined on the command line.
 *
 * A set of default parameters can be placed into the file GMAKE.DEF
 * to simplify command line typing.
 *
 * author: s.h.smith, 27-mar-86
 *
 * typical usage would be:
 *   gmake *.lib .sym janus @.lib /sc/w >batch.bat
 *   gmake *.pkg .jrl janus @.pkg /sc/w >>batch.bat
 *   batch
 *
 * revision history:
 *    27-mar-86 shs - derived from exmake "compiled" utility
 *
 *)
{$p512,d-}


program generic_global_make;
const
   reldate =           'Generic Global Make,  S.H.Smith 27-Mar-86';
                              {release date}

type
   anystring =         string [80];


{$I \shs\tools\regpack.inc  Utility declaration of register package for msdos}
{$I \shs\tools\getfiles.inc Utility to get file lists}
{$I \shs\tools\filedate.inc Utility to get file modification date}



procedure usage;
begin
   writeln(con);
   writeln(con, reldate);
   writeln(con);
   writeln(con,'Usage:  gmake PATTERN EXT COMMAND');
   writeln(con);
   writeln(con,'PATTERN is a wildcard file list to be scanned.');
   writeln(con);
   writeln(con,'EXT     is the comparison file extention.  Action is taken');
   writeln(con,'        when FILE.EXT is older than the file matching PATERN.');
   writeln(con);
   writeln(con,'COMMAND is the command action.  The @ sign will be replaced');
   writeln(con,'        with the base filename that is out of date.');
   writeln(con);
   writeln(con);
   writeln(con,'Example:');
   writeln(con,'   gmake *.lib .sym janus @.lib /sc/w >batch.bat');
   writeln(con,'   gmake *.pkg .jrl janus @.pkg /sc/w >>batch.bat');
   writeln(con,'   batch');
   writeln(con);
   halt;
end;


procedure update_file (base_name:          anystring;
                       template:           anystring);
var
   p:                  integer;
   command:            anystring;

begin
   writeln(con, 'Update: ', base_name);
   command := template;


(* replace all '@' signs with the base filename *)
   p := pos ('@', command);

   while p > 0 do
   begin
      command := copy (command, 1, p - 1)+ base_name +
                 copy (command, p + 1, length (command));
      p := pos ('@', command);
   end;


(* generate the command *)
   writeln(command);
end;


var
   base_name:          anystring;
   out_of_date:        boolean;
   command_template:   anystring;
   i:                  integer;
   updates:            integer;

begin

   if paramcount < 3 then
      usage;


(* build the command template *)
   command_template := '';

   for i := 3 to paramcount do
   begin
      command_template := command_template + paramstr (i);

      if i < paramcount then
         command_template := command_template + ' ';
   end;


(* search for all files matching pattern in first paramters, make a list
   of them in filetable.  filecount is the count of matched files.  *)

   getfiles(paramstr (1), filetable, filecount);
   updates := 0;


(* process each listed file *)

   for i := 1 to filecount do
   begin


(* get the filename from the filetable and strip of the filetype *)
      base_name := filetable [i];

      if pos ('.', base_name)> 0 then
         base_name := copy (base_name, 1, pos ('.', base_name)- 1);



(* check to see if the file is up to date *)
      out_of_date := filedate (filetable [i]) >
                     filedate (base_name + paramstr (2));

      if out_of_date then
      begin
         updates := updates + 1;
         update_file(base_name, command_template);
      end;
   end;


   if updates = 0 then
      writeln(con, 'No updates needed.');
end.