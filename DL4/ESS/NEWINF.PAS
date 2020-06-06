

(*
 * binf - playing with inferences - a simple inference engine
 *
 * shs 14-oct-85
 *
 *)

{$r-,u-,p512,d-}


program inference_engine;

type
   anystring = string [255];
   factstring = string [40];
   relatstring = string [40];
   factrecptr = ^factrec;
   factptr = ^factlist;
   rulerecptr = ^rulerec;
   ruleptr = ^rulelist;


(* what we know about a fact *)
   factrec = record
         desc:     factstring;      {description of the fact}
         
         value:    relatstring;     {value of the fact if known}
         
         known:    boolean;         {is the fact known?}
         
         byif:     ruleptr;         {list of rules that need this fact}
         
         bythen:   ruleptr;         {list of rules that can deduce this 
                                      fact}
         
   end;


(* a list of facts *)
   factlist = record
         fact:     factrecptr;      {the fact}
         
         relat:    relatstring;     {relational operator and value}
         
         next:     factptr;         {the next item in the list}
         
   end;


(* what we know about a rule *)
   rulerec = record
         iflist:   factptr;         {list of facts that must be true}
         
         thenlist: factptr;         {list of facts that can be deduced}
         
         known:    boolean;         {is it already known that the rule
                                      is true?}
         
   end;


(* a list of rules *)
   rulelist = record
         rule:     rulerecptr;      {the rule}

         next:     ruleptr;         {the next item in the list}

   end;

var
   title:    anystring;       {the title for this set of tules}

   facts:    factptr;         {all of the facts}
   factcnt:  integer;

   rules:    ruleptr;         {all of the rules}
   rulecnt:  integer;

   goals:    factptr;         {all the facts that must be proven}

   crelat:   relatstring;     {current relation and value for specify_fact}

   reading:  boolean;         {are we loading from a file?}
   infd:     text;            {current input file}

   c:        char;
   line:     anystring;
   saved:    boolean;
   trace:    boolean;


(**)


(******************************************************
 *
 * Procedure: getln
 *
 * Purpose:   get a line of input from a file and
 *            map all characters to upper case
 *
 * Example:   getln(fd,buf)
 *
 * Inputs:    file to read from
 *
 * Outputs:   buffer to store data in
 *
 *)

procedure getln (var fd:   text;
                 var buf:  anystring);
var
   i:        integer;

begin
   flush(output);
   readln(fd, buf);
   
   for i := 1 to length (buf) do
      buf[i]:= upcase (buf [i]);
   
   while (length (buf)> 1) and (buf [1]= ' ') do
      buf := copy (buf, 2, 99);
end;


(**)


(******************************************************
 *
 * Procedure:  dispstatus
 *
 * Purpose:    display count of rules, facts and amount
 *             of free memory.
 *
 *)

procedure dispstatus;
begin
   write(output, #13, factcnt : 4, ' facts,  ', rulecnt : 4, ' rules,  ',
         maxavail div 64 : 3, ' kb free');
end;


(**)


(******************************************************
 *
 * Procedure:   insert_fact
 *
 * Purpose:     add a new fact to the end of a fact list
 *
 * Example:     newfact := insert_fact(factlist);
 *
 * Inputs:      the head of the factlist to insert into
 *
 * Outputs:     pointer to newly created factlist entry
 *
 *)

function insert_fact (var flist: factptr): factptr;
var
   cfact:    factptr;

begin
   saved := false;

   if flist = nil then
   begin
      new(flist);
      flist^.next := nil;
      insert_fact := flist;
   end
   else

   begin
      cfact := flist;
      
      while cfact^.next <> nil do
         cfact := cfact^.next;

      new(cfact^.next);
      cfact^.next^.next := nil;
      insert_fact := cfact^.next;
   end;
end;


(**)


