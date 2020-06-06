
(*
 * TPTC - Turbo Pascal to C translator
 *
 * (C) 1988 Samuel H. Smith (rev. 13-Feb-88)
 *
 *)

function exprlimit(var ex: string): integer;
   {determine limit value for given static expression}
var
   sym:     symptr;
begin
   if isnumber(ex) then
      sym := nil
   else
      sym := locatesym(ex);

   if (sym <> nil) and (sym^.limit > 0) then
   begin
      exprlimit := sym^.limit;
      exit;
   end;

   exprlimit := htoi(ex);
end;


procedure initialize_global(id: string80; exp: string);
   {generate code to initialize a global variable at runtime}
begin
   if length(exp) = 0 then
      exit;

{writeln('[init global, id=',id,' exp=',exp,']');}

   if ((unitlevel > 0) and (not in_interface)) or (pos('(',exp)=0) then
   begin
      puts(' = '+exp);
      exit;
   end;

   {enter into global initializer table}
   addinit(id+' = '+exp);
end;



(********************************************************************)
(*
 * process pascal data type specifications
 *
 *)

function psimpletype: string80;
   {parse a simple (single keyword and predefined) type; returns the
    translated type specification; sets the current data type}
begin
   if debug_parse then write(' <simpletype>');

   if cursym = nil then
   begin
     if debug then
        warning('Unknown simple type');
   end
   else

   begin
      ltok := cursym^.repid;
      if tok[1] = '^' then
         ltok := '^' + ltok;
      while cursym^.symtype = ss_subtype do
         cursym := cursym^.parent;
      curparent := cursym;
   end;

(*
if debug then
writeln(' psimtype: tok=',ltok,
              ' ty=',typename[cursym^.symtype],
              ' par=',cursym^.parent^.repid);
*)
   psimpletype := ltok;
   gettok;
end;


