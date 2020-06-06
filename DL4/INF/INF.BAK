
(*
 * inf - playing with inferences
 * shs 7-oct-85
 *
 *)

{$r+,u+}

type
   anystring  = string[255];
   factstring = string[40];

   factrecptr = ^factrec;
   factptr    = ^factlist;
   rulerecptr = ^rulerec;
   ruleptr    = ^rulelist;


   {what we know about a fact}
   factrec = record
      desc:     factstring;   {description of the fact}
      istrue:   boolean;      {is the fact true?}
      known:    boolean;      {is the fact known?}
      byif:     ruleptr;      {list of rules that need this fact}
      bythen:   ruleptr;      {list of rules that can deduce this fact}
   end;

   {a list of facts}
   factlist = record
      fact:     factrecptr;    {the fact}
      next:     factptr;       {the next item in the list}
   end;

   {what we know about a rule}
   rulerec = record
      iflist:    factptr;      {list of facts that must be true}
      thenlist:  factptr;      {list of facts that can be deduced}
      istrue:    boolean;      {is it already known that the rule is true?}
   end;

   {a list of rules}
   rulelist = record
      rule:     rulerecptr;    {the rule}
      next:     ruleptr;       {the next item in the list}
   end;


var
   title:  anystring;      {the title for this set of tules}
   facts:  factptr;        {all of the facts}
   rules:  ruleptr;        {all of the rules}

   fd:      text;          {current read/write file}
   reading: boolean;       {are we loading from a file?}

   c:       char;
   line:    anystring;
   saved:   boolean;



{ask the user if a fact is true or false}
procedure askfact(var fact: factrec;  why: anystring);
begin
   repeat
      writeln;
      write('Is this true:   ',fact.desc,'   (?/Yes/No/Skip)? ');
      read(kbd,c);
      c := upcase(c);
      writeln(c);

      if c = '?' then
         writeln(why);

      if c = 'S' then
         exit;

   until c in ['Y','N'];

   fact.istrue := (c = 'Y');
   fact.known  := true;
end;


procedure determinefact(new_fact: factrecptr; why: anystring); forward;


{use a rule to make a deduction}
procedure userule(cur_rule:  rulerecptr; why: anystring);
var
   cur_fact: factptr;
   ruletrue: boolean;
   ruleneeded: boolean;
