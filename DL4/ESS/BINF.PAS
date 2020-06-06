

(*
 * binf - playing with inferences - a simple inference engine
 *
 * shs 14-oct-85
 *
 *)



{$r-,u-,d-}

program inference_engine;

type
   anystring   = string[255];
   factstring  = string[40];
   relatstring = string[40];

   factrecptr  = ^factrec;
   factptr     = ^factlist;
   rulerecptr  = ^rulerec;
   ruleptr     = ^rulelist;


   (* what we know about a fact *)
   factrec = record
      desc:     factstring;   {description of the fact}
      value:    relatstring;  {value of the fact if known}
      known:    boolean;      {is the fact known?}
      byif:     ruleptr;      {list of rules that need this fact}
      bythen:   ruleptr;      {list of rules that can deduce this fact}
   end;

   (* a list of facts *)
   factlist = record
      fact:     factrecptr;    {the fact}
      relat:    relatstring;   {relational operator and value}
      next:     factptr;       {the next item in the list}
   end;

   (* what we know about a rule *)
   rulerec = record
      iflist:    factptr;      {list of facts that must be true}
      thenlist:  factptr;      {list of facts that can be deduced}
      known:     boolean;      {is it already known that the rule is true?}
   end;

   (* a list of rules *)
   rulelist = record
      rule:     rulerecptr;    {the rule}
      next:     ruleptr;       {the next item in the list}
   end;


var
   title:   anystring;      {the title for this set of tules}
   facts:   factptr;        {all of the facts}
   factcnt: integer;

   rules:   ruleptr;        {all of the rules}
   rulecnt: integer;

   goals:   factptr;        {all the facts that must be proven}

   crelat:  relatstring;    {current relation and value for specify_fact}
   fd:      text;           {current read/write file}
   reading: boolean;        {are we loading from a file?}

   c:       char;
   line:    anystring;
   saved:   boolean;
   trace:   boolean;





(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)
(* get a line of input and map it to upper case *)

procedure getln(var fd: text; var buf: anystring);
var
   i:  integer;

begin
   readln(fd,buf);

   for i := 1 to length(buf) do
      buf[i] := upcase(buf[i]);

  while (length(buf) > 1) and (buf[1] = ' ') do
     buf := copy(buf,2,99);
end;




(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)
(* display memory status *)

procedure dispstatus;
begin
   write(con,#13,factcnt:4,' facts,  ',
                 rulecnt:4,' rules,  ',
                 maxavail div 64:3,' kb free');

end;





(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

(* list maintenance functions *)

(* insert entry at the end of a fact list *)
function insertfact(var flist: factptr): factptr;
var
   cfact:  factptr;

begin
   if flist = nil then
   begin
      new(flist);
      flist^.next := nil;
      insertfact := flist;
   end
   else

   begin
      cfact := flist;
      while cfact^.next <> nil do
         cfact := cfact^.next;

      new(cfact^.next);
      cfact^.next^.next := nil;
      insertfact := cfact^.next;
   end;
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)
(* insert entry at the end of a rule list *)
function insertrule(var rlist: ruleptr): ruleptr;
var
   crule:  ruleptr;

begin
   if rlist = nil then
   begin
      new(rlist);
      rlist^.next := nil;
      insertrule := rlist;
   end
   else

   begin
      crule := rlist;
      while crule^.next <> nil do
         crule := crule^.next;

      new(crule^.next);
      crule^.next^.next := nil;
      insertrule := crule^.next;
   end;
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

(* ask the user if a fact is true or false *)
procedure askfact(var fact: factrec;  why: anystring);
var
   i,level:  integer;

begin
   repeat
      writeln;
      writeln('Enter the value of this fact:  (or WHY, or blank)');
      write('   ',fact.desc,' = ');
      getln(input,line);

      if line = '' then
         exit;

      if line = 'WHY' then
      begin
         writeln;
         level := 1;
         for i := 1 to length(why) do
         begin
            write(why[i]);         {place each level on a seperate line}
            if why[i] = ',' then
            begin
               level := level + 4;    {indent 4 spaces per level}
               writeln;
               write('':level);
            end;
         end;
         writeln;
      end;

   until (line <> 'WHY');

   fact.value := line;
   fact.known := true;
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

