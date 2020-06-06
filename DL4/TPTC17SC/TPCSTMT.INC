

(*
 * TPTC - Turbo Pascal to C translator
 *
 * (C) 1988 Samuel H. Smith (rev. 13-Feb-88)
 *
 *)

(********************************************************************)
(*
 * control statement processors
 *    for, while, repeat, with, idents
 *
 * all expect tok to be keyword
 * all exit at end of statement with ltok as ; or end
 *
 *)

procedure pfor;
var
   up:       boolean;
   id:       string80;
   low,high: string80;

begin
   if debug_parse then write(' <for>');

   nospace := true;
   puts('for (');
   gettok;   {consume the FOR}

   id := plvalue;
   gettok;   {consume the :=}

   low := pexpr;

   if tok = 'TO' then
      up := true
   else

   if tok = 'DOWNTO' then
      up := false;

   gettok;
   high := pexpr;

   if up then
      puts(id+' = '+low+'; '+id+' <= '+high+'; '+id+'++) ')
   else
      puts(id+' = '+low+'; '+id+' >= '+high+'; '+id+'--) ');

   nospace := false;
   gettok;   {consume the DO}
   pstatement;
end;


(********************************************************************)
procedure pwhile;
begin
   if debug_parse then write(' <while>');

   gettok;   {consume the WHILE}

   nospace := true;
   puts('while ('+pexpr+') ');
   nospace := false;

   gettok;   {consume the DO}
   pstatement;
end;


(********************************************************************)
procedure pwith;
var
   expr:    string;
   exty:    string;
   levels:  integer;

begin
   if debug_parse then write(' <with>');

   gettok;   {consume the WITH}

   levels := 0;
   puts('{ ');
   nospace := true;
      
   repeat
      if tok[1] = ',' then 
      begin
         gettok;
         newline;
         puts('  ');
      end;
         
      expr := plvalue;
      exty := exprtype_id;
      make_pointer(expr);
      
      inc(levels);
      inc(withlevel);
      withtable[withlevel] := exty;

      puts(ljust(exty+' *',identlen));
      puts('with'+itoa(withlevel)+' = '+expr+'; ');
      
   until tok[1] <> ',';
   
   nospace := false;
   gettok;   {consume the DO}
   
   if tok[1] <> '{' then
   begin
      pstatement;
      psemi;
   end
   else

   begin
      gettok;                 {consume the open brace}
   
      while (tok[1] <> '}') and not recovery do
      begin
         pstatement;          {process the statement}
         psemi;
      end;
      
      gettok;                 {consume the close brace}
   end;

   puts('   } ');
   newline;
   usesemi;

   dec(withlevel,levels);
end;


(********************************************************************)
procedure prepeat;
begin
   if debug_parse then write(' <repeat>');

   puts('do { ');
   gettok;

   while (tok <> 'UNTIL') and not recovery do
   begin
      pstatement;
      psemi;
   end;

   gettok;
   nospace := true;
   puts('}  while (!('+ pexpr+ '))');
   nospace := false;
end;


(********************************************************************)
procedure pcase;
var
   ex:  string80;
   ex2: string80;   
   i:   integer;
   c:   char;

begin
   if debug_parse then write(' <case>');

   gettok;
   ex := pexpr;
   puts('switch ('+ex+') {');

   gettok;   {consume the OF}

   while (tok[1] <> '}') and (tok <> 'ELSE') and not recovery do
   begin

      repeat
         if tok[1] = ',' then
            gettok;

         if tok = '..' then
         begin
            gettok;
            ex2 := pexpr;
            
            if (ex2[1] = '''') or (ex2[1] = '"') then
               for c := succ(ex[2]) to ex2[2] do
               begin
                  newline;
                  puts('case ''');
                  case c of
                     '\','''': puts('\');
                  end;
                  puts(c+''':   ');
               end
            else
            
            if htoi(ex2) - htoi(ex) > 128 then
            begin
               ltok := ex+'..'+ex2;
               warning('Gigantic case range');
            end 
            else
            
            for i := succ(htoi(ex)) to htoi(ex2) do
            begin
               newline;
               write(ofd[unitlevel],'case ',i,':   ');
            end;
         end
         else
         
         begin
            ex := pexpr;
            newline;
            puts('case '+ex+':   ');
         end;

      until (tok[1] = ':') or recovery;
      gettok;

      if (tok[1] <> '}') and (tok <> 'ELSE') then
         pstatement;
      puts('break; ');
      newline;
      usesemi;
   end;

   if tok = 'ELSE' then
   begin
      newline;
      puts('default: ');
      gettok;   {consume the else}

      while (tok[1] <> '}') and not recovery do
      begin
         if (tok[1] <> '}') and (tok <> 'ELSE') then
            pstatement;
         usesemi;
      end;
   end;

   puttok;
   gettok;
   usesemi;
