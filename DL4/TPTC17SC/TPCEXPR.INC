
(*
 * TPTC - Turbo Pascal to C translator
 *
 * (C) 1988 Samuel H. Smith (rev. 13-Feb-88)
 *
 *)


(*
 * expression parser
 *
 *)
function pterm: string; forward;


(********************************************************************)
function iscall(var lv: string): boolean;
   {see if the given lvalue is a function call or not}
begin
   iscall := lv[length(lv)] = ')';
end;


(********************************************************************)
function typecast(ty: string; ex: string): string;
   {generate a typecasted expression}
begin
   if pos(' ',ex) > 0 then
      ex := '(' + ex + ')';
   typecast := '(' + ty + ') ' + ex;
end;


(********************************************************************)
procedure make_pointer(var expr: string);
   {convert the expression into a pointer constant, if possible}
var
   sym:  symptr;
   p:    integer;
   nex:  string;
begin
   
   sym := voidsym;
   nex := expr;

   case(expr[1]) of
      '*':
         nex := copy(expr,2,255);
      
      '(':
         begin          {possible typecast}
            p := pos(')(*',expr);
            if p = 0 then
               nex := '&(' + expr + ')'
            else
               nex := copy(expr,1,p-1) + ' *) (' + copy(expr,p+3,255);
         end;

      'a'..'z','A'..'Z','_':
         begin          {pass pointer to strings/arrays}
            sym := locatesym(expr);
            if sym = nil then
               sym := voidsym;

            if (sym^.symtype = ss_scalar) then
               sym := sym^.parent;

            if (sym <> nil) and ((sym^.symtype = ss_array) or
                                 (sym^.symtype = ss_pointer)) then
            begin
               {nex := expr;}
            end
            else
            
            if expr[length(expr)-1] = '(' then    {remove () from calls}
               nex := copy(expr,1,length(expr)-2)
            else
               nex := '&' + expr;
         end;

      {else
         nex := expr;}
   end;

if debug then
writeln('mp1: expr=',expr,' nex=',nex, ' ty=',typename[sym^.symtype]);

   expr := nex;
end;


(********************************************************************)
function isnumber(var lv: string): boolean;
  {see if the given value is a literal number}
var
   i: integer;
begin

   case lv[1] of
      '0'..'9','.':
          ;
      else
         isnumber := false;
         exit;
   end;

   for i := 2 to length(lv) do
      case lv[i] of
         '0'..'9','.', 'x','X', 'A'..'F','a'..'f','L':
            ;
         else
            isnumber := false;
            exit;
      end;

   isnumber := true;
end;


(********************************************************************)
procedure subtract_base(var expr: string; base: integer);
   {subtract the specified base from the given expression;
    use constant folding if possible}
begin

if debug then
writeln(' base1=',base,' ex=',expr);

   if base <> 0 then
   begin
      if isnumber(expr) then
         expr := itoa(htoi(expr) - base)
      else
      if base > 0 then
         expr := expr + '-' + itoa(base)
      else
         expr := expr + '+' + itoa(-base);
   end;
end;


(********************************************************************)
function exprtype: char;
   {determine expression type and return the printf code for the type}
var
   xt:      char;
   sym:     symptr;
   
begin
   case cexprsym^.symtype of
      ss_scalar,
      ss_func,     
      ss_const,    
      ss_builtin:    sym := cexprsym^.parent;
      
      else           sym := cexprsym;
   end;
   
   if (sym = stringsym) {or (cexprsym = stringsym)} then
      xt := 's'
   else
   case sym^.symtype of
      s_char:    xt := 'c';
      s_text:    xt := '@';
      s_file:    xt := '!';
      s_double:  xt := 'f';
      s_bool:    xt := 'b';
      s_int:     xt := 'd';
      s_long:    xt := 'D'; { calling routine should convert to "ld" }
      else       xt := '?';
   end;