(******************************************************
 *
 * Procedure:   insert_rule
 *
 * Purpose:     add a new rule to the end of a rule list
 *
 * Example:     newrule := insert_rule(rulelist);
 *
 * Inputs:      the head of the rulelist to insert into
 *
 * Outputs:     pointer to newly created rulelist entry
 *
 *)

function insert_rule (var rlist: ruleptr): ruleptr;
var
   crule:    ruleptr;

begin
   saved := false;

   if rlist = nil then
   begin
      new(rlist);
      rlist^.next := nil;
      insert_rule := rlist;
   end
   else

   begin
      crule := rlist;
      
      while crule^.next <> nil do
         crule := crule^.next;
      
      new(crule^.next);
      crule^.next^.next := nil;
      insert_rule := crule^.next;
   end;
end;



(**)


(******************************************************
 *
 * Procedure:   write_factlist
 *
 * Purpose:     output the contents of a factlist
 *              to an output file
 *
 * Example:     write_factlist(fd,list)
 *
 * Inputs:      the file to write to
 *              the factlist to write
 *
 *)

procedure write_factlist (var fd:   text;
                          first:    factptr);
var
   cfact:    factptr;

begin
   cfact := first;
   
   while cfact <> nil do
   begin
      write(fd, '   ', cfact^.fact^.desc);

      if cfact^.relat = '' then
      begin
         
         if cfact^.fact^.known then
            write(fd, ' = ', cfact^.fact^.value);
      end
      else
         write(fd, ' ', cfact^.relat);

      writeln(fd);
      cfact := cfact^.next;
   end;
end;


(**)


(******************************************************
 *
 * Procedure:   write_rules
 *
 * Purpose:     write all of the rules in a rule list to a file
 *
 * Example:     write_rules(output,rules)
 *
 * Inputs:      file to write to
 *              the rule list to write
 *
 *)

procedure write_rules(var fd:  text;
                      rlist:   ruleptr);
var
   crule:    ruleptr;

begin
   crule := rlist;

   while crule <> nil do

      with crule^.rule^ do
      begin
         writeln(fd);
         writeln(fd, 'IF');
         write_factlist(fd, iflist);

         writeln(fd, 'THEN');
         write_factlist(fd, thenlist);

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

procedure saywhy(why:  anystring);
var
   i:     integer;
   level: integer;

begin
   writeln;
   level := 1;

   for i := 1 to length (why) do
   begin
      write(why [i]);            {place each level on a seperate
                                   line}


      if why [i]= ',' then
      begin
         level := level + 3;        {indent 4 spaces per level}

         writeln;
         write('' : level);
      end;
   end;

   writeln;
end;



(**)


(******************************************************
 *
 * Procedure:  askfact
 *
 * Purpose:    ask the operator for the value of a
 *             fact when there is no way to deduce the
 *             fact.
 *
 * Example:    askfact(fact,why)
 *
 * Inputs:     factrecord of the fact to ask
 *             explanation of why the fact is needed
 *
 * Outputs:    fact value is set and
 *             known status is set if the user answers the fact
 *             also supports 'why' to print out why the
 *             fact is needed.   the user has the option to
 *             leave the fact unknown.
 *
 *)

procedure askfact (var fact: factrec;
                    why:      anystring);
var
   i,
   level:    integer;
   
begin
   
   repeat
      writeln;
      writeln('Enter the value of this fact:  (or WHY, or blank)');
      write('   ', fact.desc, ' = ');
      getln(input, line);
      writeln;

      if line = '' then
         exit;

      if line = 'WHY' then
         saywhy(why);

   until (line <> 'WHY');
   
   fact.value := line;
   fact.known := true;
end;


(**)


(******************************************************
 *
 * Procedure:   valuematches
 *
 * Purpose:     see if the value in a fact matches the relation
 *              indicated by a listrec entry
 *
 * Example:     if valuematches(factlist) then ...
 *
 * Inputs:      the fact list entry pointer for the fact to ask
 *
 * Outputs:     true if the value matches the relation given
 *
 *)

