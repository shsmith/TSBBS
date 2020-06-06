
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
 * PCB ProDOOR prepare macro lines (expand macros) (3-1-89)
 *
 *)

(*********************
Substitute '@' Commands
-----------------------
This version will begin to support many '@' substitute text commands.
When the code encounters one of the commands below in a text string
for display, it will replace the command with the corresponding
data from the system.  Note that the commands must be entered in
caps in order to function.

   @BOARDNAME@     - the name of your BBS
   @BYTELIMIT@     - bytes allowed from PWRD file
   @BYTESLEFT@     - remaining bytes available for download for that day
   @CITY@          - city and state of caller (all caps)
   @DATAPHONE@     - caller's business/data phone number
   @DAYBYTES@      - bytes downloaded so far that day
   @DLBYTES@       - total bytes downloaded - all calls
   @DLFILES@       - total files downloaded - all calls
   @EXPDATE@       - subscription expiration date
   @FIRST@         - first name of the user (first letter captialized)
   @HOMEPHONE@     - caller voice phone number
   @INCONF@        - conference the caller is currently in
   @LASTDATEON@    - last date on (mm-dd-yy format)
   @LASTTIMEON@    - last time on (hh:mm format)
   @NUMTIMESON@    - number of times on system
   @SECURITY@      - users current security level including conf. add.
   @SYSDATE@       - host date in (mm-dd-yy format)
   @SYSTIME@       - host system in in (hh:mm format)
   @TIMELEFT@      - time remaining that call incl. all credits, etc.
   @TIMELIMIT@     - time allowed from PWRD file
   @TIMEUSED@      - minutes used since logon
   @UPBYTES@       - total bytes uploaded - all calls
   @UPFILES@       - total files uploaded - all calls
   @USER@          - complete name of the caller (first & last - all caps)
**************)

procedure prepare_line(var line: string);
const
   nrep = 19+25;
   repid:  array[1..nrep] of string[12] = (
            '$3$',         {temp- par3}
            '$4$',         {temp- par4}
            '$5W$',        {temp- par5 word}
            '$6W$',        {temp- par6 word}
            '$7L$',        {temp- par7 longint}
            '$8S$',        {temp- par8 single}
            '$C$',         {connect bps}
            '$B$',         {modem open baud rate}
            '$N$',         {port number 0=local, 1..4}
            '$R$',         {result filename for batches}
            '$@$',         {file list pathname for dsz}
            '$FIRST$',     {callers first name}
            '$SCRATCH$',   {scratch file name}
            '$MAIL$',      {mail file name}
            '$SYSOP$',     {sysop name}
            '$NAME$',      {callers full name =- @USER@}
            '$CONF$',      {conference number with mail waiting}
            '$TIME$',      {minutes left}
            '$NODE$',      {current node number}

            '@BOARDNAME@', {the name of your BBS}
            '@BYTELIMIT@', {bytes allowed from PWRD file}
            '@BYTESLEFT@', {remaining bytes available for download for that day}
            '@CITY@',      {city and state of caller (all caps)}
            '@DATAPHONE@', {caller's business/data phone number}
            '@DAYBYTES@',  {bytes downloaded so far that day}
            '@DLBYTES@',   {total bytes downloaded - all calls}
            '@DLFILES@',   {total files downloaded - all calls}
            '@EXPDATE@',   {subscription expiration date}
            '@FIRST@',     {first name of the user (first letter captialized)}
            '@HOMEPHONE@', {caller voice phone number}
            '@INCONF@',    {conference the caller is currently in}
            '@LASTDATEON@',{last date on (mm-dd-yy format)}
            '@LASTTIMEON@',{last time on (hh:mm format)}
            '@NUMCALLS@',  {total number of callers in system}
            '@NUMTIMESON@',{number of times on system}
            '@SECURITY@',  {users current security level including conf. add.}
            '@SYSDATE@',   {host date in (mm-dd-yy format)}
            '@SYSTIME@',   {host system in in (hh:mm format)}
            '@TIMELEFT@',  {time remaining that call incl. all credits, etc.}
            '@TIMELIMIT@', {time allowed from PWRD file}
            '@TIMEUSED@',  {minutes used since logon}
            '@UPBYTES@',   {total bytes uploaded - all calls}
            '@UPFILES@',   {total files uploaded - all calls}
            '@USER@');     {complete name of the caller (first & last - all caps)}
var
   rep:  integer;

   procedure nextrep(r: anystring); {replace next identifier in repid list}
   begin
      delete_trailing_spaces(r);
      if delete_variables then
         r := '(deleted)';
      replace_string(line,repid[rep],r);
      inc(rep);
   end;

   procedure nextint(i: integer);
   begin
      nextrep(itoa(i));
   end;

begin
   if (posc('$',line) = 0) and (posc('@',line) = 0) then
      exit;

   rep := 1;
   {the order of these nextrep calls must match the order of the identifiers
    declared above.  this is an ugly hack but it cuts quite a lot from the
    size of the generated code}

   nextrep(par3);
   nextrep(par4);
   nextrep(wtoa(par5));
   nextrep(wtoa(par6));
   nextrep(ltoa(par7));
   nextrep(stoa(par8));

   nextrep(pcbsys.connectbps);
   nextrep(pcbsys.openbps);
   nextint(com_chan+1);
   nextrep(result_path);
   nextrep('@'+sys_dir+'\$DOOR.NAM');
   nextrep(first_name);
   nextrep(scratchname);
   nextrep(mailname);
   nextrep(pcbsetup.sysop_name^);
   nextrep(username);
   nextint(user.mailconf);
   nextint(pcbsys.sminsleft);
   nextrep(pcbsetup.node_number^);

   nextrep(pcbsetup.system_name^);
   nextrep(ltoa(longint(pcbsys.down_limit)*1024));
   nextrep(ltoa(longint(download_k_allowed)*1024));
   nextrep(user.city);
   nextrep(user.busphone);
   nextrep(dtoa(user.downbytes));
   nextrep(dtoa(user.downtotal));
   nextint(user.downloads);
   nextrep(expdate(user.expdate));
   nextrep(first_name);
   nextrep(user.phone);
   nextrep(conf_info.conf_name);
   nextrep(expdate(user.date));
   nextrep(user.time);
   nextrep('{numcalls}');
   nextint(user.total_calls);
   nextint(userlevel);
   nextrep(system_date);
   nextrep(system_time);
   nextint(pcbsys.sminsleft);
   nextint(pcbsys.time_limit);
   nextint(time_used);
   nextrep(dtoa(user.uptotal));
   nextint(user.uploads);
   nextrep(username);
end;


procedure prepare_protocol_table;
   (* process each protocol table entry to fix references to
    baud rate and com port *)
var
   i,k:   integer;
   temp:  string;

begin
   for i := 1 to cnf.protocol_count do
      with cnf.protocol_table[i] do
      begin
         temp := command^;
         prepare_line(temp);
         savestr(command,temp);
      end;
end;


procedure remove_variables(var line: string);
begin
   delete_variables := true;
   prepare_line(line);
   delete_variables := false;
end;


