
(*
 * balance - balance out differences between two systems
 *
 * s.h.smith, 26-may-87
 *
 *)

#include <anystring.inc>
#include <tolower.inc>

var
   dups:        text;
   diff:        text;
   lst1:        text;
   lst2:        text;
   new1:        text;
   new2:        text;
   id1:         anystring;
   id2:         anystring;
   basedate:    anystring;
   date1:       anystring;
   date2:       anystring;
   name1:       anystring;
   name2:       anystring;
   line:        anystring;


procedure usage;
begin
   writeln;
   writeln('Balance v1.0 (LAST_UPDATE SHS)');
   writeln;
   writeln('usage:  balance SINCE_DATE SINCE_TIME DIFFERENCES ');
   writeln;
   writeln('where:  SINCE_DATE is the newest date to overwrite, YY/MM/DD format');
   writeln('        SINCE_TIME is the newest time to overwrite, HH:MM:SS format');
   writeln('        DIFFERENCES is a difference-list filename (made by CSTAMP)');
   writeln;
   writeln('output: <id1>.lst - lists files on <id1> that can be copied to system2');
   writeln('        <id1>.new - lists files on <id1> only');
   writeln('        <id2>.lst - lists files on <id2> that can be copied to system1');
   writeln('        <id2>.new - lists files on <id2> only');
   writeln('        DUPS.lst  - lists possible duplicate updated files');
   halt;
end;


procedure init;
   {initialization}
begin
   if paramcount <> 3 then
      usage;

   basedate := paramstr(1) + ' ' + paramstr(2);
   assign(diff,paramstr(3));
   reset(diff);

   assign(dups,'dups.lst');
   rewrite(dups);

   id1 := '';
   id2 := '';
   name1 := '';
   name2 := '';
   date1 := '';
   date2 := '';
end;


procedure cleanup(var name: anystring);
var
   p: integer;
begin
   repeat
      p := pos(' ',name);
      if p <> 0 then
         delete(name,p,1);
   until p = 0;
end;


procedure copyfrom(var fd:    text);
begin
   writeln(fd,name1);
   name1 := '';
   name2 := '';
end;


procedure duplicate;
begin
   if (name1 = '') or (name2 = '') then
      exit;

   writeln(dups,'duplicate: ');
   writeln(dups, id1:8,' ',date1,' ',name1);
   writeln(dups, id2:8,' ',date2,' ',name2);
   writeln(dups);
   name1 := '';
   name2 := '';
end;


procedure check_line;
var
   date:  anystring;
   name:  anystring;
   id:    anystring;

begin
   id := copy(line,1,8);
   cleanup(id);
   date := copy(line,11,17);
   name := copy(line,38,64);
   cleanup(name);
   {writeln('name=<',name,'>  id=<',id,'>  date=<',date,'>');}

   {init the two identifiers and open files}
   if id1 = '' then
   begin
      id1 := id;
      assign(lst1,id + '.lst');
      rewrite(lst1);
      assign(new1,id + '.new');
      rewrite(new1);
   end
   else

   if (id2 = '') and (id1 <> id) then
   begin
      id2 := id;
      assign(lst2,id + '.lst');
      rewrite(lst2);
      assign(new2,id + '.new');
      rewrite(new2);
   end;

   {update the proper file variables}
   if id = id1 then
   begin
      if name1 <> '' then
         writeln(new1,name1);
      date1 := date;
      name1 := name;
   end
   else

   if id = id2 then
   begin
      if name2 <> '' then
         writeln(new2,name2);
      date2 := date;
      name2 := name;
   end

   else
      writeln(dups,'unknown id: ',line);

end;


begin
   init;

   repeat
      {grab the file info}
      readln(diff,line);

      if length(line) > 38 then
      begin

      check_line;

      if name1 = name2 then         {if file names match}

         if date1 > date2 then          {if 1 newer}
            if date2 < basedate then       {and 2 is old}
                  copyfrom(lst1)               {then copy 1}
            else  duplicate                    {else 2 is duplicate}

         else                          {else if 2 newer}
            if date1 < basedate then       {and 1 is old}
                  copyfrom(lst2)               {then copy 2}
            else  duplicate;                   {else 1 is duplicate}
      end;

   until eof(diff);

   close(diff);
   close(lst1);
   close(lst2);
   close(new1);
   close(new2);
   close(dups);
end.
