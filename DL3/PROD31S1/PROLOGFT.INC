
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
 * PCB ProDOOR file transfer logging (3-1-89)
 *
 *)

procedure log_file_transfer;
   {make a log entry for the previous file transfer as specified
    by the leftover doorfile}
type
   logfile_rec = record
      name:     filenames;
      descr:    string;
      size:     longint;
      speed:    real;
      effic:    real;
      failed:   boolean;
      errors:   integer;
   end;

   logfile_table = array[1..max_files] of logfile_rec;


var
   files:       ^logfile_table;
   nfiles:      integer;

   upload:      boolean;
   abnormal:    boolean;

   elapsed:     longint;
   started:     longint;

   tsize:       longint;
   teffic:      real;
   tspeed:      real;


   (*-----------------------------------------------------------------*)
   procedure add_file(path: filenames; desc: string);
      (* add a file to the transfer table; prevent duplication *)
   var
      fsize:   longint;
      k:       integer;

   begin
      stoupper(path);
      fsize := file_size(path);
{writeln('[add: fsize=',fsize:6,' path=',path,']');}

      (* prevent duplication *)
      for k := 1 to nfiles do
      with files^[k] do
         if name_only(path) = name_only(name) then
         begin
            if (length(desc) >= min_desc) then
               descr := desc;

            if upload or (fsize = 0) or (size = 0) then
               size := fsize;
{writeln('[add.update: size=',size:6,' descr=',descr,']');}
            exit;
         end;

      (* new table entry *)
      if nfiles < max_files then
         inc(nfiles);
      with files^[nfiles] do
      begin
         size   := fsize;
         name   := path;
         descr  := desc;
         {effic  := 0;
         speed  := 0;}
         failed := abnormal or (size = 0) or (speed = 0);
         if failed then errors := 99
         {else           errors := 0;}

{writeln('add.new: path=',path,' size=',size:0,' descr=',descr);}
      end;
   end;


   (*----------------------------------------------------------------*)
   procedure get_name_list;
   var
      i,j:   integer;
      d,n,e: filenames;

   begin
      for i := 1 to transfer.count do
      begin
         FSplit(transfer.entry[i]^,d,n,e);
         getfiles(d+n+'.*', filetable, filecount);

         if upload and (filecount = 0) then
         begin
            newline;
            par3 := ljust(remove_path(transfer.entry[i]^),15);
            dRED('Not Uploaded:   $3$   ');
            display_extended_description(descr.entry[i]^);
         end
         else

         for j := 1 to filecount do
            add_file(filetable[j]^, descr.entry[i]^);
      end;
   end;


   (*----------------------------------------------------------------*)
   procedure check_for_uploads;
      (* enter unsolicited uploads into the files list *)
   var
      i: integer;
   begin
      cons_path(dos_name,cnf.playpen_dir,'*.*');
      getfiles(dos_name, filetable, filecount);
      for i := 1 to filecount do
         add_file(filetable[i]^, '?');
   end;


   (*----------------------------------------------------------------*)
   procedure generate_logfile;
        (* no transfer log present, create one from the file directory
           information.  *)
   var
      i:    integer;

   begin

      if upload then
         check_for_uploads;

(* calculate overall efficiency and assign it to each file in the batch *)
      tsize := 0;
      for i := 1 to nfiles do
         tsize := tsize + files^[i].size;

(***
      if (tsize > 0) and (tsize < topcps * cnf.overhead) then
         tsize := trunc(topcps * cnf.overhead);
***)
      tspeed := tsize / int(elapsed);
      teffic := tspeed / topcps * 100;
      if (teffic > max_efficiency) then
         abnormal := true;

{writeln('generate_logfile: tspeed=',tspeed:0:1,' teffic=',teffic:0:2);}

      for i := 1 to nfiles do
      with files^[i] do
      {if speed = 0 then}
      begin
         effic := teffic;
         speed := tspeed;

         failed := abnormal or (size = 0) or (speed = 0);
         if failed then
            errors := 99
         else
            errors := 0;
      end;
   end;


   (*-----------------------------------------------------------------*)
   procedure get_transfer_log;
      (* load the file transfer execution log, if present *)
   var
      p:       integer;
      code:    char;
      
   begin