(* see is the value of a fact matches the factlist pointing to it *)

function valuematches(cfact: factptr): boolean;
var
   rvalue: relatstring;
   nval:   real;
   nrval:  real;
   rop:    char;
   code:   integer;

begin
   valuematches := false;

   with cfact^.fact^ do
   if known then
   begin
      rop    := cfact^.relat[1];
      rvalue := copy(cfact^.relat,3,40);

      if trace then
         writeln('Matches?  ',desc,':  ',value,' ',rop,' ',rvalue,' ');


      (* if it looks like a number, then do a numeric compare *)

      if rvalue[1] in ['.','0'..'9','-'] then
      begin
         val(rvalue,nrval,code);
         if code <> 0 then
            writeln('Invalid number in relation: ',desc,' ',cfact^.relat);

         val(value, nval, code);
         if code <> 0 then
            writeln('Invalid number in fact value: ',desc,' = ',value);

         case rop of
            '=':  valuematches := (nval = nrval);
            '#':  valuematches := (nval <> nrval);
            '<':  valuematches := (nval < nrval);
            '>':  valuematches := (nval > nrval);

            else  writeln('Invalid numeric relation: ',cfact^.relat);
         end;
      end


      (* not a number - do a string comparison *)
      else
         case rop of
            '=':  valuematches := (value = rvalue);
            '#':  valuematches := (value <> rvalue);
            '<':  valuematches := (value < rvalue);
            '>':  valuematches := (value > rvalue);

            else  writeln('Invalid relation: ',cfact^.relat);
         end;

   end;
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

procedure determinefact(nfact: factrecptr; why: anystring); forward;


(* use a rule to make a deduction *)
procedure userule(crule:  rulerecptr; why: anystring);
var
   cfact:  factptr;
   ifrule: ruleptr;

begin

   with crule^ do
   begin
      if known then
         exit;

      (* for each fact needed and that can be deduced by other rules *)
      cfact := iflist;

      while (cfact <> nil) do
      with cfact^.fact^ do
      begin
         if bythen <> nil then
         begin
            determinefact(cfact^.fact,why);

            if valuematches(cfact) = false then
               exit;        {stop now if one of the facts cannot be deduced}
         end;

         cfact := cfact^.next;
      end;


      (* for each remaining fact needed by this rule that must be asked *)
      cfact := iflist;

      while (cfact <> nil) do
      with cfact^.fact^ do
      begin
         determinefact(cfact^.fact,why);

         if valuematches(cfact) = false then
            exit        {stop now if one of the facts is missing}
         else
            cfact := cfact^.next;
      end;


      (* if all needed facts were true, then trigger deductions *)
      crule^.known := true;   {remember that this rule is known}
      cfact := thenlist;

      (* for each fact that can be deduced *)
      while (cfact <> nil) do
      with cfact^.fact^ do
      begin

         (* tell the user if this is a deduction that was not known before *)
         if (not known) or (value <> copy(cfact^.relat,3,40)) then
         begin
            known := true;
            value := copy(cfact^.relat,3,40);
            writeln;
            writeln('Deduction:   ',desc,' = ',value);

            (* mark all rules that use this fact as 'not known' *)
            ifrule := byif;
            while ifrule <> nil do
            begin
               ifrule^.rule^.known := false;
               ifrule := ifrule^.next;
            end;
         end;

         cfact := cfact^.next;
      end;

   end;
end;




(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)


(* try to prove a fact is true *)
procedure determinefact; {(nfact: factrecptr; why: anystring);}
var
   crule:       ruleptr;

