
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
 * Build download list and upload directory information.  (3-1-89)
 * Also loads conference-specific doors file.
 *
 *)

procedure build_download_list;

{$IFDEF IN_PROEDIT}
begin

{$ELSE}
   (* build download directory table, upload directory, upload
      filelist, private filelist; take conferences into account *)

   procedure add( dir: anystring );
      (* add a directory to the download table; prevent duplication *)
   var
      k:    integer;

   begin
      (* change D:DIR into D:\pcb\DIR *)
      if (dir[2] = ':') and (dir[3] <> '\') then
         if dir[1] = sys_dir[1] then
            cons_path(dir,sys_dir,copy(dir,3,99));

      (* prevent duplication *)
      for k := 1 to download_table.count do
         if dir = download_table.entry[k]^ then
            exit;

      if (dir = cnf.playpen_dir) or (dir = cnf.scratch_dir) then
         abort_program('Temp directory ['+dir+'] MUST *NOT* be in download path list!');

      if download_table.count >= max_dir then
         abort_program('Too many download dirs ['+dir+']');

      (* new table entry *)
      inc(download_table.count);
      savestr(download_table.entry[download_table.count], dir);
   end;

var
   path:    string;
   inconf:  boolean;
   i:       integer;

begin
   (* start list with the scratch directory *)
   download_table.count := 1;
   savestr(download_table.entry[1], cnf.scratch_dir);

   get_infocount(conf_info.conf_dirinfo, 96, conf_dirs);

   private_dir := conf_info.conf_private_updir;
   private_list := conf_info.conf_private_uplist;

   if conf_info.conf_private_ul then
   begin
      upload_dir := private_dir;
      upload_list := private_list;
   end
   else
   begin
      upload_dir := conf_info.conf_updir;
      upload_list := conf_info.conf_public_uplist;
   end;

   openfile(conf_info.conf_dlinfo);
   if not ok then exit;

   conf_dlpaths := 0;
   while not endfile do
   begin
      inc(conf_dlpaths);
      getline(path,30);
      add( path );
   end;
   closefile;

{$ENDIF}

   {use .nnn (conference number) based message files when no
    alternate language is being used}

   if pcbsys.slanguage[1] = ' ' then
      language := '.' + itoa(user.curconf);
end;

