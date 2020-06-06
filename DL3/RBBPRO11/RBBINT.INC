
(*
 * RBBINT.INC - Read RBBS interface files (DORINFOx.DEF)
 *
 * S.H.Smith, 20-Dec-87
 *
 *)

var
   rbbs_name:      string;
   sysop_first:    string;
   sysop_last:     string;
   com_port:       string;
   parity:         string;  {format:  xxx BAUD,N,8,1}
   network_type:   integer; {format: ' 0'}
   first_name:     string;
   last_name:      string;
   city_state:     string;
   gr:             integer; {format: ' 1'}
   security_level: integer; {format: ' 6'}
   time_remaining: integer; {format: ' 70'}


procedure get_RBuser;
var
   fd:    text;

begin
   assign(fd,'DORINFO.DEF');
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      usage('Can''t open DORINFO.DEF');

   readln(fd,rbbs_name);
   readln(fd,sysop_first);
   readln(fd,sysop_last);
   readln(fd,com_port);
   readln(fd,parity);
   readln(fd,network_type);
   readln(fd,first_name);
   readln(fd,last_name);
   readln(fd,city_state);
   readln(fd,gr);
   readln(fd,security_level);
   readln(fd,time_remaining);
   close(fd);
end;


procedure fill_chars( var dest; source: anystring; size: integer );
var
   into:  array[1..1000] of char absolute dest;
   i:     integer;
   len:   integer;
begin
   len := length(source);
   if len > size then
      len := size;
   for i := 1 to len do
      into[i] := (source[i]);
   for i := len+1 to size do
      into[i] := ' ';
end;


procedure convert_to_pcb;
   (* convert contents of RBBS records into the similar pcb records *)
var
   str: anystring;
   p: integer;
begin

{default the pcbsys record}
   fillchar(pcbsys,sizeof(pcbsys),0);
   pcbsys.usernum := 1;            {only 1 record in "fake" users.pcb}
   pcbsys.display := '-1';         {enable display}
   pcbsys.printer := ' 0';         {disable printer logging}
   pcbsys.page_bell := '-1';       {enable page bell}
   pcbsys.alarm := '-1';           {enable beeping on console}
   fill_chars(pcbsys.password,'password',sizeof(pcbsys.password));
   ftos(get_time,pcbsys.time_on);
   ftos(get_time,pcbsys.open_time);
   fill_chars(pcbsys.time_logged,system_time,sizeof(pcbsys.time_logged));
   pcbsys.conference := 0;
   pcbsys.time_added := 0;
   ftod(1000000.0,pcbsys.down_limit);
   pcbsys.upload_credit := 0;
   pcbsys.errcheck := ' 0';


{default the user record}
   fillchar(user,sizeof(user),' ');
   user.conferences := '123456789';
   user.pagelen := 23;
   user.total_calls := 0;
   user.uploads := 0;
   user.downloads := 0;
   user.protocol := 'N';


{fill in information from RBBS files}
   fill_chars(pcbsys.firstname,first_name,sizeof(pcbsys.firstname));

   str := first_name + ' ' + last_name;
   fill_chars(pcbsys.name,str,sizeof(pcbsys.name));
   fill_chars(user.name,str,sizeof(user.name));
   fill_chars(user.city,city_state,sizeof(user.city));

   ftos(int(time_remaining)*60.0, pcbsys.time_limit);
   user.level := security_level;

   str := parity;
   p := pos('BAUD',parity);
   str := copy(parity,1,p-1);
   fill_chars(pcbsys.baud,str,sizeof(pcbsys.baud));

   if parity[p+5] <> 'N' then        {xxx BAUD,N,8,1}
      pcbsys.graphics := '7E'
   else
   if gr <> 0 then 
      pcbsys.graphics := '-1'         {enable color/graphics}
   else
      pcbsys.graphics := ' 0';


{missing details}

   str := '01-01-80';
   fill_chars(user.date,str,sizeof(user.date));  {mm-dd-yy}

   str := copy(str,7,2) + copy(str,1,2) + copy(str,4,2);
   fill_chars(user.filedate,str,sizeof(user.filedate));  {yymmdd}

end;


