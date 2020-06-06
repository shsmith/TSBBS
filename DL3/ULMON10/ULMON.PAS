
(*
 * ulmon - monitor upload directory for free space
 *
 * This is a sysop utility program that will help monitor your upload
 * directory and keep disk space from running out.
 *
 * Samuel H. Smith, 23-dec-87 (rev. 07-jan-88)
 *
 *
 *)

uses Dos;

const
   whoami = 'Automatic Upload Space Monitor';
   version = 'Version 1.0b, 01-07-88';


{$I \tinc\anystring.inc}
{$I \tinc\atoi.inc}
{$I \tinc\sysdate2.inc}


procedure usage;
begin
   writeln;
   writeln(whoami,', ',version);
   writeln('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.');
   writeln;
   writeln('Usage:    ulmon KBYTES_FREE UPLOAD_LISTING UPLOAD_DIR [/batch]');
   writeln;
   writeln('Where:    KBYTES_FREE');
   writeln('             Specifies the number of K-bytes of free');
   writeln('             space to leave on the upload disk.');
   writeln('          UPLOAD_LISTING');
   writeln('             Specifies the full pathname of the file containing');
   writeln('             your upload directory listings.');
   writeln('          UPLOAD_DIR');
   writeln('             Is the directory where the upload files are stored.');
   writeln('          /batch');
   writeln('             Means to delete files without asking first.');
   writeln('             (SEE DOCUMENTATION BEFORE USING THIS OPTION!)');
   writeln;
   writeln('Example:  ulmon 750 c:\pcb\main\dir14 d:\upload /batch');
   writeln('   This example will delete files from d:\upload in the');
   writeln('   order that they are listed in c:\pcb\main\dir14 until');
   writeln('   there is at least 750k of space on drive d:.');
   halt;
end;


var
   query:       boolean;
   goal:        longint;
   uplist:      string;
   updir:       string;
   newlist:     string;
   baklist:     string;
   free:        longint;
   infd:        text;
   outfd:       text;
   inbuf:       array[1..10240] of byte;
   outbuf:      array[1..10240] of byte;
   line:        string;
   path:        string;
   yn:          string;
   i:           integer;
   fd:          file;

begin
   writeln;
   writeln(system_date,' ',system_time,' Automatic Upload Monitor Started');

{setup command line parameters}
   case paramcount of
      3:  query := true;
      4:  if paramstr(4) = '/batch' then
             query := false
          else
             usage;
      else
         usage;
   end;

   goal := atoi(paramstr(1));

   uplist := paramstr(2);
   newlist := uplist + '.new';
   baklist := uplist + '.bak';

   updir := paramstr(3);
   if updir[length(updir)] <> '\' then
      updir := updir + '\';

{see if any action is needed}
   free := DiskFree( ord(upcase(updir[1]))-ord('@') ) div 1024;
   write(free,'k free, goal: ',goal,'k in ',updir,'.  ');
   if free > goal then
   begin
      writeln('No action taken.');
      halt(0);
   end;

{need to delete some files - setup to scan the upload directory}
   writeln('Need to delete ',goal-free,'k.');
   writeln;

{setup input and output files}
   assign(infd,uplist);
   reset(infd);
   SetTextBuf(infd,inbuf);

   assign(outfd,newlist);
   rewrite(outfd);
   SetTextBuf(outfd,outbuf);


{check each line in the upload directory}
   while not eof(infd) do
   begin
      readln(infd,line);

      {if there is now enough free space, just copy lines}
      free := DiskFree( ord(upcase(updir[1]))-ord('@') ) div 1024;
      if free > goal then
         writeln(outfd,line)
      else

      {some space is needed - extract a filename and see if it exists}
      begin
         path := line + ' ';
         path := copy(path,1,pos(' ',path)-1);
         assign(fd,updir + path);

         {file exists - delete it and skip its line in the listing file}
         {$i-} reset(fd); {$i+}
         if ioresult <> 0 then
            yn := 'NO'

         else begin
            close(fd);
            writeln(line);
            if not query then
               yn := 'Y'
            else begin
               write('-- delete? <no> ');
               yn := '';
               readln(yn);
            end;
         end;

         if upcase(yn[1]) = 'Y' then
         begin
            erase(fd);
            if query then
               writeln('         *DELETED*');
         end
         else
            writeln(outfd,line);
      end;
   end;

{process complete, save a backup of upload listing and install new version}
   close(infd);
   close(outfd);

   assign(fd,baklist);
   {$i-} erase(fd); {$i+}
   if ioresult <> 0 then ;

   assign(fd,uplist);
   rename(fd,baklist);

   assign(fd,newlist);
   rename(fd,uplist);
end.


