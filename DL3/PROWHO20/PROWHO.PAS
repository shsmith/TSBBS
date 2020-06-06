
(*
 * ProWho.PAS - Door to answer the question: Who uploaded that file?
 *
 * (C) 1988 Samuel H, Smith (05-Feb-88)
 *
 *)

{$M 12000,12000,12000}  {Stack, minheap, maxheap}
{$V-}                   {Relax string rules}

Program WhoUploaded;

{$i prokit.inc}    {include standard 'uses' statement}

const
   version = 'ProWho v2.0, 04-27-92 (C)1991 S.H.Smith';

   shortest = 2;        {shortest search key allowed}

var
   buffer:              array[1..20480] of char;

   driver:              string;   {driver type; taken care of automatically}
   download_file:       string;   {download listing file}
   welcome_file:        string;   {welcome message file}
   menu_file:           string;   {main menu file}
   close_file:          string;   {closing message file}


(* ---------------------------------------------------------------- *)
procedure load_info;
   {load the latest configuration file}
var
   fd: text;
begin
   assignText(fd,config_file);
   reset(fd);
   readln(fd,driver);
   readln(fd,download_file);
   readln(fd,welcome_file);
   readln(fd,menu_file);
   readln(fd,close_file);
   close(fd);
end;


(* ---------------------------------------------------------------- *)
procedure locate_file(name: string);
   {$i \tinc\bline.inc}
var
   table:  Btable;
   fd:     text;
   line:   string;
   uline:  string;
   i:      longint;
   recs:   longint;
   downs:  longint;
   ups:    longint;
   hits:   longint;

   procedure scanfile;
   begin
      MakeTable(name,table);

      while true do
      begin
         qReadLn(fd,line,sizeof(line));
         if dump_user or (line[1] = ^Z) then exit;

         inc(recs);
         if (recs mod 300) = 0 then
         begin
            if nomore then exit;
            disp('.');
         end;

         i := BMsearch(line[1],length(line), table, name);
         if i > 0 then
         begin
            if nomore then exit;

            displn(^M+aWHITE+copy(line,1,i-1)+
                      aRED  +name+
                      aWHITE+copy(line,i+length(name),255));

            inc(hits);
            if pos('(U)',uline) > 0 then inc(ups);
            if pos('(D)',uline) > 0 then inc(downs);
         end;

      end;
   end;

begin
   AssignText(fd,download_file);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      displn(aRED+'Can''t access data file.  Sorry!');
      exit;
   end;

   SetTextBuf(fd,buffer);
   downs := 0;
   ups := 0;
   hits := 0;
   recs := 0;
   stoupper(name);
   make_log_entry('Searching for ('+name+') ...',true);
   newline;

   scanfile;

   close(fd);
   newline;

   disp(aGREEN+ltoa(recs)+' entries scanned, '+ltoa(hits)+' matches');
   if ups > 0 then   disp(', '+ltoa(ups)+' uploads');
   if downs > 0 then disp(', '+ltoa(downs)+' downloads');
   displn('.');

   newline;
end;


(* ---------------------------------------------------------------- *)
procedure main_menu;
   {main procedure}
begin

   repeat
      force_enter;
      display_file(menu_file);

      display_time_left;
      disp('Enter the Text to Scan for: (Q)=quit? ');

      get_cmdline;              {get cmdline, map to upper case}
      newline;

      if cmdline = 'Q' then
         exit;

      if length(cmdline) < shortest then
         displn('Please enter a longer search key!')
      else
      if is_wild(cmdline) then
         displn('Wildcards won''t work!  Use keywords only.')
      else
         locate_file(cmdline);

   until dump_user or (minutes_left < 1);

end;


(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}

   newline;
   displn(version);

   progname := 'ProWho';    {program name on status line, must be 7 characters}
   load_info;               {load info from config file}

   display_file(welcome_file);

   main_menu;              
   display_file(close_file);

   uninit;   {must be last - closes com port and updates database}
end.