begin

   (* if fact is known already, then nothing to do *)
   if nfact^.known then
      exit;

   if length(why) > 200 then
   begin
      writeln;
      writeln('LOGIC NESTING IS TOO DEEP!');
      writeln('You probably have some circular rules.');
      writeln;
      writeln('Why: ',WHY);
      writeln('Trying to determine fact:  ',nfact^.desc);
      writeln;
      exit;
   end;

   why := why + ', determine '+nfact^.desc;

   if trace then
   begin
      writeln;
      writeln('Determine fact:   ',nfact^.desc);
   end;


   (* use each rule that can deduce this fact until the fact is known *)
   crule := nfact^.bythen;

   (* if there is no way to deduce the fact, then ask for it *)
   if crule = nil then
   begin
      askfact(nfact^,why);
      exit;
   end;

   (* try each rule looking for this deduction *)
   while (crule <> nil) and (not nfact^.known) do
   begin
      userule(crule^.rule,why);
      crule := crule^.next;
   end;
end;




(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

(* try all goals and see if any new facts can be deduced *)
procedure deduce;
var
   cfact:      factptr;
   deductions: boolean;
   why:        anystring;

begin
   why := 'reach goals';

   repeat
      deductions := false;
      cfact := goals;

      while (cfact <> nil) do
      begin
         if not cfact^.fact^.known then
         begin
            determinefact(cfact^.fact,why);
            if cfact^.fact^.known then
               deductions := true;
         end;

         cfact := cfact^.next;
      end;

   until deductions = false;

   writeln;
   writeln('No more deductions');

end;




(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)



(* allow operator to specify a fact; creates new facts when needed *)
function specify_fact: factrecptr;
var
   cur:      factptr;
   newfact:  factptr;
   i:        integer;

begin
   repeat
      if reading then
         getln(fd,line)
      else

      repeat
         begin
            write('> ');
            getln(input,line);

            if line = 'HELP' then
            begin
               writeln;
               writeln('Specify a fact.   You also have the option to');
               writeln('give a value for the fact.  If you don''t give a');
               writeln('value, then "= TRUE" will be assumed.');
               writeln;
               writeln('Examples:   COLOR = RED');
               writeln('            ANIMAL IS MAMMAL = TRUE');
               writeln('            ANIMAL IS CARNIVORE = FALSE');
               writeln('            CHILDREN # 2     ("#" means not-equal)');
               writeln('            INCOME > 20000');
               writeln;
            end;
         end;
      until line <> 'HELP';

      if (line = '') or (line = 'THEN') or (line = 'END') then
      begin
         specify_fact := nil;
         crelat := '';
         exit;
      end;


      crelat := '= TRUE';   {default relation if none given}

      for i := 1 to length(line) do
      begin
         if line[i] in ['=','#','<','>'] then
         begin
            crelat := copy(line,i,80);
            line := copy(line,1,i-2);
         end;
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


      (* new rule - create it and leave *)
      factcnt := factcnt + 1;
      if (not reading) or ((factcnt mod 8) = 0) then
         dispstatus;

      if not reading then
         writeln('   New fact');


      newfact := insertfact(facts);
      new(newfact^.fact);
      with newfact^.fact^ do
      begin
         known := false;
         value := '?';
         desc := line;
         byif := nil;
         bythen := nil;
      end;

      specify_fact := newfact^.fact;
      exit;

   until true=false;
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)



(* add new rules to the rule list *)
procedure add_rule;
var
   newrule:  ruleptr;
   cfact:    factrecptr;
   rlist:    ruleptr;
   flist:    factptr;

begin
   newrule := insertrule(rules);
   new(newrule^.rule);
   with newrule^.rule^ do
   begin
      known := false;

      if not reading then
      begin
         writeln('List the facts that must be true.');
         writeln('Enter a blank fact to end the list.  Type "HELP" if needed.');
      end;

      iflist := nil;
      cfact := specify_fact;

      while cfact <> nil do
      begin
         flist := insertfact(iflist);
         flist^.fact  := cfact;
         flist^.relat := crelat;

         rlist := insertrule(cfact^.byif);
         rlist^.rule := newrule^.rule;

         cfact := specify_fact;
      end;

      if not reading then
      begin
         writeln;
         writeln('List the facts that can be deduced.');
         writeln('Enter a blank fact to end the list.  Type "HELP" if needed.');
      end;

      thenlist := nil;
      cfact := specify_fact;

      while cfact <> nil do
      begin
         flist := insertfact(thenlist);
         flist^.fact  := cfact;
         flist^.relat := crelat;

         rlist := insertrule(cfact^.bythen);
         rlist^.rule := newrule^.rule;

         cfact := specify_fact;
      end;

   end;

   rulecnt := rulecnt + 1;
   if (not reading) or ((rulecnt mod 8) = 0) then
      dispstatus;

   if not reading then
      writeln;