{if local then displn('get_transfer_log: doorlog_path='+doorlog_path);}
      if not dos_exists(doorlog_path) then
      begin
         (* no logfile present, simulate it *)
         {displn('[warning: cannot find '+doorlog_path+']');}
         get_name_list;
         generate_logfile;
         exit;
      end;


     (* logfile exists - load it *)
      openfile(doorlog_path);
      if not ok then
         exit;

      while not seekeof(curfd) do
      begin
         readln(curfd,cmdline);
         stoupper(cmdline);

         (* extract the filename portion of the log entry, skip error
            entries.   DSZ 0801 or later is required.  *)
               {1234567890123456789012345678901234567890123456789012345}
               {0        1         2         3         4         5}
               {Z  46532 38400 BPS 3324 CPS   0 ERRORS    66 1024 DSZ.COM 0}

         {make_log_entry(cmdline,false);}

         if nfiles < max_files then
            inc(nfiles);
         with files^[nfiles] do
         begin
            get_nextpar;   code := par[1];
            get_nextpar;   size := atol(par);
            get_nextpar;   {nnn}
            get_nextpar;   {'bps'}
            get_nextpar;   speed  := atof(par);
            get_nextpar;   {'cps'}
            get_nextpar;   errors := parn;
            get_nextpar;   {'errors'}
            get_nextpar;   {flow count}
            get_nextpar;   {block size}
            get_nextpar;   name := par; delete_trailing_spaces(name);
            get_nextpar;   {serial number}
            
            descr  := '';
            effic  := speed / topcps * 100.0;

            failed := (code = 'E') or (code = 'L') or 
                      (code = 'U') or (speed = 0) or (size = 0);

{write('[log: name=',name,' speed=',speed:0:1,' lsize=',size:0);}
            if upload then
            begin
               cons_path(name,cnf.playpen_dir,name);
               if failed then
                  size := 0
               else
                  size := file_size(name);
            end;

{writeln(' fsize=',size:0,']');}
{writeln(' log, name=',name,' size=',size:0,' d=',descr);}
         end;
      end;

      closefile;

      (* get upload descriptions if already entered *)
      if upload {or (nfiles = 0)} then
         get_name_list;
   end;


  (*-----------------------------------------------------------------*)
   procedure report_transfer_statistics;
      (* counts files transferred and reports transfer summary *)
   var
      i:        integer;
      entry:    anystring;

   begin