begin

   why := why + '/prove '+cur_rule^.thenlist^.fact^.desc;

   with cur_rule^ do
   begin
      if istrue then
         exit;

      {if all deductions are already true, then don't try to prove}
      cur_fact := thenlist;
      ruleneeded := false;

      {for each fact that can be deduced}
      while (cur_fact <> nil) do
      with cur_fact^.fact^ do
      begin
         {tell the user if this is a deduction that was not known before}
         if not known then
            ruleneeded := true;

         cur_fact := cur_fact^.next;
      end;

      if not ruleneeded then
         exit;


      {for each fact needed by this rule}
      ruletrue := true;
      cur_fact := iflist;

      while (cur_fact <> nil) and ruletrue do
      with cur_fact^.fact^ do
      begin
         if (not known) then
            determinefact(cur_fact^.fact,why);

         if (not istrue) or (not known) then
            ruletrue := false
         else
            cur_fact := cur_fact^.next;
      end;


      {if all needed facts were true, then trigger deductions}
      if ruletrue then
      begin
         cur_rule^.istrue := true;  {remember that this rule is true}
         cur_fact := thenlist;

         {for each fact that can be deduced}
         while (cur_fact <> nil) do
         with cur_fact^.fact^ do
         begin
            {tell the user if this is a deduction that was not known before}
            if not known then
            begin
               known := true;
               istrue := true;
               writeln;
               writeln('Deduction: ',desc);
            end;

            cur_fact := cur_fact^.next;
         end;
      end;

   end;

end;




{try to prove a fact is true}
procedure determinefact; {(new_fact: factrecptr; why: anystring);}
var
   cur_rule:       ruleptr;

begin

   {if fact is known already, then nothing to do}
   if new_fact^.known then
      exit;

   why := why + '/determine '+new_fact^.desc;

   {use each rule that can deduce this fact until the fact is known}
   cur_rule := new_fact^.bythen;

   {if there is no way to deduce the fact, then ask for it}
   if cur_rule = nil then
   begin
      askfact(new_fact^,why);
      exit;
   end;

   {try each rule looking for this deduction}
   while (cur_rule <> nil) and (not new_fact^.known) do
   begin
      userule(cur_rule^.rule,why);
      cur_rule := cur_rule^.next;
   end;
end;



{try all rules and see if any new facts can be deduced}
procedure deduce;
var
   cur_rule:   ruleptr;
   deductions: boolean;
   why:        anystring;

begin
   why := 'deduce';

   repeat
      deductions := false;

      {walk through all rules looking for any that can be proven}
      cur_rule := rules;

      while (cur_rule <> nil) do
      with cur_rule^ do
      begin
         if not rule^.istrue then
         begin
            userule(rule,why);
            if rule^.istrue then
               deductions := true;
         end;

         cur_rule := cur_rule^.next;
      end;

   until deductions = false;

end;




{list the facts in a fact list}
procedure list_facts(first: factptr);
var
   cur_fact: factptr;

begin
   cur_fact := first;

   while cur_fact <> nil do
   with cur_fact^.fact^ do
   begin
      write('   ',desc);
      if known then
         write(' (',istrue,')');

      writeln;
      cur_fact := cur_fact^.next;
   end;
end;




{list all of the facts and rules}
procedure list_all;
var
   cur_rule: ruleptr;

begin
   writeln;
   writeln('All Facts:');
   list_facts(facts);

   writeln;
   writeln('All Rules:');
   cur_rule := rules;

   while cur_rule <> nil do
   with cur_rule^.rule^ do
   begin
      writeln('If these facts are true:');
      list_facts(iflist);

      writeln('Then these facts can be deduced:');
      list_facts(thenlist);
      writeln;

      cur_rule := cur_rule^.next;
   end;

   writeln;

end;




{allow operator to specify a fact; creates new facts when needed}
function specify_fact: factrecptr;
var
   cur:      factptr;
   newfact:  factptr;

begin
   repeat
      if reading then
      begin
         readln(fd,line);
         while (length(line) > 1) and (line[1] = ' ') do
            line := copy(line,2,99);
      end
      else

      begin
         write('> ');
         readln(line);
      end;

      if (line = '') or (line = 'THEN') or (line = 'END') then
      begin
         specify_fact := nil;
         exit;
      end;

      cur := facts;
      while cur <> nil do
      begin
         if cur^.fact^.desc = line then
         begin
            specify_fact := cur^.fact;
            exit;
         end;

         cur := cur^.next;
      end;


      {new rule - create it and leave}
      new(newfact);
      newfact^.next := facts;
      facts := newfact;

      new(facts^.fact);
      with facts^.fact^ do
      begin
         known  := false;
         istrue := false;
         desc   := line;
         byif   := nil;
         bythen := nil;
      end;

      specify_fact := facts^.fact;
      exit;

   until true=false;
end;




{add new rules to the rule list}
procedure add_rule;
var
   newrule:  ruleptr;
   cur_fact: factrecptr;
   rlist:    ruleptr;
   flist:    factptr;

begin
   new(newrule);
   newrule^.next := rules;
   rules := newrule;

   new(rules^.rule);
   with rules^.rule^ do
   begin
      istrue := false;

      if not reading then
      begin
         writeln('List the facts that must be true.');
         writeln('Enter a blank fact to end the list.');
      end;

      iflist := nil;
      cur_fact := specify_fact;

      while cur_fact <> nil do
      begin
         new(flist);
         flist^.next := iflist;
         iflist := flist;
         iflist^.fact := cur_fact;

         new(rlist);
         rlist^.next := cur_fact^.byif;
         cur_fact^.byif := rlist;
         rlist^.rule := rules^.rule;

         cur_fact := specify_fact;
      end;

      if not reading then
      begin
         writeln;
         writeln('List the facts that can be deduced.');
         writeln('Enter a blank fact to end the list.');
      end;

      thenlist := nil;
      cur_fact := specify_fact;

      while cur_fact <> nil do
         begin
         new(flist);
         flist^.next := thenlist;
         thenlist := flist;
         thenlist^.fact := cur_fact;

         new(rlist);
         rlist^.next := cur_fact^.bythen;
         cur_fact^.bythen := rlist;
         rlist^.rule := rules^.rule;

         cur_fact := specify_fact;
      end;

   end;
end;




{write the facts in a fact list to output file}
procedure write_facts(first: factptr);
var
   cur_fact: factptr;

begin
   cur_fact := first;

   while cur_fact <> nil do
   with cur_fact^.fact^ do
   begin
      writeln(fd,'   ',desc);
      cur_fact := cur_fact^.next;
   end;
end;



{write all of the facts and rules to the output file}
procedure write_all;
var
   cur_rule: ruleptr;

begin
   writeln(fd,'TITLE');
   writeln(fd,title);
   writeln(fd);

   writeln(fd,'FACTS');
   write_facts(facts);

   writeln(fd);
   writeln(fd,'RULES');

   cur_rule := rules;

   while cur_rule <> nil do
   with cur_rule^.rule^ do
   begin
      writeln(fd);
      writeln(fd,'IF');
      write_facts(iflist);

      writeln(fd,'THEN');
      write_facts(thenlist);

      cur_rule := cur_rule^.next;
   end;

   writeln(fd,'END');

end;



procedure writefile;
begin
   write('Enter the name of the file to write to [.RUL]: ');
   readln(line);
   if line = '' then
      exit;

   if pos('.',line) = 0 then
      line := line + '.RUL';

   assign(fd,line);

{$I-}
   reset(fd);
{$I+}

   if ioresult = 0 then
   begin
      close(fd);
      write('The file '+line+' exists!   Overwrite it?');
      read(kbd,c);
      c := upcase(c);
      writeln(c);
      if c <> 'Y' then
         exit;
   end;

{$I-}
   rewrite(fd);
   write_all;
   close(fd);
   saved := true;
end;


procedure readfile;

   procedure expect(m: anystring);
   begin
      readln(fd,line);
      if line <> m then
         writeln('"',m,'" expected, "',line,'" found');
   end;


begin
   {if there is anything not saves, then see if}
   {the user wants to save it}

   if not saved then
   begin
      write('Do you want to save?');
      read(kbd,c);
      c := upcase(c);
      writeln(c);
      if c = 'Y' then
         writefile;
   end;

   write('Enter the name of the file to read from [.RUL]: ');
   readln(line);
   if line = '' then
      exit;

   if pos('.',line) = 0 then
      line := line + '.RUL';

   assign(fd,line);

{$I-}
   reset(fd);
   if ioresult <> 0 then
      writeln('File not found!')
   else

   begin
      facts := nil;
      rules := nil;
      reading := true;
      expect('TITLE');
      readln(fd,title);

      expect('');
      expect('FACTS');

      repeat
      until specify_fact = nil;

      expect('RULES');
      expect('');

      repeat
         expect('IF');
         add_rule
      until line = 'END';

      reading := false;
      close(fd);
   end;

   if ioresult <> 0 then
      writeln('Error reading file!');
{$I+}

   saved := true;

end;





procedure file_io;
begin
   write('File:  Read,  Write: ');

   read(kbd,c);
   c := upcase(c);
   writeln(c);
   writeln;

   case c of
      'R':  readfile;
      'W':  writefile;
   end;
end;



procedure new_data;
begin
   writeln('Enter the title of the new set of rules');
   write('> ');
   readln(title);

   facts := nil;
   rules := nil;
end;



{the main program}
begin
   clrscr;
   writeln('INF - A simple inference engine');
   writeln('By Samuel H. Smith, 7-Oct-85');
   writeln;

   facts := nil;
   rules := nil;
   title := 'Default';
   reading := false;
   saved := true;

   repeat
      writeln;
      writeln('Working on:');
      writeln('   ',title);
      writeln;
      write('Command:  New, File, List, Rule, Deduce, Quit: ');

      read(kbd,c);
      c := upcase(c);
      writeln(c);
      writeln;

      case c of
         'N':   new_data;
         'F':   file_io;
         'L':   list_all;
         'R':   add_rule;
         'D':   deduce;
         'Q':   writeln('Goodbye');
         else   writeln('What?');
      end;

   until c = 'Q';

end.

                                                                            