function valuematches (cfact:    factptr): boolean;
var
   rvalue:   relatstring;
   nval:     real;
   nrval:    real;
   rop:      char;
   code:     integer;
   
begin
   valuematches := false;

   with cfact^, fact^ do

   if known then
   begin
      rop := relat [1];
      rvalue := copy (relat, 3, 40);


(* if it looks like a number, then do a numeric compare *)

      if rvalue [1] in ['.', '0'..'9', '-'] then
      begin
         val(rvalue, nrval, code);
         if code <> 0 then
            writeln('Invalid number in relation: ', desc, ' ', relat);

         val(value, nval, code);
         if code <> 0 then
            writeln('Invalid number in fact value: ', desc, ' = ', value);

         case rop of
            '=':  valuematches :=(nval = nrval);

            '#':  valuematches :=(nval <> nrval);

            '<':  valuematches :=(nval < nrval);

            '>':  valuematches :=(nval > nrval);

            else  writeln('Invalid numeric relation: ', relat);
         end;
      end


(* not a number - do a string comparison *)
      else

         case rop of
            '=':  valuematches :=(value = rvalue);
            
            '#':  valuematches :=(value <> rvalue);
            
            '<':  valuematches :=(value < rvalue);
            
            '>':  valuematches :=(value > rvalue);
            
            else  writeln('Invalid relation: ', relat);
         end;
   end;
end;


(**)


(******************************************************
 *
 * Procedure:   use_rule
 *
 * Purpose:     use a rule to make deductions.  is recursive
 *              with determine_fact_value
 *
 * Example:     usefule(rule,why)
 *
 * Inputs:      the rule record pointer for the rule to use
 *              why the rule is needed
 *
 * Outputs:     values set on any deductions that are made
 *
 *)

procedure determine_fact_value (nfact:    factrecptr;
                                why:      anystring); forward;

procedure use_rule (crule:    rulerecptr;
                    why:      anystring);
var
   cfact:    factptr;
   ifrule:   ruleptr;

begin

   with crule^ do
   begin

      if known then
         exit;


(* for each fact needed and that can be deduced by other rules *)

      cfact := iflist;

      while (cfact <> nil) do
      begin

         if cfact^.fact^.bythen <> nil then
         begin
            determine_fact_value(cfact^.fact, why);

            if valuematches (cfact)= false then
               exit;                   {stop now if one of the facts
                                         cannot be deduced}

         end;

         cfact := cfact^.next;
      end;


(* for each remaining fact needed by this rule that must be asked *)

      cfact := iflist;

      while (cfact <> nil) do
      begin

         if cfact^.fact^.bythen = nil then
         begin
            determine_fact_value(cfact^.fact, why);

            if valuematches (cfact)= false then
               exit                       {stop now if one of the facts
                                            is missing}

         end;

         cfact := cfact^.next;
      end;


(* if all needed facts were true, then trigger deductions *)

      crule^.known := true;      {remember that this rule is known}

      cfact := thenlist;


(* for each fact that can be deduced *)

      while (cfact <> nil) do

         with cfact^.fact^ do
         begin


(* tell the user if this is a deduction that was not known before *)

            if (not known) or (value <> copy (cfact^.relat, 3, 40)) then
            begin
               known := true;
               value := copy (cfact^.relat, 3, 40);
               writeln('Deduction:   ', desc, ' = ', value);


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
 * Procedure:  determine_fact_value
 *
 * Purpose:    determine the value of a fact.  is recursive
 *             with use_rule if the fact value can be deduced.
 *
 * Example:    determine_fact_value(fact,why)
 *
 * Inputs:     the fact pointer of the fact to be determines
 *             why the fact is needed
 *
 * Outputs:    fact value may be set
 *
 *)

procedure determine_fact_value;  {(nfact: factrecptr; why: anystring);}
 
var
   crule:    ruleptr;
   c:        char;

begin

   if keypressed then
   begin
      read(kbd,c);
      if c = ^C then
      begin
         writeln('*** ^C');
         exit;
      end;
   end;