(* determine overall transfer size and efficiency *)
      tsize := 0;
      teffic := 0;
      for i := 1 to nfiles do
      with files^[i] do
      begin
         tsize  := tsize  + size;
         teffic := teffic + (effic * size);
         if (size = 0) and upload then
            dos_unlink(name);
      end;

      if tsize = 0 then
         teffic := 0
      else
         teffic := teffic / tsize;

      if (teffic > max_efficiency) then
      begin
         beep;
         displn(^X^X^X^X^X);
         newline;
         par3 := ftoa(tsize/topcps/60.0,0,1);
         dRED('+++ Error +++  Transfer should have taken at least $3$ minutes.');
         newline;

         abnormal := true;
         {teffic := max_efficiency;}
      end;

      tspeed := topcps * (teffic / 100);

      newline;
      displn(YELLOW);
      if tsize = 0 then
         displn('File transfer aborted!')
      else
         displn('File transfer completed.');
      {beep;}
      beep;

   (* report transfer summary *)
      entry := itoa(nfiles)+' files,  '+
               ltoa(tsize div 1024)+'k bytes,  '+
               ftoa(int(elapsed)/60.0,0,1)+' minutes,  '+
               ftoa(tspeed,0,1)+' cps,  '+
               ftoa(teffic,0,1)+' % efficiency';
      make_log_entry(entry,false);

      dCYAN('   '+ entry);
      beep;
      newline;
      newline;
   end;


   (*-----------------------------------------------------------------*)
   procedure get_upload_descriptions;
      (* prompt for descriptions on files needing them *)
   var
      i:      integer;
      prompt: string65;
      ask:    boolean;

   begin
      newline;
      ask := false;
      for i := 1 to nfiles do
         if (length(files^[i].descr) < min_desc) and (files^[i].size > 0) then
            ask := true;

      if ask then
      begin
         dGREEN('Please enter a description of this upload.');
         displn('  (Enter) alone to end.');
         displn('Begin description with (/) to make upload ''Private''.');
         disp_margin(30,45);
      end
      else
      begin
         dYELLOW('Uploaded files:');
         newline;
      end;

   (* check each file *)
      for i := 1 to nfiles do
      with files^[i] do
      if size > 0 then
      begin
         prompt := ljust(remove_path(name),12) +
                   ftoa(size,7,0) + ' ' +
                   system_date;

         (* list files that already have comments *)
         if (length(descr) >= min_desc) then
         begin
            newline;
            dCYAN(prompt);
            spaces(3);
            display_extended_description(descr);
         end
         else

         (* ask user for comments on files that don't have one yet *)
            get_upload_description(prompt+' ?',descr);
      end;

      newline;
   end;


   (*----------------------------------------------------------------*)
   procedure post_upload(i: integer);
      {post the specified file in the upload directory.
       involves moving file from the playpen_dir into the upload area,
       batch checking to make sure that it does not duplicate any other
       file, trashcan handling of invalid or duplicate uploads}
   var
      fname:   filenames;
      src:     filenames;
      dest:    filenames;
      priv:    boolean;
      cred:    longint;

      function unique_name: filenames;
         {form a unique filename based on time and date}
      begin
         unique_name := copy(system_date,4,3) + ftoa(get_time,0,2);
      end;

   begin
      with files^[i] do
      begin
         priv := descr[1] = '/';
         if conf_info.conf_private_ul then
            priv := true;

         fname := remove_path(name);
         dYELLOW('Checking '+fname+' ...');

         {see if the filename is OK for posting (not duplicate)}
         cons_path(src,cnf.playpen_dir,fname);

         {file is invalid}
         if size = 0 then
         begin
            dRED('   Invalid upload! (empty file)');
            newline;
         end
         else

         {file is valid}
         if ok_name(fname) then
         begin
            dGREEN('  Okay.');

            if priv then
               cons_path(dest,private_dir,fname)
            else
               cons_path(dest,upload_dir,fname);

            move_file(src,dest);

            dYELLOW('  Posted in @INCONF@');

            log_upload_name(upload_list,src,dest,size,descr);

            par3 := fname;
            par4 := pro_code;
            par5 := errors;
            par6 := trunc(speed);
            make_log_entry('(U) $3$ Completed using $4$  T/E=$5W$  CPS=$6W$',false);

            log_download('(U),'+username+','+
                           system_mm+'-'+system_dd+'-19'+system_yy+
                           ','+system_time+
                           ','+fname+','+ pro_code+
                           ', '+itoa(errors)+' , '+ftoa(speed,0,0));

            if priv then
               displn(' private dir.')
            else
               displn(' upload dir.');


            {credit the user with this upload}
            inc(user.uploads);
            incd( user.uptotal, size );

            {grant byte credit for uploads}
            cred := trunc(size * curctl.bytefact);  {cred<0}
            dec(user.earned_k,cred div 1024);
            if user.earned_k > 65000 then
               user.earned_k := 65000;
         end
         else

         {file is duplicate}
         begin
            {move into trashcan dir and log it, rename to unique name if needed}
            dRED('File moved to off-line holding area for screening by SYSOP.');
            newline;

            cons_path(dest,cnf.trashcan_dir,fname);
            if dos_exists(dest) then
               cons_path(dest,cnf.trashcan_dir,unique_name);

            move_file(src,dest);

            log_upload_name(cnf.trashcan_list,src,dest,size,descr);

            par3 := fname;
            par4 := pro_code;
            par5 := errors;
            make_log_entry('(U) $3$ Aborted using $4$  T/E=$5W$', false);
            newline;
         end;

      end;
   end;


   (*----------------------------------------------------------------*)
   procedure grant_upload_credit;
   begin
      {set adjustment interval to match the actual transfer duration}
      curstart := curstart - elapsed;
      adjust_timing;

      {tell the user if any extra time has been granted beyond the
       actual time uploading}
      last_adjustment := last_adjustment - (elapsed div 60);

      newline;

      if last_adjustment > 0 then
      begin
         dRED('Thanks $FIRST$!');
         newline;
         newline;
         par5 := last_adjustment;
         pdispln('Upload Time Credit:  $5W$ minutes');
      end;
   end;


   (*----------------------------------------------------------------*)
   procedure post_uploads;
      (* process a batch of uploads *)
   var
      i:     integer;

   begin
      get_upload_descriptions;

      for i := 1 to nfiles do
         post_upload(i);

      grant_upload_credit;
   end;


   (*-----------------------------------------------------------------*)
   procedure check_scratch(fname,against: filenames);
   begin
{writeln('[check fname=',fname,' against=',against,']');}

      if name_only(fname) = name_only(against) then
      begin
         dos_unlink(fname);

         inc(user.scratchnum);
         if name_only(against) = name_only(mailarc) then
         begin
            displn('Message pointers updated.');
            load_pointers(newptrfile);
         end;
      end;
   end;


   (*----------------------------------------------------------------*)
   procedure post_download(i: integer);
      {post a download in the log and download list}
   var
      fname:   filenames;
      downk:   integer;
      charge:  integer;

   begin
      with files^[i] do
      begin
         fname := remove_path(name);

         par3 := fname;
         par4 := pro_code;
         par5 := errors;
         if failed then
            make_log_entry('(D) $3$ Aborted using $4$  T/E=$5W$', true)
         else
         begin
            par3 := fname;

            (* check for free downloads *)
            if is_free_file(fname) then
               make_log_entry('Free download: $3$',true)
            else

            (* download is to be charged *)
            begin
               inc( user.downloads );
               incd( user.downtotal, size );
               incd( user.downbytes, trunc(size*curctl.bytefact) );

               (* charge against earned credit if needed *)
               downk := dtol(user.downbytes) div 1024;
               if downk > pcbsys.down_limit then
               begin
                  charge := downk - pcbsys.down_limit;
                  pcbsys.down_limit := downk;
                  if user.earned_k < charge then
                     user.earned_k := 0
                  else
                     dec(user.earned_k, charge);
               end;

               par3 := fname;
               par4 := pro_code;
               par5 := errors;
               par6 := trunc(speed);
               make_log_entry('(D) $3$ Completed using $4$  T/E=$5W$  CPS=$6W$', true);
            end;

            log_download('(D),'+username+','+
                           system_mm+'-'+system_dd+'-19'+system_yy+
                           ','+system_time+ ','+fname+','+ pro_code+
                           ', '+itoa(errors)+' , '+ftoa(speed,0,0));

            check_scratch(fname,scratcharc);
            check_scratch(fname,mailarc);
         end;
      end;
   end;


   (*----------------------------------------------------------------*)
   procedure post_downloads;
      (* process a batch of downloads *)
   var
      i:  integer;
   begin
      for i := 1 to nfiles do
         post_download(i);
   end;


   (*-----------------------------------------------------------------*)
   procedure get_transfer_info;
   var
      ov:   longint;
      fun:  char;
   begin
      abnormal := (option = o_logerr);

      protocol := atoi(paramstr(4));
      upload := (pro_mode = RX);
      if pro_files <> 1 then
         if upload then fun := fun_batchul else
                        fun := fun_batchdl
      else
         if upload then fun := 'U' else
                        fun := 'D';
      set_function(fun);

      started := atol(paramstr(5));
      elapsed := lget_time - started;
      if elapsed<0 then
         elapsed := elapsed+86400;      (* convert if midnight crossover *)

      ov := trunc(cnf.overhead);
      elapsed := elapsed - ov;
      if elapsed < ov then
         elapsed := ov;

   end;


(*-----------------------------------------------------------------*)
begin {log_file_transfer}

   linenum := -30000;           {force non-stop mode}
   display_resultfile;          {display the arc-test result, if present}
   newline;

   dos_getmem(files,sizeof(files^));
   fillchar(files^,sizeof(files^),0);

   get_transfer_info;           {get details about transfer time, protocol}

   load_name_list;              {load contents of door.nam into transfer.*}
                                {gets d/l list or u/l list w/descriptions}

   nfiles := 0;
   get_transfer_log;            {load the transfer log, simulate if needed}

   report_transfer_statistics;  {report a summary of files transferred}

   if nfiles > 0 then
   begin

      if not upload then
      begin
         post_downloads;

         {switch to upload mode in case of bimodem-type protocols}
{writeln('pro_command=',pro_command);}
         if is_wild(pro_command)=false then
         begin
            nfiles := 0;
            cnf.protocol_table[protocol].mode := RX;
            cnf.protocol_table[protocol].files := 0;
            upload := true;
         end;
      end;

      if upload then
      begin
         check_for_uploads;
         if nfiles > 0 then
            post_uploads;
      end;

      view_profile;
      newline;
   end;
   
   dos_freemem(files);
   clean_playpen;
end;