end;


(********************************************************************)
procedure pif;
var
   pspace: integer;
begin
   if debug_parse then write(' <if>');

   gettok;   {consume the IF}

   pspace := length(spaces);
   nospace := true;
   puts('if ('+ pexpr+ ') ');
   nospace := false;
   
   gettok;   {consume the THEN}

   if (tok[1] <> '}') and (tok <> 'ELSE') then
      pstatement;

   if tok = 'ELSE' then
   begin
      spaces := copy(spaces,1,pspace);
      if not linestart then
         newline;
      puts('else ');

      gettok;
      if tok[1] <> '}' then
         pstatement;
   end;

end;


(********************************************************************)
procedure pexit;
begin
   if debug_parse then write(' <exit>');

   puts('return;');

   gettok;
   usesemi;
end;


(********************************************************************)
procedure pgoto;
var
   ex:  anystring;

begin
   gettok;                      {consume the goto}

   if toktype = number then
      ltok := 'label_' + ltok;  {modify numeric labels}

   puts('goto '+ltok+';');

   gettok;                      {consume the label}
   usesemi;
end;


(********************************************************************)
procedure phalt;
var
   ex: anystring;

begin
   if debug_parse then write(' <halt>');

   gettok;

   if tok[1] = '(' then
   begin
      gettok;
      ex := pexpr;
      gettok;
   end
   else
      ex := '0';     {default exit expression}

   puts('exit('+ex+');');

   usesemi;
end;


(********************************************************************)
procedure pread;
var
   ctl:  string;
   func: anystring;
   ex:   paramlist;
   p:    string;
   ln:   boolean;
   ty:   string[2];
   i:    integer;

begin
   if debug_parse then write(' <read>');
   
   nospace := true;   {don't copy source whitespace to output during
                       this processing.  this prevents spaces from
                       getting moved around}

   ln := tok = 'READLN';
   nospace := true;
   func := 'scanf(';

   gettok;   {consume the read}

   if tok[1] = '(' then
   begin
      gettok;

      if ltok[1] = '[' then   {check for MT+ [addr(name)], form}
      begin
         gettok;   {consume the '[' }

         if tok[1] = ']' then
            func := 'scanf('
         else

         begin
            gettok;   {consume the ADDR}
            gettok;   {consume the '(' }
            func := 'tiscanf(' + usetok + ',';
            gettok;   {consume the ')'}
         end;

         gettok;   {consume the ']'}
         if tok[1] = ',' then
            gettok;
      end;

      ctl := '';
      ex.n := 0;

      while (tok[1] <> ')') and not recovery do
      begin
         p := pexpr;
         ty := exprtype;

         {convert to fprintf if first param is a file variable}
         if (ex.n = 0) and (ty = '@') then
         begin
            make_pointer(p);
            func := 'tscanf(' + p + ',';
         end
         else

         {process a new expression; add expressions to ex.id table
          and append proper control codes to the control string}
         begin
            if ty <> 's' then
               if p[1] = '*' then
                  delete(p,1,1)
               else
                  p := '&' + p;
            inc(ex.n);
            if ex.n > maxparam then
               fatal('Too many params (pread)');
            ex.id[ex.n] := p;
            ctl := ctl + '%'+ty;
         end;

         if tok[1] = ',' then
            gettok;
      end;

      gettok;   {consume the )}

      if ctl = '%s' then
         ctl := '#';
      if ln then
         ctl := ctl + '\n';

      if func[1] <> 't' then
         func := 't' + func + '&input,';

      puts(func+'"'+ctl+'"');
      for i := 1 to ex.n do
         puts(','+ex.id[i]);

      puts(')');
   end

   else   {otherwise there is no param list}
      if ln then
         puts('scanf("\n")');

   nospace := false;
   forcesemi;
