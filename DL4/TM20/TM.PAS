
(*
 * tm - simple replacement for Norton's TM utility
 * S.H.Smith, 29-jan-89; public domain material.
 *
 *)

{$m 2000,0,0}
{$r-}

uses CRT,DOS;

procedure p2(c: char; n: integer);
begin
   write(c);
   if n < 10 then
      write('0');
   write(n);
end;

const
   days: array[0..6] of string[3] =
            ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

var
   i,j:        integer;
   par:        string;
   upar:       string;
   msg:        string;
   left:       boolean;
   prompt:     boolean;
   bare:       boolean;
   h,m,s,s100: word;
   d,y,dw:     word;

   procedure prompt_for_message;
   const
      timeout = 3 * 182;   {30 seconds}
   var
      clock:   longint absolute 0:$46c;
      start:   longint;
      res:     string;
      c:       char;
      con:     text;

   begin
      while keypressed do  {gobble keyahead}
         c := readkey;

      assign(con,'con');
      rewrite(con);
      res := '';
      write(con,msg,'? ');
      c := '?';

      start := clock;
      repeat
         if keypressed then
         begin
            c := readkey;
            if c = ^H then
            begin
               if res <> '' then
               begin
                  dec(res[0]);
                  write(con,^H' '^H);
               end;
            end
            else
            if c <> ^M then
            begin
               res := res + c;
               write(con,c);
            end;
         end
         else

         if clock > start+timeout then
            c := ^M;
      until c = ^M;

      if res <> '' then
         msg := res;

      writeln(con);
      close(con);
   end;

begin
   if paramcount = 0 then
   begin
      writeln('TM 2.3, Samuel H. Smith, Public domain material.');
      writeln('Usage:');
      writeln(' TM ''prompt'' /P [/LOG] [/L] >>outfile');
      writeln(' TM ''message'' [/LOG] [/L] [/BARE] >>outfile');
      halt(1);
   end;

   assign(output,'');
   rewrite(output);

   left := false;
   prompt := false;
   bare := false;
   msg := '';

   for i := 1 to paramcount do
   begin
      par := paramstr(i);
      upar := par;
      for j := 1 to length(upar) do
         upar[j] := upcase(upar[j]);

      if upar[1] = '/' then
      begin
         if (upar = '/L') then
            left := true
         else
         if (upar = '/P') then
            prompt := true
         else
         if (upar = '/BARE') then
            bare := true;
      end
      else

      if (upar = 'START') or (upar = 'STOP') or (upar = 'REPORT') then
      else
      if (par[1] = '''') or (par[1] = '"') then
         msg := par
      else
      if msg = '' then
         msg := par
      else
         msg := msg + ' ' + par;
  end;

   if (msg[1] = '"') or (msg[1] = '''') then
      msg := copy(msg,2,length(msg)-2);

   if prompt then
      prompt_for_message;

   if not left then
      while length(msg) < 56 do
         msg := ' ' + msg;

   if bare then
   begin
      write(msg);

      GetDate(y,m,d,dw);
      p2(' ',m); p2('-',d); p2('-',y-1900);

      GetTime(h,m,s,s100);
      p2(' ',h); p2(':',m);
   end
   else

   begin
      write(msg);

      GetTime(h,m,s,s100);
      p2(' ',h); p2(':',m); p2(':',s);

      GetDate(y,m,d,dw);
      write(', ',days[dw]);
      p2(' ',m); p2('-',d); p2('-',y-1900);
   end;

   writeln;
end.

