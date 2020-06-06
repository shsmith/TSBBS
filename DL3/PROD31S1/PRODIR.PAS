
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * PCB ProDOOR file directories user interface (3-1-89)
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProDir;

interface

   Uses
     Tools,
     ProData,
     ProRoot,
     ProScan,
     ProTran,
     ProView;


procedure display_dirmenu;
procedure display_dirn(n: integer);
procedure file_directories;


implementation


procedure display_dirmenu;
begin
   display_file(conf_info.conf_dirmenu);
end;

procedure display_dirn(n: integer);
begin
   get_dirn(n, par1, par2);
   display_dirfile(par1);
end;


procedure file_directories;
var
   i: integer;

begin
   if dir_count = 0 then
   begin
      not_available;
      exit;
   end;

   if cmdline = '' then
      display_dirmenu;

   while not dump_user do
   begin
      if cmdline = '' then
      begin
         newline;
         par5 := dir_count;
         get_defnh('Directory: (1-$5W$),',
                  '(V)iew, (D)ownload, (R)elist, ');
         if cmdline = '' then exit;
      end;

      get_nextpar;
      if par <> '' then

      case par[1] of
         'D':     begin
                     get_protocol(TX);
                     exit;
                  end;

         'F':     if par[2] = 'L' then
                     flag_files;

         'R':     display_dirmenu;

         'L':     dir_scan(by_name);
         'N':     dir_scan(by_date);
         'Z':     dir_scan(by_keyword);

         'V':     view_archive(length(par) = 1);  {no initial listing for VQ}

         '1'..'9':
                  display_dirn( parn );

         'U':     display_dirn( conf_dirs+1 );
      end;

     {if protocol = outside_batch then
         exit;}
   end;
end;


end.