(* if fact is known already, then nothing to do *)

   if nfact^.known then
      exit;

   if length (why)> 200 then
   begin
      writeln;
      writeln('LOGIC NESTING IS TOO DEEP!');
      writeln('You probably have some circular rules.');
      writeln;
      writeln('Why: ', WHY);
      writeln('Trying to determine fact:  ', nfact^.desc);
      writeln;
      exit;
   end;

   why := why + ', determine ' + nfact^.desc;

   if trace then
      writeln('Determine fact:   ', nfact^.desc);


(* use each rule that can deduce this fact until the fact is known *)

   crule := nfact^.bythen;


(* if there is no way to deduce the fact, then ask for it *)
   
   if crule = nil then
   begin
      askfact(nfact^, why);
      exit;
   end;


(* try each rule looking for this deduction *)
   
   while (crule <> nil) and (not nfact^.known) do
   begin
      use_rule(crule^.rule, why);
      crule := crule^.next;
   end;
end;


(**)


(******************************************************
 *
 * Procedure:   deduce
 *
 * Purpose:     try to deduce the values of all of the goals.
 *              this starts up the inference engine
 *
 *)

procedure deduce;
var
   cfact:    factptr;
   deductions: boolean;
   why:      anystring;
   
begin
   why := 'reach goals';
   
   repeat
      deductions := false;
      cfact := goals;
      
      while (cfact <> nil) do
      begin
         
         if not cfact^.fact^.known then
         begin
            determine_fact_value(cfact^.fact, why);
            
            if cfact^.fact^.known then
               deductions := true;
         end;

         cfact := cfact^.next;
      end;
   until deductions = false;
   
   writeln('No more deductions');
end;


(**)


(******************************************************
 *
 * Procedure:   specify_fact
 *
 * Purpose:     user interface to specify a fact and a value
 *
 * Example:     newfact := specify_fact
 *
 * Outputs:     pointer the fact record if the specified fact.
 *              creates a new fact if needed.
 *              returns nil if no fact specified
 *
 *)

function specify_fact: factrecptr;
var
   cur:      factptr;
   newfact:  factptr;
   i:        integer;

begin

   repeat

      if reading then
         getln(infd, line)
      else

         repeat
            begin
               write('> ');
               getln(input, line);
               
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

      crelat := '= TRUE';        {default relation if none given}


      for i := 1 to length (line) do
      begin

         if line [i] in ['=', '#', '<', '>'] then
         begin
            crelat := copy (line, i, 80);
            line := copy (line, 1, i - 2);
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

      if (not reading) or ((factcnt mod 8)= 0) then
         dispstatus;

      if not reading then
         writeln('   New fact');

      newfact := insert_fact (facts);
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
   until true = false;
end;


(**)


(******************************************************
 *
 * Procedure:  add_rule
 *
 * Purpose:    user interface for adding new rules to the
 *             current rulelist
 *
 *)

procedure add_rule;
var
   newrule:  ruleptr;
   cfact:    factrecptr;
   rlist:    ruleptr;
   flist:    factptr;

begin
   newrule := insert_rule (rules);
   new(newrule^.rule);

   with newrule^.rule^ do
   begin
      known := false;

      if not reading then
      begin
         writeln('List the facts that must be true.');
         writeln('Enter a blank fact toend the list.  Type "HELP" if needed.');
      end;
      
      iflist := nil;
      cfact := specify_fact;

      while cfact <> nil do
      begin
         flist := insert_fact (iflist);
         flist^.fact := cfact;
         flist^.relat := crelat;
         rlist := insert_rule (cfact^.byif);
         rlist^.rule := newrule^.rule;
         cfact := specify_fact;
      end;
      
      if not reading then
      begin
         writeln;
         writeln('List the facts that can be deduced.');
         writeln('Enter a blank fact toend the list.  Type "HELP" if needed.');
      end;

      thenlist := nil;
      cfact := specify_fact;
      
      while cfact <> nil do
      begin
         flist := insert_fact (thenlist);
         flist^.fact := cfact;
         flist^.relat := crelat;
         rlist := insert_rule (cfact^.bythen);
         rlist^.rule := newrule^.rule;
         cfact := specify_fact;
      end;
   end;
   
   rulecnt := rulecnt + 1;
   
   if (not reading) or ((rulecnt mod 8)= 0) then
      dispstatus;
   
   if not reading then
      writeln;
