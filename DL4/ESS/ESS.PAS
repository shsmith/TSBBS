


(*
 * ess - a simple expert system shell (inference engine)
 *
 * shs 14-oct-85
 *
 *)

{$r-,u-,d-}


program inference_engine;
type
   anystring =    string [255];
   factstring =   string [40];
   relatstring =  string [40];
   factrecptr =   ^factrec;
   factptr =      ^factlist;
   rulerecptr =   ^rulerec;
   ruleptr =      ^rulelist;


(* what we know about a fact *)
   factrec =      record
         desc:          factstring; {description of the fact}
         
         value:         relatstring;
                                    {value of the fact if known}
         
         known:         boolean;    {is the fact known?}
         
         byif:          ruleptr;    {list of rules that need this fact}
         
         bythen:        ruleptr;    {list of rules that can deduce this 
                                      fact}
         
   end;


(* a list of facts *)
   factlist =     record
         fact:          factrecptr; {the fact}
         
         relat:         relatstring;
                                    {relational operator and value}
         
         next:          factptr;    {the next item in the list}
         
   end;


(* what we know about a rule *)
   rulerec =      record
         iflist:        factptr;    {list of facts that must be true}
         
         thenlist:      factptr;    {list of facts that can be deduced}
         
         known:         boolean;    {is it already known that the rule
                                      is true?}
         
         ded:           integer;    {deduction count when rule last tried}
         
   end;


(* a list of rules *)
   rulelist =     record
         rule:          rulerecptr; {the rule}

         next:          ruleptr;    {the next item in the list}

   end;


(* a full knowledge base *)
   knowledgebase = record
         title:          anystring; {the title for this kdb}

         facts:          factptr;   {all of the facts}

         rules:          ruleptr;   {all of the rules}

         goals:          factptr;   {all of the goals}
   end;


var
   domain:        knowledgebase;
                              {the current domain of knowledge}

   factcnt:       integer;
   rulecnt:       integer;
   crelat:        relatstring;
                              {current relation and value for specify_fact}
   
   fd:            text;       {current read/write file}
   
   c:             char;
   line:          anystring;
   trace:         boolean;
   dedcnt:        integer;    {deduction count; used for rule re-trys}


procedure determine_fact (nfact:         factptr;
                          why:           anystring); forward;



(**)
(* get a line of input and map it to upper case *)

procedure read_line (var fd:        text;
                     var buf:       anystring);
var
   i:             integer;

begin
   readln(fd, buf);
   
   for i := 1 to length (buf) do
      buf[i]:= upcase (buf [i]);

   while (length (buf)> 1) and (buf [1]= ' ') do
      buf := copy (buf, 2, 99);
end;


(**)
(* ask the user if a fact is true or false *)

procedure ask_for_fact (var fact:      factrec;
                        why:           anystring);
var
   i,
   level:         integer;

begin

   repeat
      writeln;
      writeln('Enter the value of this fact:  (or WHY, TRACE, or blank)');
      write('   ', fact.desc, ' = ');
      read_line(input, line);
      writeln;

      if line = '' then
         exit;

      if line = 'TRACE' then
      begin
         trace := not trace;
         writeln('Trace = ', trace);
      end;

      if line = 'WHY' then
      begin
         writeln;
         level := 1;

         for i := 1 to length (why) do
         begin
            write(why [i]);            {place each level on a seperate line}

            if why [i]= ',' then
            begin
               level := level + 4;        {indent 4 spaces per level}
               writeln;
               write('' : level);
            end;
         end;

         writeln;
      end;
   until (line <> 'WHY') and (line <> 'TRACE');

   fact.value := line;
   fact.known := true;
   dedcnt := dedcnt + 1;
end;


(**)
(* see is the value of a fact matches the factlist pointing to it *)

function fact_value_matches (cfact:         factptr): boolean;
var
   rvalue:        relatstring;
   nval:          real;
   nrval:         real;
   rop:           char;
   code:          integer;

begin
   fact_value_matches := false;

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
            '=':  fact_value_matches :=(nval = nrval);
            '#':  fact_value_matches :=(nval <> nrval);
            '<':  fact_value_matches :=(nval < nrval);
            '>':  fact_value_matches :=(nval > nrval);
            else  writeln('Invalid numeric relation: ', relat);
         end;
      end


(* not a number - do a string comparison *)
      else
         case rop of
            '=':  fact_value_matches :=(value = rvalue);
            '#':  fact_value_matches :=(value <> rvalue);
            '<':  fact_value_matches :=(value < rvalue);
            '>':  fact_value_matches :=(value > rvalue);
            else  writeln('Invalid relation: ', relat);
         end;
   end;