end;




(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)


(* write the facts in a fact list to output file *)
procedure write_factlist(first: factptr);
var
   cfact: factptr;

begin
   cfact := first;

   while cfact <> nil do
   begin

      write(fd,'   ',cfact^.fact^.desc);
      if cfact^.relat = '' then
      begin
         if cfact^.fact^.known then
            write(fd,' = ',cfact^.fact^.value);
      end
      else
         write(fd,' ',cfact^.relat);

      writeln(fd);

      cfact := cfact^.next;
   end;
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)
procedure write_goals;
begin
   writeln(fd,'GOALS');
   write_factlist(goals);
   writeln(fd);
end;


procedure write_facts;
begin
   writeln(fd,'FACTS');
   write_factlist(facts);
   writeln(fd);
end;




(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

procedure write_rules;
var
   crule: ruleptr;

begin
   writeln(fd,'RULES');
   crule := rules;

   while crule <> nil do
   with crule^.rule^ do
   begin
      writeln(fd);
      writeln(fd,'IF');
      write_factlist(iflist);

      writeln(fd,'THEN');
      write_factlist(thenlist);

      crule := crule^.next;
   end;

   writeln(fd,'END');

end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

procedure writefile;
begin
   write('Enter the name of the file to write to [.RUL]: ');
   getln(input,line);
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
      write('The file '+line+' exists!   Overwrite it? ');
      read(kbd,c);
      c := upcase(c);
      writeln(c);
      if c <> 'Y' then
         exit;
   end;

{$I-}
   rewrite(fd);

   writeln(fd,'TITLE');
   writeln(fd,title);
   writeln(fd);

   write_goals;
   write_facts;
   write_rules;

   close(fd);
   saved := true;
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

procedure list_all;
begin
   write('List:  Goals, Facts, Rules, All: ');

   read(kbd,c);
   c := upcase(c);
   writeln(c);
   writeln;

   assign(fd,'con');
   rewrite(fd);

   case c of
      'G':  write_goals;

      'F':  write_facts;

      'R':  write_rules;

      'A':  begin
               write_goals;
               write_facts;
               write_rules;
            end;
   end;

   close(fd);
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)


procedure readfile;
var
   cfact:     factrecptr;
   ngoal:  factptr;


   procedure expect(m: anystring);
   begin
      if eof(fd) then
         line := 'END'
      else

      begin
         repeat
            getln(fd,line);
         until line <> '';

         if line <> m then
            writeln('"',m,'" expected, "',line,'" found');
      end;
   end;


begin
   (*if there is anything not saved, then see if
    * the user wants to save it *)

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
   getln(input,line);
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
      writeln;
      writeln('Reading...');

      goals := nil;
      facts := nil;
      rules := nil;
      factcnt := 0;
      rulecnt := 0;
      reading := true;
      expect('TITLE');
      getln(fd,title);

      expect('GOALS');
      cfact := specify_fact;
      while cfact <> nil do
      begin
         ngoal := insertfact(goals);
         ngoal^.fact := cfact;

         cfact := specify_fact;
      end;

      expect('FACTS');
      repeat
      until specify_fact = nil;

      expect('RULES');
      repeat
         expect('IF');
         add_rule;
      until line = 'END';

      reading := false;
      close(fd);
      dispstatus;
      writeln;
      writeln;
   end;

   if ioresult <> 0 then
      writeln('Error reading file!');
{$I+}

   saved := true;

end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)



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



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

procedure state_facts;
var
   cfact:   factrecptr;

