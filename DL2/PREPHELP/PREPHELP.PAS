
(*
 * PrepHelp - Prepare Help File
 *            Supporting utility for Helpme unit.
 *
 * Written by S.H.Smith, 3-14-89
 * Copyright 1989 Samuel H. Smith
 * Copyright 1989 Omnicraft, Inc.
 *
 *)

{$i prodef.inc}
{$m 8000,0,0}

uses Helpme;

var
   infd:    text;
   ofd:     text;
   obuf:    array[1..20000] of byte;

   key:     array[1..maxkey] of keyword_rec;
   keys:    integer;

   line:    string;
   loc:     word;

var
   sub:     array[1..maxsub] of string[keylen];
   subkey:  array[1..maxsub] of byte;
   subs:    integer;


(* ---------------------------------------------------------- *)
procedure parse_sub;
var
   p: integer;
begin
   while copy(line,1,1) = ' ' do
      delete(line,1,1);
   p := pos(' ',line);
   if p = 0 then
      p := length(line)+1;

   if subs < maxsub then
      inc(subs);

   sub[subs] := copy(line,1,p-1);
   line := copy(line,p+1,255);

   for p := 1 to length(sub[subs]) do
      if sub[subs][p] = '_' then
         sub[subs][p] := ' ';
end;



(* ---------------------------------------------------------- *)
procedure build_keywords;
var
   maxlen:  integer;
   nlines:  integer;

begin
   keys := 0;
   loc := 3;
   while not eof(infd) do
   begin
      readln(infd,line);

      if copy(line,1,2) = '--' then    {define keyword}
      begin
         if keys > 0 then
         begin
            key[keys].width := maxlen;
            key[keys].lines := nlines;
            inc(loc,9);
         end;

         nlines := 0;
         line := copy(line,3,255);
         subs := 0;
         parse_sub;

         inc(keys);
         key[keys].id := sub[1];
         key[keys].loc := loc;

         maxlen := 13;
         subs := 0;
         while line <> '' do
         begin
            parse_sub;
            inc(maxlen,3+length(sub[subs]));
         end;

      end
      else

      if copy(line,1,1) <> ';' then
      begin                            {plain text}
         inc(nlines);
         if length(line) > maxlen then
            maxlen := length(line);
         inc(loc,length(line)+1);
      end;
   end;

   if keys > 0 then
   begin
      key[keys].width := maxlen;
      key[keys].lines := nlines;
      inc(loc,9);
   end;
end;


(* ---------------------------------------------------------- *)
procedure generate_keytab;
var
   i:       integer;
   ocol:    integer;

   procedure put(c: byte);
   begin
      if ocol > 72 then
      begin
         writeln(ofd);
         write(ofd,'      ');
         ocol := 6;
      end;
      write(ofd,c:3,',');
      inc(ocol,4);
   end;

begin

   writeln(ofd);
   writeln(ofd,'{Generated from ',paramstr(1),' by PrepHelp}');
   writeln(ofd);

   writeln(ofd,'const');
   writeln(ofd,'   keyword_count = ',keys,';');
   writeln(ofd);

   writeln(ofd,'   keyword_table: array[1..keyword_count] of keyword_rec = (');
   for i := 1 to keys do
   begin
      write(ofd,'      {',i:2,
                  '}  (loc: ',key[i].loc:5,
                  ';  width: ',key[i].width:2,
                  ';  lines: ',key[i].lines:2,
                  ';  id: ''',key[i].id,''')');

      if i = keys then
         writeln(ofd,' );')
      else
         writeln(ofd,',');
   end;

   writeln(ofd);
   write(ofd,'   help_text: array[1..',loc-1,'] of byte = (');
   ocol := 99;

   reset(infd);
   while not eof(infd) do
   begin
      readln(infd,line);

      if copy(line,1,2) = '--' then    {refer to keyword}
      begin
         line := copy(line,3,255);
         subs := 0;
         parse_sub;

         ocol := 99;
         put(1); put(0);     {#0 = end of topic}
         write(ofd,'  {',subkey[1],' - ',sub[1],'}');

         subs := 0;
         while line <> '' do
         begin
            parse_sub;
            subkey[subs] := 0;
            for i := 1 to keys do
               if sub[subs] = key[i].id then
                  subkey[subs] := i;
            if subkey[subs] = 0 then
            begin
               writeln('unknown subtopic(',subs,'): ',sub[subs]);
            end;
         end;

         ocol := 99;
         for i := 1 to maxsub do
            if i > subs then
               put(0)
            else
               put(subkey[i]);

         ocol := 99;
      end
      else

      if copy(line,1,1) <> ';' then
      begin                            {plain text}
         inc(loc,length(line)+1);
         put(length(line));
         for i := 1 to length(line) do
            put(ord(line[i]));
      end;
   end;

   ocol := 99;
   put(1);
   writeln(ofd,'  0 );');
   writeln(ofd);
   writeln(ofd,'procedure help(x,y,key: integer);');
   writeln(ofd,'begin');
   writeln(ofd,'   help_on_tap(1,x,y,key,keyword_table,help_text); ');
   writeln(ofd,'end;');
   writeln(ofd);

end;


(* ---------------------------------------------------------- *)
begin
   if paramcount <> 2 then
   begin
      writeln('usage: prephelp infile outfile');
      halt(99);
   end;

   assign(infd,paramstr(1));
   {$i-} reset(infd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('can''t open helpfile: ',paramstr(1));
      halt(99);
   end;

   build_keywords;

   assign(ofd,paramstr(2));
   {$i-} rewrite(ofd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('can''t create output: ',paramstr(2));
      halt(99);
   end;

   setTextBuf(ofd,obuf);

   generate_keytab;

   close(infd);
   close(ofd);
end.