(********************************************************************)
procedure pdatatype(stoclass: anystring;
                    var vars: paramlist;
                    prefix:   anystring;
                    suffix:   anystring;
                    addsemi:  boolean);
   {parse any full data type specification;  input is a list of variables
    to be declared with this data type; stoclass is a storage class prefix
    (usually 'static ', '', 'typedef ', or 'extern '.  prefix and suffix
    are variable name modifiers used in pointer and subscript translations;
    recursive for complex data types}

const
   forward_typedef: anystring = '';
   forward_undef:   anystring = '';

var
   i:       integer;
   ts:      anystring;
   ex:      anystring;
   sym:     symptr;
   nbase:   integer;
   ntype:   symtypes;


   procedure pvarlist(typemark: string80);
   var
      i:    integer;
      pcnt: integer;

   begin
      ts := '';
      pcnt := -1;

(**
if debug then
writeln(' pvl nbase=',nbase,' tok=',ltok,' ty=',typename[ntype]);
**)
      if tok = 'ABSOLUTE' then
      begin
         if debug_parse then write(' <abs>');

         gettok;        {consume the ABSOLUTE}
         ts := pexpr;   {get the absolute lvalue}

         if tok[1] = ':' then    {absolute addressing}
         begin
            gettok;
            ts := 'MK_FP('+ts+','+pexpr+')';
         end
         else                 {variable aliasing}
         begin
            if ts[1] = '*' then
               ts := copy(ts,2,255)
            else
               ts := '&' + ts;
         end;
         
         {determine proper pointer type}
         if (ntype <> ss_pointer) or (prefix = '*') then
         begin
            {force automatic pointer dereference in expressions}
            if (length(suffix) = 0) and (length(prefix) = 0) then
               pcnt := -2;
            typemark := typemark + ' *';
         end;

         {typecase pointers}
         ts := typecast(typemark,ts);
      end;

      if length(typemark) > 0 then
         puts(stoclass+ljust(typemark,identlen));


      if tok = 'SYMTYPE' then
      begin
         if debug_parse then write(' <builtin>');
         gettok;
         ntype := first_symtype;
         while (ntype < last_symtype) and (tok <> typename[ntype]) do
            inc(ntype);
         gettok;
      end;

      for i := 1 to vars.n do
      begin
         newsym(vars.id[i],ntype,pcnt,withlevel,curlimit,nbase,curparent);
         if length(ts) = 0 then
            puts(prefix+vars.id[i]+suffix)
         else
            puts(vars.id[i]);
         initialize_global(vars.id[i],ts);
         if i < vars.n then
            puts(', ');
      end;

      if curparent = nil then
         curparent := cursym;
   end;


   procedure parray;
   begin
      if debug_parse then write(' <array>');

      gettok;     {consume the ARRAY}

      repeat
         gettok;        {consume the [ or ,}

         ts := pexpr;   {consume the lower subscript expression}
         nbase := exprlimit(ts);

         if tok = '..' then
         begin
            gettok;   {consume the ..}
            ex := ts;
            ts := pexpr;
            ex := ' /* ' + ex + '..' + ts + ' */ ';

            i := exprlimit(ts);
            if i <> 0 then
               ts := itoa(i);
            subtract_base(ts,nbase-1);
            if isnumber(ts) then
               ts := ex + ts;
         end
         else

         begin    {subscript by typename - look up type range}
            sym := locatesym(ts);
            if sym <> nil then
            begin
               nbase := sym^.base;
               if (sym^.limit > 0) and (sym^.symtype <> ss_const) then
                  ts := ' /* ' + ts + ' */ ' + itoa(sym^.limit-nbase+1);
            end;
         end;
   
         suffix := suffix + '[' + ts + ']'; 

      until tok[1] <> ',';
      
      gettok;     {consume the ]}
      gettok;     {consume the OF}

      ntype := ss_array;
(*
if debug then
writeln(' array ts=',ts,' nbase=',nbase,' tok=',ltok);
*)
   end;


   procedure pstring;
   begin
      if debug_parse then write(' <string>');

      gettok;     {consume the STRING}

      if tok[1] = '[' then
      begin
         gettok;     {consume the [}

         ts := pexpr;
         subtract_base(ts,-1);            {increment string size by one}
         suffix := suffix + '[' + ts + ']'; 
         
         gettok;     {consume the ]}
      end
      else
         suffix := suffix + '[STRSIZ]';

      curparent := stringsym;
      nbase := 1;
      pvarlist('char');
   end;


   procedure ptext;
   begin
      if debug_parse then write(' <text>');

      gettok;     {consume the TEXT}

      if tok[1] = '[' then
      begin
         gettok;     {consume the [}
         ts := pexpr;
         gettok;     {consume the ]}
      end;

      curparent := textsym;
      pvarlist('text');
   end;


   procedure pfile;
   begin
      if debug_parse then write(' <file>');

      gettok;     {consume the FILE}

      if tok = 'OF' then
      begin
         gettok;     {consume the OF}
         ts := tok;
         gettok;     {consume the recordtype}
         ts := ' /* file of '+ts+' */';
      end
      else
         ts := ' /* untyped file */';

      curparent := textsym;
      pvarlist('int'+ts);
   end;


   procedure pset;
   begin
      if debug_parse then write(' <set>');

      gettok;     {consume the SET}
      gettok;     {consume the OF}

      ts := ' /* ';
      if toktype = identifier then
         ts := ts + usetok
      else

      if tok = '(' then
      begin
         repeat
            ts := ts + usetok
         until (tok[1] = ')') or recovery;
         ts := ts + usetok;
      end
      else
         ts := ts + psetof;
      ts := ts + ' */';

      ntype := ss_struct;
      curparent := nil;

      pvarlist('setrec'+ts);
   end;


   procedure pvariant;
   begin
      if debug_parse then write(' <variant>');

      gettok;     {consume the CASE}

      ex := ltok;
      gettok;     {consume the selector identifier}

      if tok[1] = ':' then
      begin
         gettok;     {consume the :}
         ts := psimpletype;
         newsym(ex,ss_scalar,-1,1,0,0,curparent);
         
         puts(ts+' '+ex+ ';  /* Selector */');
      end
      else
         puts(' /* Selector is '+ex+' */');

      gettok;
      puts('union { ');
      newline;

      while (tok <> '}') and not recovery do
      begin
         ts := pexpr;      {parse the selector constant}
         while tok[1] = ',' do
         begin
            gettok;
            ts := pexpr;
         end;

         gettok;    {consume the :}

         puts(' struct {  ');

         if (ts[1] = '"') or (ts[1] = '''') then
           ts := ts[2];
         ts := 's' + ts;
         decl_prefix := 'v.'+ts+'.';
         pvar;
         decl_prefix := '';
         
         gettok;    {consume the ')'}

         puts(' } '+ts+';');

         {arrange for reference translation}
         newsym(ts,ss_struct,-1,0,0,0,nil);
         cursym^.repid := ts;
         usesemi;
      end;

      puts(' } v;');
      newline;
   end;


   procedure precord;
   begin
      if debug_parse then write(' <record>');

      puts(stoclass+'struct '+vars.id[1]+' { ');

      inc(withlevel);
      pvar;     {process each record member}

      if tok = 'CASE' then    {process the variant part, if any}
         pvariant;

      puttok;   {output the closing brace}
      gettok;   {and consume it}

      dec(withlevel);

      ntype := ss_struct;
      curparent := nil;
      pvarlist(''); {output any variables of this record type}

      {convert a #define into a typedef in case of a forward pointer decl}
      if length(forward_typedef) > 0 then
      begin
         puts(';'); 
         newline;
         puts(forward_undef); 
         newline;
         puts(forward_typedef);
         forward_typedef := '';
      end;
   end;


   procedure penum;
   var
      members: integer;

   begin
      if debug_parse then write(' <enum>');

      puts(stoclass+'enum { ');

      gettok;
      members := 0;
      repeat
         puts(ltok);
         if toktype = identifier then
         begin
            newsym(ltok,ss_const,-1,0,members,0,intsym);
            inc(members);
         end;
         gettok;
      until (tok[1] = ')') or recovery;

      puts(' } ');
      gettok;   {consume the )}

      curlimit := members-1;
      curparent := intsym;
      nbase := 0;
      pvarlist('');
   end;


   procedure pintrange;
   begin
      if debug_parse then write(' <int.range>');

      ex := pexpr;   {consume the lower limit expression}
      nbase := htoi(ex);
      
      if tok <> '..' then
      begin
         syntax('".." expected');
         exit;
      end;
      
      gettok;        {consume the ..}
      ts := pexpr;   {consume the number}

      curlimit := exprlimit(ts);
      curparent := intsym;

      pvarlist('int /* '+ex+'..'+ts+' */');
   end;


   procedure pcharrange;
   begin
      if debug_parse then write(' <char.range>');

      ex := pexpr;   {consume the lower limit expression}
      nbase := ord(ex[2]);

      if tok <> '..' then
      begin
         syntax('".." expected');
         exit;
      end;

      gettok;        {consume the ..}
      ts := pexpr;   {consume the number}

      curlimit := exprlimit(ts);
      curparent := charsym;

      pvarlist('char /* '+ex+'..'+ts+' */');
   end;


   procedure psimple;
   begin
      ex := psimpletype;
      if ntype <> ss_array then
         nbase := curparent^.base; {??}

      if tok =  '..' then
      begin
         if debug_parse then write(' <range>');
         gettok;        {consume the ..}
         ts := pexpr;   {consume the number}

         nbase := exprlimit(ex);
         curlimit := exprlimit(ts);
         curparent := intsym;

         pvarlist('int /* '+ex+'..'+ts+' */');
         exit;
      end;

      {pointer to simpletype?}      
      i := pos('^',ex);
      if i <> 0 then
      begin
         if debug_parse then write(' <pointer>');

         delete(ex,i,1);
         prefix := '*';
         ntype := ss_pointer;
      end;
   
      sym := locatesym(ex);

      {potential forward pointer reference?}
      if (stoclass = 'typedef ') and (vars.n = 1) and 
         (prefix = '*') and (sym = nil) then
      begin
         if debug_parse then write(' <forward>');

         newsym(vars.id[1],ntype,-1,0,curlimit,0,nil);
         puts(ljust('#define '+vars.id[1],identlen)+'struct '+ex+' *');
         forward_undef := '#undef '+vars.id[1];
         forward_typedef := 'typedef struct '+ex+' *'+vars.id[1];
         addsemi := false;
      end
      else

      {ordinary simple types}
      begin
         if debug_parse then write(' <simple>');
         pvarlist(ex);
      end;
   end;

begin   {pdatatype}

   curlimit := 0;
   nbase := 0;
   if stoclass = 'typedef ' then
      ntype := ss_subtype
   else
      ntype := ss_scalar;
   curparent := voidsym;

   if tok = 'EXTERNAL' then
   begin
      gettok;     {consume the EXTERNAL}
      stoclass := 'extern '+stoclass;
   end;
   
   if tok = 'PACKED' then
      gettok;
   while tok = 'ARRAY' do
      parray;
   if tok = 'PACKED' then
      gettok;

   if tok = 'STRING'        then pstring
   else if tok = 'TEXT'     then ptext
   else if tok = 'FILE'     then pfile
   else if tok = 'SET'      then pset
   else if tok = '('        then penum
   else if tok = 'RECORD'   then precord
   else if toktype = number then pintrange
   else if toktype = chars  then pcharrange
   else psimple;

   if addsemi then
      puts(';');
   puts(' ');

   usesemi;
end;


(********************************************************************)
(*
 * declaration keyword processors
 *   const, type, var, label
 *
 * all enter with tok=section type
 * exit with tok=new section or begin or proc or func
 *
 *)

procedure pconst;
   {parse and translate a constant section}
var
   vars:    paramlist;
   parlev:  integer;
   exp:     string;
   term:    string;
   complex: boolean;

   procedure check_complex;
   begin
      if not complex then
         puts(' = ');
      puts(exp);
      exp := '';
      complex := true;
   end;
   
begin
   if debug_parse then write(' <const>');

   gettok;

   while (toktype <> keyword) and not recovery do
   begin
      nospace := false;
      vars.n := 1;
      vars.id[1] := ltok;
      complex := false;

      curparent := cursym;
      gettok;    {consume the id}

      if tok[1] = '=' then     {untyped constant}
      begin
         if debug_parse then write(' <untyped.const>');

         gettok;   {consume the =}

         exp := pexpr;
         if isnumber(exp) then
            curlimit := htoi(exp);
         {if (cexprsym^.symtype = ss_pointer) then
            cexprsym := cexprsym^.parent;}
         newsym(vars.id[1],ss_const,-1,0,curlimit,0,cexprsym);

         case exprtype of
            'd','D','b','c':
               puts('enum { '+ljust(vars.id[1],identlen)+'= '+exp+' };');
            's':
               puts('#define '+ljust(vars.id[1],identlen)+' '+exp);
            else
               puts('const '+cexprsym^.repid+ljust(vars.id[1],identlen)+'= '+exp+';');
         end;

         usesemi;
      end
      else

      begin               {typed constants}
         if debug_parse then write(' <typed.const>');

         gettok;   {consume the :}

         pdatatype('',vars,'','',false);
         puts(ljust('',identlen-length(vars.id[1])-1));

         gettok;   {consume the =}
         parlev := 0;
         exp := '';

         repeat
            if tok[1] = '[' then
            begin
               gettok;     {consume [}
               exp := exp + psetof;
               gettok;     {consume ]}
            end
            else
            
            if tok[1] = '(' then
            begin
               inc(parlev);
               exp := exp + '{';
               gettok;
            end
            else

            if tok[1] = ')' then
            begin
               dec(parlev);
               exp := exp + '}';
               gettok;
            end
            else

            if tok[1] = ',' then
            begin
               exp := exp + ',';
               check_complex;
               gettok;
            end
            else

            if (parlev > 0) and (tok[1] = ';') then
            begin
               exp := exp + ',';
               check_complex;
               gettok;
            end
            else

            if tok[1] <> ';' then
            begin
               term := pexpr;
               if tok[1] = ':' then
                  gettok   {discard 'member-identifier :'}
               else
                  exp := exp + term;
            end;

         until ((parlev = 0) and (tok[1] = ';')) or recovery;

         if complex then
         begin
            puts(exp);
            exp := '';
         end;
         
         initialize_global(vars.id[1],exp);
         puts(';');
         gettok;
      end;
   end;
end;


(********************************************************************)
procedure ptype;
   {parse and translate a type section}
var
   vars: paramlist;

begin
   if debug_parse then write(' <type>');

   gettok;

   while (toktype <> keyword) do
   begin
      vars.n := 1;
      vars.id[1] := usetok;
      gettok;                {consume the =}

      nospace := false;
      pdatatype('typedef ',vars,'','',true);
   end;

end;


(********************************************************************)
procedure pvar;
   {parse and translate a variable section}
var
   vars:  paramlist;
   sto:   string20;
begin
   if debug_parse then write(' <var>');

   if in_interface and (withlevel = 0) then
      sto := 'extern '
   else
      sto := '';

   vars.n := 0;
   gettok;

   while (toktype <> keyword) and (tok[1] <> '}') and (tok[1] <> ')') do
   begin
      nospace := true;

      repeat
         if tok[1] = ',' then
            gettok;

         inc(vars.n);
         if vars.n > maxparam then
            fatal('Too many identifiers (pvar)');
         vars.id[vars.n] := ltok;
         gettok;
      until tok[1] <> ',';

      if tok[1] <> ':' then       
      begin
         syntax('":" expected');
         exit;
      end;
         
      gettok;   {consume the :}
      nospace := false;
      pdatatype(sto,vars,'','',true);
      vars.n := 0;
   end;
end;