begin
   writeln('List the fact statements and their values.');
   writeln('Enter a blank fact to end the list.  Type "HELP" if needed.');

   repeat
      cfact := specify_fact;
      if cfact = nil then
         exit;

      cfact^.value := copy(crelat,3,99);
      cfact^.known := true;

   until true = false;
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)


procedure add_goals;
var                  cfact:   factrecptr;
   ngoal:   factptr;

begin
   writeln('List the fact to be added to the goal list.');
   writeln('Enter a blank fact to end the list.');

   cfact := specify_fact;
   while cfact <> nil do
   begin

      ngoal := insertfact(goals);
      ngoal^.fact := cfact;

      cfact := specify_fact;
   end;

end;




(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

procedure new_data;
var
   cfact:  factptr;
   crule:  ruleptr;

begin
   write('New:  Goals,  Facts,  Rules: ');

   read(kbd,c);
   c := upcase(c);
   writeln(c);
   writeln;

   case c of
      'G':  goals := nil;

      'F':  begin
               writeln('Fact values reset');
               cfact := facts;
               while cfact <> nil do
               begin
                  cfact^.fact^.value := '?';
                  cfact^.fact^.known := false;
                  cfact := cfact^.next;
               end;

               crule := rules;
               while crule <> nil do
               begin
                  crule^.rule^.known := false;
                  crule := crule^.next;
               end;
            end;

      'R':  begin
               writeln('Enter the title of the new set of rules');
               write('> ');
               getln(input,title);
               facts := nil;
               rules := nil;
               goals := nil;
            end;
   end;
end;




(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)
(* give help *)

procedure help;
begin
   clrscr;
   writeln('INF - A simple inference engine');
   writeln;
   writeln('This program is an example of an inference engine.');
   writeln('You enter a list of IF ... THEN type rules, and the');
   writeln('inference engine will determine what facts need to be');
   writeln('known to deduce the values listed in the goal list.');
   writeln;
   writeln('Commands:');
   writeln('   New Goals     - Erase the list of goals');
   writeln('   New Facts     - Forget all fact values');
   writeln('   New Rules     - Forget all rules, facts and goals');
   writeln('   File Read     - Read rules from a file');
   writeln('   File Write    - Write rules to a file');
   writeln('   List          - List goals, facts or rules on screen');
   writeln('   Rule          - Define a new rule');
   writeln('   Statefact     - State the value of a fact');
   writeln('   Goal          - Add facts to the goal list');
   writeln('   Deduce        - Use rules to deduce goal values');
end;



(**)
(******************************************************
 *
 * Procedure:
 *
 * Purpose:
 *
 * Example:
 *
 * Inputs:
 *
 * Outputs:
 *
 *)

(* the main program *)
begin
   clrscr;
   writeln('INF - A simple inference engine');
   writeln;
   writeln('This program is an example of an inference engine.');
   writeln('You enter a list of IF ... THEN type rules, and the');
   writeln('inference engine will determine what facts need to be');
   writeln('known to deduce the values listed in the goal list.');
   writeln;
   writeln('By Samuel H. Smith');
   writeln('Version 1.0, 14-oct-85');

   sound(3000);
   delay(100);
   nosound;

   delay(3000);
   help;

   facts := nil;
   rules := nil;
   title := 'Default';
   reading := false;
   saved := true;
   trace := false;
   factcnt := 0;
   rulecnt := 0;

   repeat
      writeln;
      writeln('Working on:  ',title);
      writeln;
      write('Command:  ');
      write('Trace, New, File, List, Rule, StateFact, Goal, Deduce, Quit: ');

      read(kbd,c);
      c := upcase(c);
      writeln(c);
      writeln;

      case c of
         'T':   begin
                   trace := not trace;
                   writeln('Trace=',trace);
                end;

         'N':   new_data;
         'F':   file_io;
         'L':   list_all;
         'R':   add_rule;
         'S':   state_facts;
         'G':   add_goals;
         'D':   deduce;
         'Q':   writeln('Goodbye');
         '?':   help;
         else   writeln('What?');
      end;

   until c = 'Q';

end.

                           