end;



(**)


(******************************************************
 *
 * Procedure:   file_write
 *
 * Purpose:     write the current knowledge base to a file
 *
 *)

procedure file_write;
var
   fd:  text;

begin
   write('Enter the name of the file to write to [.RUL]: ');
   getln(input, line);

   if line = '' then
      exit;

   if pos ('.', line)= 0 then
      line := line + '.RUL';

   assign(fd, line);

{$I-}
   reset(fd);
{$I+}


   if ioresult = 0 then
   begin
      close(fd);
      write('The file ' + line + ' exists!   Overwrite it? ');
      flush(output);
      read(kbd, c);
      c := upcase (c);
      writeln(c);

      if c <> 'Y' then
         exit;
   end;

{$I-}
   rewrite(fd);
   writeln(fd, 'TITLE');
   writeln(fd, title);
   writeln(fd);

   writeln(fd, 'GOALS');
   write_factlist(fd, goals);
   writeln(fd);

   writeln(fd, 'FACTS');
   write_factlist(fd, facts);
   writeln(fd);

   writeln(fd, 'RULES');
   write_rules(fd, rules);
   writeln(fd, 'END');
   close(fd);
   saved := true;
end;


(**)


(******************************************************
 *
 * Procedure:   list_all
 *
 * Purpose:     user interface for listing parts of
 *              the current knowledge base
 *
 *)

procedure list_all;
begin
   write('List:  Goals, Facts, Rules: ');
   flush(output);
   read(kbd, c);
   c := upcase (c);
   writeln(c);
   writeln;

   case c of
      'G':  begin
               writeln('GOALS');
               write_factlist(output,goals);
               writeln;
            end;

      'F':  begin
               writeln('FACTS');
               write_factlist(output,facts);
               writeln;
            end;

      'R':  begin
               writeln('RULES');
               write_rules(output,rules);
            end;
   end;
end;


(**)
(******************************************************
 *
 * Procedure:   expect
 *
 * Purpose:     read a line from the input file
 *              and compare it to an expected value.
 *              complain if what you get is not what
 *              you expected.  skips blank lines.
 *
 * Example:     expect('GOALS');
 *
 * Inputs:      the string to expect
 *
 * Outputs:     line (global) contains the line that was read
 *
 *)

procedure expect (m:        anystring);
begin

   if eof (infd) then
      line := 'END'
   else
   begin

      repeat
         getln(infd, line);
      until line <> '';

      if line <> m then
         writeln('"', m, '" expected, "', line, '" found');
   end;
end;


(**)


(******************************************************
 *
 * Procedure:   file_read
 *
 * Purpose:     read a new knowledge base from a file
 *
 *)

procedure file_read;
var
   cfact:    factrecptr;
   ngoal:    factptr;

begin

(* if there is anything not saved, then see if
 * the user wants to save it *)

   if not saved then
   begin
      write('Do you want to save?');
      flush(output);
      read(kbd, c);
      c := upcase (c);
      writeln(c);

      if c = 'Y' then
         file_write;
   end;

   write('Enter the name of the file to read from [.RUL]: ');
   getln(input, line);

   if line = '' then
      exit;

   if pos ('.', line)= 0 then
      line := line + '.RUL';

   assign(infd, line);