end;


(**)
(* use a rule to make a deduction *)

procedure use_rule (crule:         rulerecptr;
                    why:           anystring);
var
   cfact:         factptr;
   ifrule:        ruleptr;
   
begin
   
   with crule^ do
   begin
      
      if known then
         exit;


(* if this has already been tried, and nothing new is known, then
   don't bother again *)
      
      if ded = dedcnt then
         exit;


(* for each fact needed and that can be deduced by other rules *)
      
      cfact := iflist;
      
      while (cfact <> nil) do
      begin
         
         if cfact^.fact^.bythen <> nil then
         begin
            determine_fact(cfact, why);
            
            if not cfact^.fact^.known then
               ded := dedcnt;          {if fact not known then mark current
                                         deduction count and give up 
                                         now. try this rule again only 
                                         after new facts have been added}
            
            
            if fact_value_matches (cfact)= false then
               exit;                   {stop now if one of the facts cannot 
                                         be deduced}
            
         end;
         
         cfact := cfact^.next;
      end;


(* for each remaining fact needed by this rule that must be asked *)
      
      cfact := iflist;
      
      while (cfact <> nil) do
      begin
         
         if cfact^.fact^.bythen = nil then
         begin
            determine_fact(cfact, why);
            
            if not cfact^.fact^.known then
               ded := dedcnt;          {if fact not known then mark current 
                                         deduction count and give up 
                                         now. try this rule again only 
                                         after new facts have been added}
            

            if fact_value_matches (cfact)= false then
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
         
         with cfact^, fact^ do
         begin


(* tell the user if this is a deduction that was not known before *)
            
            if (not known) or (value <> copy (cfact^.relat, 3, 40)) then
            begin
               known := true;
               value := copy (relat, 3, 40);
               dedcnt := dedcnt + 1;
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
(* try to determine the value of a fact *)

procedure determine_fact;  {(nfact: factptr; why: anystring);}

var
   crule:         ruleptr;
   whyme:         anystring;

begin


(* if fact is known already, then nothing to do *)

   if nfact^.fact^.known then
      exit;

   whyme := nfact^.fact^.desc + ' ?' + nfact^.relat;
   why := why + ', determine ' + whyme;

   if trace then
      writeln('Determine fact:  ', whyme);

   if length (why)>= 200 then
   begin
      writeln;
      writeln('LOGIC NESTING IS TOO DEEP!');
      writeln('You probably have some circular rules.');
      writeln;
      writeln('Why: ', WHY);
      writeln('Trying to determine fact:  ', whyme);
      writeln;
      exit;
   end;


(* if there is no way to deduce the fact, then ask for it *)

   crule := nfact^.fact^.bythen;

   if crule = nil then
   begin
      ask_for_fact(nfact^.fact^, why);
      exit;
   end;


(* try each rule looking for this deduction *)

   while (crule <> nil) and (not nfact^.fact^.known) do
   begin
      use_rule(crule^.rule, why);
      crule := crule^.next;
   end;
end;


(**)
(* try all goals and see if any new facts can be deduced *)

procedure deduce(var kdb:       knowledgebase);
var
   cfact:         factptr;
   why:           anystring;

begin
   why := 'reach goals';
   cfact := kdb.goals;

   while (cfact <> nil) do
   begin
      determine_fact(cfact, why);
      cfact := cfact^.next;
   end;
   
   writeln;
end;


(**)
(*******************************************
 *
 *  All that follows is to build the rule database
 *
 *)


(* display memory status *)

procedure dispstatus;
begin
   write(con, #13, factcnt : 4, ' facts,  ', rulecnt : 4, ' rules,  ',
         maxavail div 64 : 3, ' kb free');
end;

(**)
(* insert entry at the end of a fact list *)

function insert_fact (var flist:     factptr): factptr;
var
   cfact:         factptr;
   
begin

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
(* insert entry at theend of a rule list *)

function insert_rule (var rlist:     ruleptr): ruleptr;
var
   crule:         ruleptr;
   
begin
   
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
(* allow operator to specify a fact; creates new facts when needed *)

function specify_fact(var kdb:       knowledgebase): factrecptr;
var
   cur:           factptr;
   newfact:       factptr;
   i:             integer;

begin
   read_line(fd, line);

   if (line = '') or (line = 'THEN') or (line = 'END') then
   begin
      specify_fact := nil;
      crelat := '';
      exit;
   end;

   crelat := '= TRUE';        {default relation if none given}


(* look for and strip off the ralation-value part of the line *)
   for i := 1 to length (line) do
   begin

      if line [i] in ['=', '#', '<', '>'] then
      begin
         crelat := copy (line, i, 80);
         line := copy (line, 1, i - 2);
      end;
   end;

   cur := kdb.facts;

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

   if (factcnt mod 8)= 0 then
      dispstatus;

   newfact := insert_fact (kdb.facts);
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
end;


(**)
(* add new rules to the rule list *)

procedure add_rule(var kdb:       knowledgebase);
var
   newrule:       ruleptr;
   cfact:         factrecptr;
   rlist:         ruleptr;
   flist:         factptr;

begin
   newrule := insert_rule (kdb.rules);
   new(newrule^.rule);

   with newrule^.rule^ do
   begin
      known := false;
      iflist := nil;
      cfact := specify_fact (kdb);

      while cfact <> nil do
      begin
         flist := insert_fact (iflist);
         flist^.fact := cfact;
         flist^.relat := crelat;
         rlist := insert_rule (cfact^.byif);
         rlist^.rule := newrule^.rule;
         cfact := specify_fact (kdb);
      end;

      thenlist := nil;
      ded := dedcnt - 1;
      cfact := specify_fact (kdb);

      while cfact <> nil do
      begin
         flist := insert_fact (thenlist);
         flist^.fact := cfact;
         flist^.relat := crelat;
         rlist := insert_rule (cfact^.bythen);
         rlist^.rule := newrule^.rule;
         cfact := specify_fact (kdb);
      end;
   end;

   rulecnt := rulecnt + 1;

   if (rulecnt mod 8)= 0 then
      dispstatus;
end;


(**)
(* read the next line of input and expect a given message *)

procedure expect (m:             anystring);
begin
   
   if eof (fd) then
      line := 'END'
   else
   begin
      
      repeat
         read_line(fd, line);
      until line <> '';
      
      if line <> m then
         writeln('"', m, '" expected, "', line, '" found');
   end;
end;


(**)
(* read a new knowledge base from a file *)

procedure file_read (var kdb:       knowledgebase;
                     name:          anystring);
var
   cfact:         factrecptr;
   ngoal:         factptr;

begin
   if pos ('.', name)= 0 then
      name := name + '.RUL';

   assign(fd, name);

{$I-}
   reset(fd);
{$I+}

   if ioresult <> 0 then
   begin
      writeln('File not found!');
      exit;
   end;

   writeln;
   writeln('Reading...');
   kdb.goals := nil;
   kdb.facts := nil;
   kdb.rules := nil;

   expect('TITLE');
   read_line(fd, kdb.title);

   expect('GOALS');
   cfact := specify_fact (kdb);

   while cfact <> nil do
   begin
      ngoal := insert_fact (kdb.goals);
      ngoal^.fact := cfact;
      cfact := specify_fact (kdb);
   end;

   expect('FACTS');
   repeat
   until specify_fact (kdb) = nil;

   expect('RULES');
   repeat
      expect('IF');
      add_rule(kdb);
   until line = 'END';

   close(fd);
   dispstatus;
   writeln;
   writeln;
end;


(**)
(* forget all fact values *)

procedure new_facts(var kdb:  knowledgebase);
var
   cfact:         factptr;
   crule:         ruleptr;

begin
   with kdb do
   begin
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
end;



(**)
(* the main program *)

begin
   clrscr;
   writeln('ESS - A simple expert system shell (inference engine)');
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

   if paramcount <> 1 then
   begin
      writeln;
      writeln('Usage:   ESS rule-filename');
      halt;
   end;

   factcnt := 0;
   rulecnt := 0;
   trace := false;
   dedcnt := 1;
   file_read(domain,paramstr (1));

   repeat
      writeln;
      writeln;
      writeln(domain.title);
      writeln;

      deduce(domain);
      writeln;

      write('Run again? (Y/N) ');
      read(kbd, c);
      c := upcase (c);
      writeln(c);

      if c = 'N' then
      begin
         writeln;
         writeln('Goodbye');
         exit;
      end;

      writeln;
      write('Forget the facts that I know? (Y/N) ');
      read(kbd, c);
      c := upcase (c);
      writeln(c);
      
      if c = 'Y' then
         new_facts(domain);
      
      dedcnt := dedcnt + 1;      {allow retries on all rules}
      
   until true = false;
end.

                                                                                                 