(**
if debug then
writeln(^M^J'..symtype id=',cexprsym^.id,
                 ' ty=',typename[cexprsym^.symtype],
                 ' p=',cexprsym^.parent^.id,
                 ' xt=',xt);
**)
   exprtype := xt;
end;


(********************************************************************)
function exprtype_id: string;
   {return type identifier for current expression}
begin
(**
   if (cexprsym^.symtype = ss_pointer) or
      (cexprsym^.symtype = ss_array) then {hack?}
      exprtype_id := cexprsym^.parent^.repid +'`1'
   else
**)
   exprtype_id := cexprsym^.parent^.repid;
end;


(********************************************************************)
function strtype(ty: char): boolean;
   {see if the expression is a string data type or not}
begin
   case ty of
      's','c':  strtype := true;
      else      strtype := false;
   end;
end;


(********************************************************************)
function psetof:  string;
   {parse a literal set; returns the set literal translated into
    the form: setof(.....)}
var
   ex: string;

begin
   ex := 'setof(';
   if tok[1] <> ']' then
      ex := ex + pterm;

   while (tok = '..') or (tok[1] = ',') do
   begin
      if tok = '..' then       
         ex := ex + ',__,'
      else
         ex := ex + ',';

      gettok;
      ex := ex + pterm;
   end;

   if ex[length(ex)] <> '(' then
      ex := ex + ',';
   ex := ex + '_E)';
   psetof := ex;
end;


(********************************************************************)
function pterm:   string;
   {parse an expression term;  returns the translated expression term;
    detects subexpressions, set literals and lvalues(variable names)}
var
   ex: string;
   builtin: boolean;

