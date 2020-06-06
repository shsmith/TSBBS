

(*
 * jobber - batch job monitor
 *
 * NOTE:  COMPILE WITH mIn AND mAx SET TO 200
 *
 *
 * This program will scan the '\jobs' directory for files containing
 * background job command lines.   Each file may contain 1 or more command
 * lines.  Each line in each job gets a new command processor.
 *
 * The jobber will delete a job file after running all of it's jobs.  It then
 * rescans the jobs directory for more jobs.   When there are no more jobs
 * pending, the jobber will exit.
 *
 * This program allows a more general batching facility under doubledos;
 * you can add new jobs while the jobber is running.  You can, of course,
 * delete pending jobs from the \jobs directory.
 *
 *
 * shs 6-feb-86
 *
 *)

{$C-   Don't check for ^C}
{$R-   Don't generate range checks}
{$V-   Allow variable length string parameters}

const
   reldate = '06-Feb-86';     {release date}
   lockfile = '\JOBBER.LCK';  {jobber lockfile}
   whoami = 'JOBBER';         {for error messages}

type
   anystring = string[200];

var
   command:            anystring;
   fd:                 text;
   i:                  integer;


{$I regpack.inc    Utility declaration of register package for msdos}
{$I subproc.inc   Utility to allow subprocesses}
{$I getfiles.inc   Utility to get file lists}



begin

   writeln;
   writeln('Jobber ',reldate);
   writeln;
   writeln('Background job monitor');
   writeln;

   assign(fd,lockfile);
{$I-}
   reset(fd);
{$I+}
   if ioresult = 0 then
   begin
      writeln('The lockfile ',lockfile,' is present.');
      writeln('Jobber is probably already running.');
      writeln;
      halt;
   end;

   rewrite(fd);
   close(fd);

   getfiles('\JOBS\*.*',filetable,filecount);

   while filecount <> 0 do
   begin

      writeln('Pending jobs:');
      for i := 1 to filecount do
         writeln('     ',filetable[i]);
      writeln;

      assign(fd,filetable[1]);
      reset(fd);
      readln(fd,command);
      close(fd);
      erase(fd);

      writeln('Job:  ',command);

      i := subprocess ('COMMAND.COM' + ' /C ' + command);
      writeln;

      if i <> 0 then
         writeln('Jobber:  subprocess error #', i);

      getfiles('\JOBS\*.*',filetable,filecount);
   end;

   writeln;
   writeln('End of Jobber run.');

   assign(fd,lockfile);
   erase(fd);
end.