{$I-}
   reset(infd);

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
      getln(infd, title);

      expect('GOALS');
      cfact := specify_fact;

      while cfact <> nil do
      begin
         ngoal := insert_fact (goals);
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
      close(infd);
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
 * Procedure:  file_io
 *
 * Purpose:    user interface to file read and file write
 *             operations
 *
 *)

procedure file_io;
begin
   write('File:  Read,  Write: ');
   flush(output);
   read(kbd, c);
   c := upcase (c);
   writeln(c);
   writeln;

   case c of
      'R':  file_read;

      'W':  file_write;
   end;
end;


(**)


(******************************************************
 *
 * Procedure:   state_facts
 *
 * Purpose:     user interface to enter new facts into the factlist
 *              and to state the value of existing facts.
 *
 *)

procedure state_facts;
var
   cfact:    factrecptr;
   
begin
   writeln('List the fact statements and their values.');
   writeln('Enter a blank fact toend the list.  Type "HELP" if needed.');
   
   repeat
      cfact := specify_fact;
      
      if cfact = nil then
         exit;
      
      cfact^.value := copy (crelat, 3, 99);
      cfact^.known := true;
   until true = false;
end;


(**)


(******************************************************
 *
 * Procedure:  add_goals
 *
 * Purpose:    user interface to enter new goals on the goal list
 *
 *)
 
procedure add_goals;
var
   cfact:    factrecptr;
   ngoal:    factptr;
   
begin
   writeln('List the fact to be added to the goal list.');
   writeln('Enter a blank fact toend the list.');
   cfact := specify_fact;
   
   while cfact <> nil do
   begin
      ngoal := insert_fact (goals);
      ngoal^.fact := cfact;
      cfact := specify_fact;
   end;
end;


(**)


(******************************************************
 *
 * Procedure:  new_data
 *
 * Purpose:    user interface to allow clearing of goal table
 *             fact values or all data
 *
 *)

procedure new_data;
var
   cfact:    factptr;
   crule:    ruleptr;

begin
   write('New:  Goals,  Facts,  Rules: ');
   flush(output);
   read(kbd, c);
   c := upcase (c);
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
               getln(input, title);
               facts := nil;
               rules := nil;
               goals := nil;
            end;
   end;
end;


(**)


(******************************************************
 *
 * Procedure:  help
 *
 * Purpose:    print instructions on screen
 *
 *)

procedure help;
begin
   flush(output);
   clrscr;
   writeln('INF - A simple inference engine');
   writeln;
   writeln('This program is an example of an inference engine.');
   writeln('You enter a list of IF ... THEN type rules, and the');
   writeln('inference engine will determine what facts need to be');
   writeln('known to deduce the values listed in the goal list.');
   writeln;
   writeln('Commands:');
   writeln('   New           - Erase the list of goals, fact values, or rules');
   writeln('   File Read     - Read or write rule files');
   writeln('   List          - List goals, facts or rules on screen');
   writeln('   Rule          - Define a new rule');
   writeln('   Statefact     - State the value of a fact');
   writeln('   Goal          - Add facts to the goal list');
   writeln('   Deduce        - Use rules to deduce goal values');
end;


(**)


(******************************************************
 *
 * Procedure:  main
 *
 * Purpose:    the main program and top-level user interface
 *
 *)

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

   flush(output);
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
      writeln('Working on:  ', title);
      writeln;
      write('Command:  ');
      write('Trace, New, File, List, Rule, StateFact, Goal, Deduce, Quit: ');
      flush(output);
      read(kbd, c);
      c := upcase (c);
      writeln(c);
      writeln;
      
      case c of
         'T':  begin
                  trace := not trace;
                  writeln('Trace=', trace);
               end;
         
         'N':  new_data;
         
         'F':  file_io;
         
         'L':  list_all;
         
         'R':  add_rule;
         
         'S':  state_facts;
         
         'G':  add_goals;
         
         'D':  deduce;
         
         'Q':  writeln('Goodbye');
         
         '?':  help;
         
         else  writeln('What?');
      end;
   until c = 'Q';
end.

                             