begin
   if debug_parse then write(' <term>');

   if (toktype = identifier) and (cursym <> nil) then
      builtin := cursym^.symtype = ss_builtin
   else
      builtin := false;

   (* process pos(c,str) and pos(str,str) *)
   if builtin and (length(tok) = 3) and (tok = 'POS') then
   begin
      if debug_parse then write(' <pos>');

      gettok;   {consume the keyword}
      if tok[1] <> '(' then
         syntax('"(" expected (pterm.pos)');
      
      gettok;   {consume the (}
      ex := pexpr;
      if exprtype = 'c' then
         ex := 'cpos(' + ex
      else
         ex := 'spos(' + ex;

      gettok;   {consume the ,}
      ex := ex + ',' + pexpr;
      gettok;   {consume the )}
      pterm := ex + ')';
      cexprsym := intsym;
   end
   else

   (* process chr(n) *)
   if builtin and (length(tok) = 3) and (tok = 'CHR') then
   begin
      if debug_parse then write(' <chr>');

      gettok;   {consume the keyword}
      if tok[1] <> '(' then
         syntax('"(" expected (pterm.chr)');
      
      gettok;   {consume the (}
      ex := pexpr;
      gettok;   {consume the )}

      if isnumber(ex) then
         ex := numlit(htoi(ex))
      else
         ex := 'chr('+ex+')';

      pterm := ex;
      cexprsym := charsym;
   end
   else

   (* translate NOT term into !term *)
   if builtin and (length(tok) = 3) and (tok = 'NOT') then
   begin
      if debug_parse then write(' <not>');

      gettok;
      pterm := '!' + pterm;
      cexprsym := boolsym;
   end
   else

   (* process port/memory array references *)
   if builtin and ( ((length(tok) = 3) and (tok = 'MEM')    ) or
                    ((length(tok) = 4) and ((tok = 'PORT') or (tok = 'MEMW')) ) or
                    ((length(tok) = 5) and (tok = 'PORTW')  ) ) then
   begin
      if debug_parse then write(' <port>');

      if tok = 'PORT'  then ex := 'inportb('    else
      if tok = 'PORTW' then ex := 'inport('     else
      if tok = 'MEM'   then ex := 'peekb('      else
                            ex := 'peek(';

      gettok;     {consume the keyword}
      gettok;     {consume the [ }

      repeat
         ex := ex + pexpr;
         if tok[1] = ':' then
         begin
            gettok;
            ex := ex + ',';
         end;
      until (tok[1] = ']') or recovery;

      gettok;     {consume the ] }
      pterm := ex + ')';
      cexprsym := intsym;
   end
   else

   (* translate bitwise not (mt+) *)
   if (tok[1] = '?') or (tok[1] = '~') or (tok[1] = '\') then
   begin
      if debug_parse then write(' <bitnot>');

      gettok;
      pterm := '!' + pterm;         {what is a bitwise NOT in c?}
   end
   else

   (* process unary minus *)
   if (length(tok) = 1) and (tok[1] = '-') then
   begin
      if debug_parse then write(' <unary>');

      gettok;
      pterm := '-' + pterm;
   end
   else

   (* translate address-of operator *)
   if tok[1] = '@' then
   begin
      if debug_parse then write(' <ref>');

      gettok;  {consume the '@'}
      ex := plvalue;
      make_pointer(ex);
      pterm := ex;
   end
   else

   (* translate address-of operator *)
   if builtin and ((length(tok) = 4) and (tok = 'ADDR')) then
   begin
      if debug_parse then write(' <addr>');

      gettok;  {consume the 'ADDR'}
      gettok;  {consume the (}
      ex := plvalue;
      make_pointer(ex);
      gettok;  {consume the )}
      pterm := ex;
   end
   else

   (* pass numbers *)
   if toktype = number then
   begin
      if debug_parse then write(' <number>');

      case exprtype of
         'D':  begin
                  pterm := tok + 'L';
                  gettok;
                  cexprsym := longsym;
               end;

         'f':  begin
                  pterm := tok + '.0';
                  gettok;
                  cexprsym := doublesym;
               end;

      else     begin
                  pterm := tok;
                  gettok;
                  cexprsym := intsym;
               end;
      end;
   end
   else

   if toktype = longnumber then
   begin
      if debug_parse then write(' <long.number>');

      pterm := tok;
      gettok;
      cexprsym := longsym;
   end
   else

   if toktype = realnumber then
   begin
      if debug_parse then write(' <real.number>');

      pterm := tok;
      gettok;
      cexprsym := doublesym;
   end
   else

   (* pass strings *)
   if toktype = strng then
   begin
      if debug_parse then write(' <string>');

      pterm := tok;
      gettok;
      cexprsym := stringsym; {charptrsym;}
   end
   else

   (* pass characters *)
   if toktype = chars then
   begin
      if debug_parse then write(' <char>');

      pterm := tok;
      gettok;
      cexprsym := charsym;
   end
   else

   (* pass sub expressions *)
   if tok[1] = '(' then
   begin
      if debug_parse then write(' <subexp>');

      gettok;
      pterm := '(' + pexpr + ')';
      gettok;
   end
   else

   (* translate literal sets *)
   if tok[1] = '[' then
   begin
      if debug_parse then write(' <setlit>');

      gettok;
      pterm := psetof;
      gettok;
      cexprsym := voidsym;
   end

   (* otherwise the term will be treated as an lvalue *)
   else
      pterm := plvalue;
end;


(********************************************************************)
function plvalue: string;
   {parse and translate an lvalue specification and return the translated
    lvalue as a string}

var
   lv:       string;
   ex:       string;
   prefix:   string40;
   idok:     boolean;
   sym:      symptr;
   bsym:     symptr;
   pvars:    integer;
   recid:    string40;

begin

   if debug_parse then write(' <lvalue>');
   plvalue := 'lvalue';

(* lvalues must begin with an identifier in pascal *)
   if toktype <> identifier then
   begin
      syntax('Identifier expected (plvalue)');
      exit;
   end;

(* assign initial part of the lvalue *)
   idok := false;
   prefix := '';

   sym := cursym;
   if sym = nil then
   begin
      sym := voidsym;
      lv := ltok;
   end
   else
      lv := sym^.repid;          {use replacement identifier}

   recid := lv;
   cexprsym := sym;
   while cexprsym^.symtype = ss_subtype do
      cexprsym := cexprsym^.parent;

   {dereference VAR paremter pointers}
   if sym^.parcount = -2 then
   begin
      if debug_parse then write(' <var.deref>');
      prefix := '*';
   end;

   {prefix with pointer if this is a member identifier and a
    'with' is in effect}
   if (sym^.parcount < 0) and (sym^.pvar > 0) and (withlevel > 0) then
   begin
      if debug_parse then write(' <with.deref>');
      prefix := 'with'+itoa(withlevel)+'->';
   end;

   {check for typecasts}
   gettok;
   if (tok[1] = '(') then
   begin
      if (sym <> voidsym) and (cexprsym^.symtype <> ss_func) then
      begin
         lv := '(' + lv + ') ';
         if debug_parse then write(' <cast>');
      end;
   end;
   

(* process a list of qualifiers and modifiers *)

   repeat
(*
if debug then
writeln('lv1=',prefix,lv,' ty=',cexprsym^.parent^.repid,' b=',cexprsym^.base);
*)
      if toktype = identifier then
      begin

         if cursym = nil then
            cexprsym := voidsym
         else
         
         {find record member types}
         begin
            sym := cursym;
            cexprsym := sym;
            ltok := sym^.repid;          {use replacement identifier}
         end;
         
      end;
      
      (* process identifiers (variable or field names) *)
      if idok and (toktype = identifier) then
      begin
         if debug_parse then write(' <ident>');

         ex := ltok;
         idok := false;
         lv := lv + ex;
         gettok;
      end
      else

      (* pointers *)
      if (length(tok) = 1) and (tok[1] = '^') then
      begin
         if debug_parse then write(' <deref>');

         prefix := '*' + prefix;
         gettok;
         if (cexprsym^.symtype = ss_scalar) and
            (cexprsym^.parent^.symtype = ss_pointer) then
            cexprsym := cexprsym^.parent;

         cexprsym := cexprsym^.parent;
       { if cexprsym^.symtype = ss_pointer then
            cexprsym := cexprsym^.parent; } {hack??}
      end
      else

      (* pointer members *)
      if (length(tok) = 2) and (tok[1] = '^') and (tok[2] = '.') then
      begin
         if debug_parse then write(' <ptr.deref>');

         lv := lv + '->';
         gettok;
         idok := true;
         cexprsym := cexprsym^.parent;
      end
      else

      (* record members *)
      if (length(tok) = 1) and (tok[1] = '.') then
      begin
         if debug_parse then write(' <member>');

         if prefix = '*' then     {translate *id. into id->}
         begin
            prefix := '';
            lv := lv + '->';
         end
         else
            lv := lv + '.';
         idok := true;
         gettok;
         cexprsym := cexprsym^.parent;
      end
      else

      (* subscripts, pointer subscripts *)
      if (tok[1] = '[') or
         ((length(tok) = 2) and (tok[1] = '^') and (tok[2] = '[')) then
      begin
         if debug_parse then
            if tok[1] = '^' then
               write(' <ptr.subs>')
            else
               write(' <subs>');

         if tok[1] = '^' then
         begin
            cexprsym := cexprsym^.parent;
            lv := lv + '[0]';
         end;
         bsym := cexprsym;

         if copy(prefix,1,1) = '*' then
            prefix := '';       {replace '*id[' with 'id['}

         lv := lv + '[';
         gettok;

         repeat
            ex := pexpr;

            if tok[1] = ',' then
            begin
               lv := lv + ex + '][';
               gettok;
               subtract_base(ex,bsym^.base);
            end;
         until tok[1] = ']';

         subtract_base(ex,bsym^.base);
         if bsym^.symtype = ss_array then
            bsym := bsym^.parent
         else
         begin
            bsym := bsym^.parent;
            if bsym^.symtype = ss_array then 
               bsym := bsym^.parent;   {hack??}
         end;
         lv := lv + ex + ']';

         cexprsym := bsym;
         gettok;
(*
if debug then
writeln('...lv2=',lv,' ty=',bsym^.repid,' b=',bsym^.base);
*)
      end
      else

      (* function calls *)
      if tok[1] = '(' then
      begin
         if debug_parse then write(' <param>');

         pvars := 0;
         bsym := cexprsym;           {determine return type}
         pvars := cexprsym^.pvar;    {determine parameter types}

         lv := lv + '(';
         gettok;

         while tok[1] <> ')' do
         begin
            ex := pexpr;
            if (pvars and 1) = 1 then     {prefix VAR paremeters}
               make_pointer(ex);

            lv := lv + ex;
            pvars := pvars shr 1;

            if (tok[1] = ',') or (tok[1] = ':') then
            begin
               lv := lv + ',';
               gettok;
            end;
         end;

         lv := lv + ')';
         gettok;
         cexprsym := bsym;
      end
      else

(* otherwise just return what was found so far *)
      begin

         (* add dummy param list to function calls where the proc
            expects no parameters *)
         if sym <> nil then
         begin
            if (not iscall(lv)) and (sym^.parcount >= 0) then
               lv := lv + '()';
         end;

         if length(prefix)+length(lv) >= 255 then
            warning('Expression too long');
         plvalue := prefix + lv;
(*
if debug then
writeln('...lv3=',prefix,lv,' ty=',cexprsym^.parent^.repid,' b=',cexprsym^.base);
*)
         exit;
      end;

   until recovery;

   plvalue := prefix + lv;
end;


(********************************************************************)
function pexpr: string;
   {top level expression parser; parse and translate an expression and
    return the translated expr}
var
   ex:       string;
   ty:       char;
   ex2:      string;
   ty2:      char;
   endexpr:  boolean;

   procedure relop(newop: string40);
   begin
      if debug_parse then write(' <relop>');

      gettok;        {consume the operator token}

      ex2 := pterm;  {get the second term}
      ty2 := exprtype;

      {use strcmp if either param is a string}
      if ty = 's' then
      begin
         if ty2 = 's' then
            ex := 'strcmp(' + ex + ',' + ex2 + ') ' + newop + ' 0'
         else
         if ex2[1] = '''' then
            ex := 'strcmp(' + ex + ',"' +
                     copy(ex2,2,length(ex2)-2) + '") ' + newop + ' 0'
         else
            ex := 'strcmp(' + ex + ',ctos(' + ex2 + ')) ' + newop + ' 0'
      end
      else

      if ty = 'c' then
      begin
         if ty2 = 's' then
            ex := 'strcmp(ctos(' + ex + '),' + ex2 + ') ' + newop + ' 0'
         else
            ex := ex + ' ' + newop + ' ' + ex2
      end

      else
         ex := ex + ' ' + newop + ' ' + ex2;

      cexprsym := boolsym;
   end;


   procedure addop;

      procedure add_scat;
      var
         p,q: integer;

      begin
         {find end of control string}
         p := 7;  {position of 'scat("%'}
         while (ex[p] <> '"') or
               ((ex[p] = '"') and (ex[p-1] = '\') and (ex[p-2] <> '\')) do
            p := succ(p);
         p := succ(p);

         {add literals to the control string if possible}
            {note: need to add escape conversions and % doubling}
         if (ex2[1] = '''') or (ex2[1] = '"') then
         begin
            ex := copy(ex,1,p-2) + 
                  copy(ex2,2,length(ex2)-2) +
                  copy(ex,p-1,length(ex)-p+2);
         end

         else {add a parameter to the control string}
            ex := copy(ex,1,p-2) + '%' + ty2 +
                  copy(ex,p-1,length(ex)-p+1) + ',' + ex2 + ')';

         cexprsym := stringsym; {charptrsym??;}
      end;

   begin
      if debug_parse then write(' <addop>');

      gettok;        {consume the operator token}

      ex2 := pterm;  {get the second term}
      ty2 := exprtype;
(*
if debug then
writeln('ex{',ex,'}',ty,' ex2{',ex2,'}',ty2);   
*)
      {continue adding string params to scat control string}
      if (ex[5] = '(') and (copy(ex,1,4) = 'scat') then
         add_scat
      else

      {start new scat call if any par is a string}
      if strtype(ty) or strtype(ty2) then
      begin
         if (ex[1] = '''') or (ex[1] = '"') then
            ex := 'scat("' + copy(ex,2,length(ex)-2) + '")'
         else
            ex := 'scat("%' + ty + '",' + ex + ')';
         add_scat;
      end
      else
         ex := ex + ' + ' + ex2;

(*
if debug then
writeln('ex=',ex);   
*)
   end;

   procedure mulop(newop: string40);
   begin
      if debug_parse then write(' <mulop>');

      gettok;        {consume the operator token}

      ex2 := pterm;  {get the second term}
      ex := ex + ' ' + newop + ' ' + ex2;
   end;

   procedure andop(newop: char);
   begin
      if debug_parse then write(' <andop>');

      gettok;        {consume the operator token}

      ex2 := pterm;  {get the second term}
      ty2 := exprtype;

      {boolean and/or?}
      if (ty = 'b') or (ty2 = 'b') then
      begin
         ex := ex + ' ' + newop + newop + ' ' + ex2;
         cexprsym := boolsym;
      end
      else  {otherwise bitwise}
         ex := ex + ' ' + newop + ' ' + ex2;
   end;


begin {pexpr}

   if debug_parse then write(' <expr>');
   ex := pterm;
   ty := exprtype;
   endexpr := false;

   while not endexpr do

      (* process operators *)
      case length(tok) of
          1: if      tok[1] = '>' then relop(tok)
             else if tok[1] = '<' then relop(tok)
             else if tok[1] = '=' then relop('==')
             else if tok[1] = '+' then addop
             else if tok[1] = '-' then mulop(tok)
             else if tok[1] = '*' then mulop(tok)
             else if tok[1] = '/' then mulop(tok)
             else if tok[1] = '&' then mulop(tok)  {mt+}
             else if tok[1] = '!' then mulop('|')  {mt+}
             else if tok[1] = '|' then mulop('|')  {mt+}
             else endexpr := true;

          2: if      (tok[1] = '>') and (tok[2] = '=') then relop(tok)
             else if (tok[1] = '<') and (tok[2] = '=') then relop(tok)
             else if (tok[1] = '<') and (tok[2] = '>') then relop('!=')
             else if (tok[1] = 'O') and (tok[2] = 'R') then andop('|')

                        (* translate the expr IN set operator *)
             else if (tok[1] = 'I') and (tok[2] = 'N') then
                begin
                   gettok;
                   ex := 'inset('+ex+',' + pterm + ')';
                end
             else endexpr := true;

          3: if      (tok[1]='D') and (tok[2]='I') and (tok[3]='V') then mulop('/')
             else if (tok[1]='M') and (tok[2]='O') and (tok[3]='D') then mulop('%')
             else if (tok[1]='S') and (tok[2]='H') and (tok[3]='R') then mulop('>>')
             else if (tok[1]='S') and (tok[2]='H') and (tok[3]='L') then mulop('<<')
             else if (tok[1]='X') and (tok[2]='O') and (tok[3]='R') then mulop('^')
             else if (tok[1]='A') and (tok[2]='N') and (tok[3]='D') then andop('&')
             else endexpr := true;

        else endexpr := true;
      end;


   (* ran out of legal expression operators; return what we found *)
   if length(ex) >= 255 then
      warning('Expression too long');

   pexpr := ex;

(*
write('ex=',ex,' ty=',exprtype);
if cexprsym=nil then
     writeln(' nil')
else writeln(' sym=',cexprsym^.repid);
*)

end;



