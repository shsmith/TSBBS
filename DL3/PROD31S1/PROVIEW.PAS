
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
 * ProView - Archive textview/extract module             (3-1-89)
 *           Uses external programs for all functions.
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProView;

interface

Uses
   Dos, MdosIO, Tools, ProData, ProRoot, ProTran;

   procedure view_archive(table: boolean);

implementation

   var
      arcfile:       anystring;
      selection:     anystring;


   (* ------------------------------------------------------------- *)
   procedure prepare_selection;
   begin
      selection := '';

      while length(cmdline) > 0 do
      begin
         get_nextpar;
         if length(selection) > 0 then
            selection := selection + ' ';
         selection := selection + remove_path(par);
      end;
   end;


   (* ------------------------------------------------------------- *)
   procedure extfile;
   begin
      if not verify_level(fun_xtract) then
         exit;

      if length(cmdline) = 0 then
      begin
         get_defen('Member file(s) to extract:');
         newline;
         if dump_user then exit;
      end;

      prepare_selection;
      if length(selection) = 0 then exit;

      make_log_entry('Extract member ('+selection
                               +') from ('+remove_path(arcfile)
                               +')',true);

      execute(cnf.xtract_command+' '+arcfile+' '+scratcharc+' '+selection);

      autoflag_scratch;           {flag scratch/zipm files for dl}
   end;


   (* ------------------------------------------------------------- *)
   procedure viewfile;
   begin
      if not verify_level(fun_textview) then
         exit;
      if length(cmdline) = 0 then
      begin
         get_defen('Member text file(s) to view:');
         newline;
         if dump_user then exit;
      end;

      prepare_selection;
      if length(selection) = 0 then exit;

      make_log_entry('View member ('+selection
                               +') from ('+remove_path(arcfile)
                               +')',true);

      execute(cnf.typetext_command+' '+arcfile+' '+selection);
   end;


   (* ------------------------------------------------------------- *)
   procedure listfiles;
   begin
      make_log_entry('View executed on file ('+remove_path(arcfile)+')',true);
      execute(cnf.listing_command+' '+arcfile);
   end;


   (* ------------------------------------------------------------- *)
   procedure view_archive(table: boolean);
   begin
      if not verify_level(fun_arcview) then exit;

      (* select the archive (checks stacking, adds .arc and default) *)
      select_archive('VIEW');
      if length(par) = 0 then
         exit;
      arcfile := par;

      if table then
         listfiles;

      cmdline := '';
      while true do
      begin
         if length(cmdline) = 0 then
         begin
            newline;
            display_time_left;
            par3 := remove_path(arcfile);
            pdispln('Viewing contents of $3$');

            get_defnh('Action:','(V)iew text, (X)tract, (R)elist, ');
            if (length(cmdline) = 0) or dump_user then
               exit;
            newline;
         end;

         get_nextpar;
         case upcase(par[1]) of
            'R':  listfiles;
            'V':  viewfile;
            'E':  extfile;
            'X':  extfile;
         end; {case}

      end; {while}
   end;

end.

