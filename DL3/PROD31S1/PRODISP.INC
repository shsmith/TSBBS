
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
 * PCB ProDOOR display text files library (3-1-89)
 *
 *)

procedure display_file_raw(name: filenames;
                           form: display_formats);
   {display the specified file.  handles special cases for
    graphics files and missing files}

const
   bufsize = $3000;
   linelen = 128;    {used to be 120?}

type
   bufarray = array[1..bufsize] of char;
var
   buf:        ^bufarray;
   fd:         dos_handle;
   uname:      filenames;
   c:          char;
   line:       string;
   bufpos:     integer;
   endbuf:     integer;
   lnum:       integer;


   procedure out_line;
   begin
      prepare_line(line);

      {disable status line while outputting cursor-handling ansi files}
      if (length(line) > 3) and (line[1] = #27) and
         (line[2] = '[') and ((line[4] = 'J') or (line[3] = 'u')) then
      begin
         FullScreen;
         status_active := false;
         linenum := 0;
      end;

      disp(line);
      line := '';
   end;

   procedure try(add: string10);
   begin
      if uname = '' then
      begin
         uname := name + add;
         if not dos_exists(uname) then
            uname := '';
      end;
   end;


begin
   if nomore = true then
      exit;

   {append G to filename for graphics version}
   uname := '';
   if graphics then
   begin
      try('G' + language);
      try('G');
   end;
   try(language);
   try('');
   if uname = '' then
      exit;

   {don't display anything if neither file is available}
   fd := dos_open(uname,open_read);
   if fd = dos_error then
   begin
    { par := uname;
      not_available; }
      exit;
   end;

   default_color;

   {file found; display it, no line length limit}
   line := '';
   endbuf := 0;
   bufpos := 1;
   lnum := 0;
   dos_getmem(buf,bufsize);

   repeat
      ansi_ccolor := '';   {forget previous current color}

      if bufpos > endbuf then
      begin
         buf^[1] := ^Z;     {in case of eof}
         bufpos := 1;
         endbuf := dos_read(fd,buf^,bufsize);
      end;

      c := buf^[bufpos];
      inc(bufpos);

      case c of
         ^J:  ;

         ^M:  begin
                  inc(lnum);

                  case form of
                  dir_colorize:
                     begin
                        displn_dir(line);
                        line := '';
                     end;
                     
                  remove_semicolons:
                     begin
                        if line[1] = ';' then
                           line[1] := ' ';
                        prepare_line(line);
                        displn(line);
                        line := '';
                     end;

                  number_lines:
                     begin
                        str(lnum:3,par);
                        displn(par+': '+line);
                        line := '';
                     end;
                         
                  else 
                     begin
                        out_line;
                        newline;
                     end;
                 end;
                 
                 if nomore then
                    endbuf := 0;
              end;

         ^Z:  begin
                 out_line;
                 endbuf := 0;
              end;

         else begin
                 inc(line[0]);
                 line[length(line)] := c;

                 case length(line) of
                    {disable automatic color if file has escape codes in it}
                    1: if (form=dir_colorize) and (line[1] = #27) then
                          form := display_normal;
 
                    {output partial buffers for very long lines}
                    linelen..255:
                       out_line;
                 end;
              end;
      end;

   until endbuf = 0;

   out_line;
   dos_close(fd);
   dos_freemem(buf);
   update_status_display(normal_format);
end;


procedure display_file(name: filenames);
   {display the specified text file.  handles special cases for
    graphics files and missing files}
begin
   display_file_raw(name,display_normal);
end;


procedure display_dirfile(name: filenames);
begin
   display_file_raw(name,dir_colorize);
end;



(* ------------------------------------------------------------ *)
procedure display_resultfile;
   {display the resultfile from archive testing; remove pathnames from
    all lines; detect invalid archives and delete them}
var
   i:    integer;
   name: filenames;
   line: string;

begin
   default_color;
   if not dos_exists(result_path) then
      exit;

   beep;
   openfile(result_path);
   if not ok then exit;

   qReadLn(curfd,line,sizeof(line));
   while (line[1] <> ^Z) and ((option <> o_none) or (nomore = false)) do
   begin
      for i := 1 to length(line) do
         case line[i] of
            '/': line[i] := '\';
         end;


      (* delete invalid archives! *)
      i := pos(cnf.badarc_keymsg,line);
      if i > 0 then
      begin
         i := posc(' ',line);
         name := copy(line,1,i-1);
{writeln('[bad file detected, name=',name,' path=',path_only(name),' play=',cnf.playpen_dir,']');}
         if path_only(name) = cnf.playpen_dir then
         begin
            dos_unlink(name);
            make_log_entry('Invalid file ('+remove_path(name)+') deleted!',true);
         end;
      end;

      prepare_line( line );

      (* parse lines and remove any pathnames if needed *)
      i := posc('\',line);
      if i = 0 then
         disp( line )
      else

      while length(line) > 0 do
      begin
         while (length(line) > 0) and (line[1] = ' ') do
         begin
            space;
            delete(line,1,1);
         end;

         disp( remove_path(scan_nextpar(line)) );
         space;
      end;

      newline;
      qReadLn(curfd,line,sizeof(line));
   end;

   closefile;

   dos_unlink(result_path);
   update_status_display(normal_format);
end;



