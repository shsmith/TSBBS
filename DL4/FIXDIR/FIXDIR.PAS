
(*
 * FixDir - Remove various automatic entries from PCB dir files
 *
 * Written by Samuel H. Smith, 12-18-93
 *
 *)

{$v-}
uses DOS,qread;

const
   version   = 'FixDir 1.1, 02-10-94';

   dizit_prefix = '                               |                                      -> DizIt';
   dlcnt_prefix = '                               | Download Count: ';
   ulby_prefix  = '                               | Uploaded by: ';
   files_prefix = '                               | Files: ';
   fwkcs_prefix = ' @X80                              | zcs|';
   files_key = ' files - New:';

   remove_dizit:  boolean = true;
   remove_dlcnt:  boolean = true;
   remove_ulby:   boolean = false;
   remove_files:  boolean = true;
   remove_higr:   boolean = false;
   remove_blank:  boolean = true;
   remove_dashes: boolean = false;
   remove_fwkcs:  boolean = true;

var
   ibuf:    array[1..20480] of byte;
   obuf:    array[1..20480] of byte;

type
   filenames = string[65];


(* --------------------------------------------------------- *)
procedure update_dirfile(infile: filenames);
var
   tmpfile: filenames;
   bakfile: filenames;
   ifd:     text;
   ofd:     text;
   line:    string;
   tmp:     string;
   d,n,e:   filenames;
   skip:    boolean;
   i:       integer;
   first:   boolean;
   fname:   boolean;

begin
   writeln('Fixing ',infile,' ...');

   fsplit(infile,d,n,e);
   tmpfile := d+n+'.TMP';
   bakfile := d+n+'.BAK';

   assign(ifd,infile);
   {$i-} reset(ifd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open input file ',infile);
      exit;
   end;

   assign(ofd,tmpfile);
   {$i-} rewrite(ofd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t create temp file ',tmpfile);
      exit;
   end;

   setTextBuf(ifd,ibuf);
   setTextBuf(ofd,obuf);
   first := true;

   repeat
      qreadln(ifd,line,sizeof(line));

      i := pos('.',line);
      fname := (i > 1) and (i < 10);
      skip := first;

      if remove_dizit and not skip then
         skip := (copy(line,1,length(dizit_prefix)) = dizit_prefix);

      if remove_dlcnt and not skip then
         skip := (copy(line,1,length(dlcnt_prefix)) = dlcnt_prefix);

      if remove_ulby  and not skip then
         skip := (copy(line,1,length(ulby_prefix)) = ulby_prefix);

      if remove_fwkcs and not skip then
         skip := (copy(line,1,length(fwkcs_prefix)) = fwkcs_prefix);

      if remove_files and not skip then
         skip := (copy(line,1,length(files_prefix)) = files_prefix) or
                 (pos(files_key,line) > 32);

      if remove_blank and not skip then
         skip := ((length(line) < 35) and (copy(line,32,1) = '|'));

      if remove_higr and not skip then
         for i := 1 to length(line) do
            case line[i] of
               #0..#31, #127..#255:
                  line[i] := ' ';
            end;

      if remove_dashes and not skip then
         repeat
            i := pos('----',line);
            if i = 0 then
               i := pos('====',line);
            if i = 0 then
               i := pos('****',line);
            if i = 0 then
               i := pos('....',line);
            if i > 32 then
               delete(line,i,1);
         until i <= 32;

      {leave title lines alone}
      if first then
         skip := false;

      {never remove filename lines}
      if fname then
      begin
         skip := false;
         first := false;
      end;

      if not skip then
         writeln(ofd,line);
   until eof(ifd);

   close(ifd);
   close(ofd);

   assign(ifd,bakfile);
   {$i-} erase(ifd); {$i+}
   if ioresult <> 0 then ;

   assign(ifd,infile);
   {$i-} rename(ifd,bakfile); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t rename ',infile,' to ',bakfile);
      exit;
   end;

   assign(ifd,tmpfile);
   {$i-} rename(ifd,infile); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t rename ',tmpfile,' to ',infile);
      exit;
   end;

end;


(* --------------------------------------------------------- *)
procedure option_usage(minus: boolean; kw: string; action: string);
begin
   write('           -',kw,'  Strip ',action);
   if minus then write(' (* default)');
   writeln;

   write('           +',kw,'  Keep  ',action);
   if not minus then write(' (* default)');
   writeln;
end;


(* --------------------------------------------------------- *)
procedure usage;
begin
   writeln('Usage:    FixDir [OPTIONS] DIRFILENAME ...');
   writeln;
   writeln('Options:');
   option_usage(remove_blank, 'BL','blank lines');
   option_usage(remove_dashes,'DA','strings of dashes');
   option_usage(remove_dizit, 'DI','"->DizIt" lines');
   option_usage(remove_dlcnt, 'DL','"Download Count" lines');
   option_usage(remove_files, 'FI','"Files:" and "files - New:" lines');
   option_usage(remove_higr,  'HI','high graphic characters');
   option_usage(remove_ulby,  'UL','"Uploaded By" lines');
   option_usage(remove_fwkcs, 'FW','lines added by FWKCS');
   writeln;
   writeln('Example:  FixDir -UL -FI -BI +DL C:\PCB\MAIN\UPLOAD');
   halt(99);
end;


(* --------------------------------------------------------- *)
procedure update_dirfiles;
type
   fname_ptr = ^fname_node;
   fname_node = record
      fname: filenames;
      next:  fname_ptr;
   end;

var
   DirInfo:       SearchRec;
   list:          fname_ptr;
   node:          fname_ptr;
   i,j:           integer;
   d,n,e:         filenames;
   skip:          boolean;
   tf:            boolean;

begin
   list := nil;

   for i := 1 to paramcount do
   begin
      n := copy(paramstr(i),1,3);
      for j := 1 to length(n) do
         n[j] := upcase(n[j]);

      if (n[1] = '+') or (n[1] = '-') then
      begin
         tf := n[1] = '-';
         delete(n,1,1);
         if n = 'DI' then remove_dizit  := tf else
         if n = 'DL' then remove_dlcnt  := tf else
         if n = 'UL' then remove_ulby   := tf else
         if n = 'FW' then remove_fwkcs  := tf else
         if n = 'FI' then remove_files  := tf else
         if n = 'HI' then remove_higr   := tf else
         if n = 'BL' then remove_blank  := tf else
         if n = 'DA' then remove_dashes := tf
         else
         begin
            writeln('Invalid option: ',n);
            usage;
         end;
      end

      else
      begin
         fsplit(paramstr(i),d,n,e);
         FindFirst(paramstr(i),$21,DirInfo);
         while (DosError = 0) do
         begin
            new(node);
            node^.fname := d+DirInfo.name;
            node^.next := list;
            list := node;
            FindNext(DirInfo);
         end;
      end;
   end;

   node := list;
   while node <> nil do
   begin
      update_dirfile(node^.fname);
      node := node^.next;
   end;
end;


(* --------------------------------------------------------- *)
begin
   writeln;
   writeln(version,';  Copyright 1993 Samuel H. Smith');
   writeln;

   if paramcount < 1 then
      usage;

   update_dirfiles;
end.