end;


(********************************************************************)
type
   write_modes = (m_write, m_writeln, m_str);

procedure pwrite(mode: write_modes);
var
   ctl:  string;
   func: anystring;
   ex:   paramlist;
   p:    string;
   ty:   string[2];
   i:    integer;

   procedure addform(f: anystring);
      {add a form parameter, special handling for form expressions}
   begin
      if isnumber(f) then
         ctl := ctl + f      {pass literal form}
      else

      begin                      {insert form expression in parlist}
         ctl := ctl + '*';
         inc(ex.n);
         if ex.n > maxparam then
            fatal('Too many params (pwrite.form)');
         ex.id[ex.n] := ex.id[ex.n-1];
         ex.id[ex.n-1] := f;
      end;
   end;
   
begin
   if debug_parse then write(' <write>');
   
   nospace := true;   {don't copy source whitespace to output during
                       this processing.  this prevents spaces from
                       getting moved around}

   nospace := true;

   if mode = m_str then
      func := 'sbld('
   else
      func := 'printf(';
      
   gettok;   {consume the write}
   
   if tok[1] = '(' then
   begin
      gettok;   {consume the (}

      if ltok[1] = '[' then   {check for MT+ [addr(name)], form}
      begin
         gettok;   {consume the '[' }

         if tok[1] <> ']' then
         begin
            gettok;   {consume the ADDR}
            gettok;   {consume the '(' }
            func := 'tiprintf(' + usetok + ',';
            gettok;   {consume the ')'}
         end;

         gettok;   {consume the ']'}
         if tok[1] = ',' then
            gettok;
      end;

      ctl := '';
      ex.n := 0;

      while (tok[1] <> ')') and not recovery do
      begin
         p := pexpr;
         ty := exprtype;

         {convert to fprintf if first param is a file variable}
         if (ex.n = 0) and (ty = '@') then
         begin
            make_pointer(p);
            func := 'tprintf(' + p + ',';
         end
         else

         {process a new expression; add expressions to ex.id table
          and append proper control codes to the control string}
         begin
            inc(ex.n);
            if ex.n > maxparam then
               fatal('Too many params (pwrite)');
            ex.id[ex.n] := p;

            if ty = 'D' then
               ty := 'ld';
            if ty = 'b' then
               ty := 'd';

            {decode optional form parameters}
            if tok[1] = ':' then
            begin
               ctl := ctl + '%';
               cexprsym := voidsym; {prevent implicit conversions}
               gettok;
               addform(pexpr);               
               
               if tok[1] = ':' then
               begin
                  ctl := ctl + '.';
                  gettok;
                  addform(pexpr);
                  ty := 'f';
               end;
               
               ctl := ctl + ty;
            end
            else

            begin
               {pass literals into the control string}
                  {note: need to add escape conversions and % doubling}
               if (p[1] = '"') or (p[1] = '''') then
               begin
                  ctl := ctl + copy(p,2,length(p)-2);
                  dec(ex.n);
               end

               {otherwise put in the control string for this param}
               else
                  ctl := ctl + '%'+ty;
            end;
         end;

         if tok[1] = ',' then
            gettok;
      end;

      gettok;   {consume the )}

      {add newline in 'writeln' translation}
      if mode = m_writeln then
         ctl := ctl + '\n';

      {convert last parameter into destination in 'str' translation}
      if mode = m_str then
      begin
         func := func + ex.id[ex.n] + ',';
         dec(ex.n);
         delete(ctl,length(ctl)-1,2);
      end;

      {produce the translated statement}
      puts(func+'"'+ctl+'"');
      for i := 1 to ex.n do
         puts(','+ex.id[i]);

      puts(')');
   end

   else   {otherwise there is no param list}
      if mode = m_writeln then
         puts('printf("\n")');

   nospace := false;
   forcesemi;
end;


(********************************************************************)
procedure pnew;
var
   lv:   string;
   ty:   string80;

begin
   if debug_parse then write(' <new>');

   gettok;   {consume the new}
   gettok;   {consume the (}

   lv := plvalue;
   ty := exprtype_id;
   if cexprsym^.symtype = ss_pointer then
      ty := ty + ' *';

   puts(lv+' = ('+ty+') malloc(sizeof(*'+lv+'));');

   gettok;   {consume the )}
   usesemi;
end;


(********************************************************************)
procedure pport(kw: string);
   {translate port/portw/mem/memw}
var
   lv: string;

begin
   if debug_parse then write(' <port>');

   lv := kw + '(';

   gettok;     {consume the keyword}
   gettok;     {consume the [ }

   repeat
      lv := lv + pexpr;
      if tok[1] = ':' then
      begin
         gettok;
         lv := lv + ',';
      end;
   until (tok[1] = ']') or recovery;

   gettok;     {consume the ] }

   if tok = ':=' then
   begin
      gettok;       {consume :=, assignment statement}
      lv := lv + ',' + pexpr;
   end;

   puts(lv+');');
   usesemi;
end;


(********************************************************************)
procedure pinline;
   {translate inline statements}

var
   sixteen: boolean;

begin
   if debug_parse then write(' <inline>');

   gettok;     {consume the keyword}
   nospace := true;
   gettok;

   while (tok[1] <> ')') and not recovery do
   begin
      if tok[1] = '/' then
         gettok;

      if tok[1] = '>' then
      begin
         gettok;
         sixteen := true;
      end
      else
         sixteen := htoi(ltok) > $00ff;

      putline;
      if sixteen then
         puts('      asm DW '+ltok+'; ')
      else
         puts('      asm DB '+ltok+'; ');
      gettok;
   end;

   nospace := false;
   gettok;     {consume the ) }
   usesemi;
end;


(********************************************************************)
procedure pident;
   {parse statements starting with an identifier;  these are either
    assignment statements, function calls, return-value assignments,
    or label identifiers}
var
   ex:   string;
   lv:   string;
   lvt,
   ext:  char;
   ety,
   rty:  string;

begin
   if debug_parse then write(' <ident>');

   nospace := true;   {don't copy source whitespace to output during
                       this processing.  this prevents spaces from
                       getting moved around}

   lv := plvalue;     {destination variable or function name}
   lvt := exprtype;   {destination data type}
   rty := exprtype_id;
   if cexprsym^.symtype = ss_pointer then
      rty := rty + ' *';

   if tok = ':=' then
   begin
      if debug_parse then write(' <assign>');
      
      gettok;       {consume :=, assignment statement}
      ex := pexpr;
      ext := exprtype;
      ety := exprtype_id;
      if cexprsym^.symtype = ss_pointer then
         ety := ety + ' *';

      if iscall(lv) then      {assignment to function name}
         puts('return '+ex)
      else

      begin
(*
if debug then
writeln('assign: lv{',lv,'}',lvt,' ex{',ex,'}',ext);
*)
         if copy(ex,1,5) = 'scat(' then
            lv := 'sbld('+lv+',' + copy(ex,6,255)
         else

         if lvt = 's' then
         begin
            if ex[1] = '''' then
            begin
               ex[1] := '"';
               ex[length(ex)] := '"';
               ext := 's';
            end;

            if ext = 's' then
               lv := 'strcpy('+lv+','+ex+')'
            else
               lv := 'sbld('+lv+',"%'+ext+'",'+ex+')';
         end
         else

         if lvt = 'c' then
            if ext = 's' then
               lv := lv+' = first('+ex+')'
            else
               lv := lv+' = '+ex
         else

         if rty <> ety then
         begin
            lv := lv + ' = ' + typecast(rty, ex);
(**
            ltok := ex;
            warning('('+ety+') casted to ('+rty+')');
**)
         end
         else
            lv := lv + ' = ' + ex;

         puts(lv);
      end;
   end
   else

   if tok[1] = ':' then
   begin
      if debug_parse then write(' <label>');
      
      putline;
      puts(lv+': ');

      gettok;       {label identifier}
      usesemi;
      exit;
   end
   else

   begin   
      if debug_parse then write(' <call>');

      if not iscall(lv) then
         lv := lv + '()';
      puts(lv);
   end;
   
   nospace := false;
   forcesemi;
end;




(********************************************************************)
procedure pnumlabel;
   {parse statements starting with an number;  these must be
    numeric labels}
begin
   if debug_parse then write(' <numlabel>');

   putline;
   puts('label_'+tok+': ');

   gettok;      {consume the number}
   gettok;      {consume the :}
end;


(********************************************************************)
procedure plabel;
   {parse (and throw away) a label section}
begin
   if debug_parse then write(' <label>');

   while tok[1] <> ';' do
      gettok;

   gettok;
end;




(********************************************************************)
(*
 * process single statement
 *
 * expects tok to be first token of statement
 * processes nested blocks
 * exits with tok as end of statement
 *
 *)

procedure pstatement;
var
   builtin: boolean;
   
begin

   if recovery then
   begin
      while tok[1] <> ';' do
         gettok;
      gettok;
      recovery := false;
      exit;
   end;
   
   if (toktype = identifier) and (cursym <> nil) then
      builtin := cursym^.symtype = ss_builtin
   else
      builtin := false;

   if debug_parse then write(' <stmt>');

   if toktype = number then
      pnumlabel
   else
   
   case tok[1] of
   '.':
      exit;

   ';':
      begin
         puts('; ');
         gettok;
      end;
      
   '{':
      pblock;

   'C':
      if tok = 'CASE' then
         pcase
      else
         pident;

   'E':
      if builtin and (tok = 'EXIT') then
         pexit
      else
         pident;

   'F':
      if tok = 'FOR' then
         pfor
      else
         pident;
      
   'G':
      if tok = 'GOTO' then
         pgoto
      else
         pident;
         
   'H':
      if tok = 'HALT' then
         phalt
      else
         pident;
         
   'I':
      if tok = 'IF' then
         pif
      else
      if tok = 'INLINE' then
         pinline
      else
         pident;
         
   'M':
      if builtin and (tok = 'MEM') then
         pport('pokeb')
      else
      if builtin and (tok = 'MEMW') then
         pport('poke')
      else
         pident;
         
   'N':
      if tok = 'NEW' then
         pnew
      else
         pident;
         
   'P':
      if builtin and (tok = 'PORT') then
         pport('outportb')
      else
      if builtin and (tok = 'PORTW') then
         pport('outport')
      else
         pident;
         
   'R':
      if tok = 'REPEAT' then
         prepeat
      else
      if tok = 'READ' then
         pread
      else
      if tok = 'READLN' then
         pread
      else
         pident;

   'S':
      if builtin and (tok = 'STR') then
         pwrite(m_str)
      else
         pident;
                  
   'W':
      if tok = 'WHILE' then
         pwhile
      else
      if tok = 'WITH' then
         pwith
      else
      if tok = 'WRITE' then
         pwrite(m_write)
      else
      if tok = 'WRITELN' then
         pwrite(m_writeln)
      else
         pident;
   else
      pident;
   end;
end;


(********************************************************************)
(*
 * process begin...end blocks
 *
 * expects tok to be begin
 * exits with tok = end
 *
 *)

procedure pblock;
begin
   if debug_parse then write(' <block>');

   puts('{ ');
   gettok;                 {get first token of first statement}

   while (tok[1] <> '}') and not recovery do
   begin
      pstatement;          {process the statement}
      psemi;
   end;

   if not linestart then
      newline;
      
   puttok;                 {put the closing brace}
   gettok;
   usesemi;
end;


