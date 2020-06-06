
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
 * PCB ProDOOR download directory searching (3-1-89)
 *
 *)


function valid_filename(name: filenames): boolean;
   (* test a specified filename for validity, return false if it is
      invalid (also prints a message to that effect *)
var
   i,valid:  integer;
   wild:     boolean;

begin
   {count the number of valid, non-wildcard characters in the filename.
    don't count the extention (because .ARC would make anything valid)}

   wild := false;
   valid := 0;

   i := 1;
   while (i <= length(name)) and (name[i] <> '.') do
   begin
      if name[i] = '*' then
         wild := true
      else
      if name[i] = '?' then
         wild := true
      else
         inc(valid);

      inc(i);
   end;

   {check for invalid filename characters}
   i := 1;
   while (i <= length(name)) do
   begin
      case name[i] of
         '\','|','/',';',':','>','<',',',#0..' ','~'..#255:
            begin
               valid := 0;
               par3 := name[i];
               pdispln('You can''t use "$3$" in a filename!');
            end;
      end;
      inc(i);
   end;

   if wild and (valid < 1) then
   begin
      displn('Too ambiguous!  Please specify at least 1 non-wild character.');
      valid := 0;
   end;

   if valid > 8 then
   begin
      displn('Too long!  Only 8 letters, please.');
      valid := 0;
   end;

{if setdebug then 
writeln(dbfd,'valid=',valid,' name=[',name,']');}

   if valid < 1 then
   begin
      make_log_entry('(' + name + ') is an invalid filename!',true);
      valid_filename := false;
   end
   else
      valid_filename := true;

end;



(* --------------------------------------------------------------- *)
procedure find_file(target:      filenames;
                    files:       integer);
   {attempt to locate the specified file based on the
    available file directories.  list matching files in 'select'}
var
   i:       integer;
   free:    boolean;

   procedure check_size(name: filenames);
   var
      size:       longint;
      ksize:      integer;
      elapsed:    real;
      i:          integer;
      nleft:      integer;

   begin
      if (length(name) = 0) then
         exit;

      free := is_free_file(name);

      if (transfer.count >= files) then
      begin
         displn('Too many files selected!');
         ok := false;
      end;

      for i := 1 to transfer.count do
         if transfer.entry[i]^ = name then
         begin
            displn('File already in the list!');
            ok := false;
         end;

{if setdebug then displn(' [FOUND: '+name+'] ');}
      size := file_size(name);
      ksize := (size+1023) div 1024;
      elapsed := estimated_time(size);
      nleft := minutes_left - trunc(estimated_time(transize+size));

      {when downloading, the file must exist}
      if pro_mode = TX then
      begin

         if ksize = 0 then
         begin
            make_log_entry('Empty files cannot be downloaded!',true);
            ok := false;
         end;

         if (not free) and (k_left < ksize) then
         begin
            make_log_entry('Not enough download bytes remaining!',true);
            ok := false;
         end;

         if nleft < 0 then
         begin
            make_log_entry('Not enough time remaining!',true);
            ok := false;
         end;

         if ok then
         begin
            inc(transfer.count);
            savestr(transfer.entry[transfer.count], name);
            transize := transize + size;
            k_left := k_left - ksize;
            mins_left := nleft;
         end;
      end;

      dCYAN (rjust(itoa(ksize),6) + 'k,' +
             ftoa(elapsed+0.1,6,1)+' min.  ' + remove_path(name));

      if ok then
      begin
         inc(files_found);
         disp(' - Ok');
         if free then
            disp(' (Free download)');
         newline;
      end
      else
      begin
         beep;
         displn(' - Rejected');
      end;
   end;


   procedure check_directory(dir: string);
   var
      path:    filenames;
      j:       integer;

   begin
      {expand the wildcard into individual file names}
      cons_path(path,dir,target);
      getfiles(path,filetable,filecount);
      ok := true;
      if filecount = 0 then
         exit;

      {verify legal file access for downloading}
      if pro_mode = TX then
         for j := 1 to filecount do
         begin
            ok := file_allowed(filetable[j]^,pcbsetup.fsec_path^);
            if not ok then
               exit;
         end;

      {process listed files}
      for j := 1 to filecount do
         if ok and (nomore=false) then
            check_size(filetable[j]^);
   end;


begin
   files_found := 0;
   if not valid_filename(target) then
      exit;

   if files = 0 then
      files := max_files;

   if not is_wild(target) then
      files := transfer.count+1;

   {check each of the file directories}
   for i := 1 to download_table.count do
   begin
      check_directory(download_table.entry[i]^);
      if (transfer.count >= files) or (not ok) then
         exit;
   end;

   if files_found = 0 then
   begin
      {check for private upload duplication}
      if pro_mode = RX then
         check_directory(private_dir)
      else  {download file not found}
         file_not_found(target);
   end;

end;



(* --------------------------------------------------------------- *)
function ok_name(target: filenames): boolean;
   {is the specified filename ok for the selected protocol?
    return the exact name if it is}
begin
   if not valid_filename(target) then
   begin
      ok_name := false;
      exit;
   end;

   {check all extensions during uploading}
   if pro_mode = RX then
      dos_name := remove_ext(target) + '.*'
   else
      dos_name := target;
{writeln('target=',dos_name);}

   {search download directories; verify against FSEC}
   find_file(dos_name,pro_files);   {giving files_found and transfer[]}

   {when downloading, the file must exist}
   if pro_mode = TX then
   begin
      ok_name := files_found > 0;
      exit;
   end;

   {log a duplicate upload attempt}
   if files_found > 0 then
   begin
      make_log_entry('('+target+') duplicates a current board file.',true);
      ok_name := false;
   end
   else

   {when uploading, the file must not exist in ANY directory,
    and must not conflict with UPSEC specifications}
   if not file_allowed(target, pcbsetup.upsec_path^) then
      ok_name := false
   else
      ok_name := true;
end;


(* ----------------------------------------------------------- *)
procedure set_scratch_type;
begin
   scratcharc := remove_ext(scratcharc) + ext_only('Z'+par);
(***
   scratchname := remove_path(scratcharc);
***)
end;


(* ----------------------------------------------------------- *)
(*
 * select an archive file for processing
 *
 * appends .arc if needed
 * provided default from previous archive
 *
 * returns par='' if failure
 * else par = selected path
 *)

procedure select_archive(action: string30);
begin

   (* prompt for archive name if none specified *)
   if length(cmdline) = 0 then
   begin
      newline;
      get_defen('Enter the filename to '+action+':');
   end;

   (* get the archive name and add the default extention *)
   get_nextpar;
   if (length(par) = 0) or (par = 'Q') or dump_user then
   begin
      par := '';
      exit;
   end;

   (* add default extention *)
   if posc('.',par) = 0 then
      par := par + dotpak;

   (* locate the file *)
   newline;
   dGREEN('Checking ... ');
   newline;

   transfer.count := 0;
   k_left := 10000;
   transize := -1000000;
   find_file(par,1);
   if files_found = 0 then
   begin
      par := '';
      exit;
   end;

   par := transfer.entry[transfer.count]^;
   set_scratch_type;
end;

