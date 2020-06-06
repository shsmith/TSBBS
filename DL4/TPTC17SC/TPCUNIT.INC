
(*
 * TPTC - Turbo Pascal to C translator
 *
 * (C) 1988 Samuel H. Smith (rev. 13-Feb-88)
 *
 *)

(********************************************************************)
(*
 * process interface, implementation and uses statements
 *
 *)

(********************************************************************)
procedure punit;
   {parse a unit clause}
begin
   if debug_parse then write(' <unit>');

   in_unit := true;
   gettok;     {consume the UNIT}

   unitproc := ltok + '_init';
   puts('/* Unit '+ltok+' */ ');

   gettok;     {consume the unit name}
   usesemi;
end;


(********************************************************************)
procedure puses;
   {parse a uses clause}
begin
   if debug_parse then write(' <uses>');

   gettok;     {consume the USES}
   
   repeat
      {load the saved unit header symbol table, generate .UNH include}
      load_unitfile(ltok,globals);

      {move interface section to skip new entries}
      top_interface := globals;     
      
      gettok;                       {consume the unit name}
      if tok[1] = ',' then
         gettok;
   until (tok[1] = ';') or recovery;
   
end;


(********************************************************************)
procedure pinterface;
begin
   if debug_parse then write(' <interface>');
   gettok;
      
   in_interface := true;
   top_interface := globals;

   putline;
   putln('#define IN_'+unitname+'  /* globals defined here */');
   putln('#include <'+unitname+'.UNH>');
   
   inc(unitlevel);
   assign(ofd[unitlevel],unitname+'.UNH');
   rewrite(ofd[unitlevel]);
   getmem(outbuf[unitlevel],inbufsiz);
   SetTextBuf(ofd[unitlevel],outbuf[unitlevel]^,inbufsiz);

   putline;
   putln('/* Unit header for: '+outname+' -- Made by '+version1+' */');
   putline;
   putln('#ifndef '+unitname+'_LOADED  /* prevent multiple loading */');
   putln('#define '+unitname+'_LOADED');
   putline;

   (* .UNH includes will be generated here *)
   if tok = 'USES' then
      puses;

   putline;
   putln('#ifdef IN_'+unitname+'  /* define globals here? */');
   putln('#define extern');
   putln('#endif');

   usesemi;
end;


(********************************************************************)
procedure pimplementation;
begin
   if debug_parse then write(' <implementation>');

   if not in_interface then
      exit;

   {terminate the .unh file being generated}
   putline;
   puts('extern void  '+unitproc);
   if unitheader then
      putln('(void);')
   else
      putln('(int argc, char **argv);');
   putln('#undef extern');
   putln('#endif');

   close(ofd[unitlevel]);
   freemem(outbuf[unitlevel],inbufsiz);
   dec(unitlevel);
   
   {create the requested unit symbol file}
   newsym(unitproc, ss_unit, 2, 0, 0, 0, voidsym);
   create_unitfile(unitname+'.UNS',globals,top_interface);
   in_interface := false;

   gettok;
end;


   
(********************************************************************)
(*
 * process generic declaration section
 *   dispatches to const, type, var, proc, func
 *   enter with tok=section type
 *   exit with tok=next section type
 *
 *)

procedure psection;
begin
   if recovery then
   begin
      while toktype <> keyword do
         gettok;
      recovery := false;
   end;

   if debug_parse then write(' <section>');

   if tok = 'UNIT' then
      punit
   else
   
   if tok = 'INTERFACE' then
      pinterface
   else
   
   if tok = 'IMPLEMENTATION' then
      pimplementation
   else
   
   if tok = 'USES' then
   begin
      puses;
      usesemi;
   end
   else
   
   if (tok = 'EXTERNAL')  or (tok = 'OVERLAY') or
      (tok = 'PROCEDURE') or (tok = 'FUNCTION') then
      progunit
   else

   if tok = 'CONST' then
      pconst
   else

   if tok = 'TYPE' then
      ptype
   else

   if tok = 'VAR' then
      pvar
   else

   if tok = 'LABEL' then
      plabel
   else

   if tok[1] = '{' then
      pblock
   else

   if (tok[1] = '.') or (tok[1] = '}') then
   begin
      tok := '.';
      exit;
   end
   else
      syntax('Section header expected (psection)');
end;


(********************************************************************)
(*
 * process argument declarations to
 *    program, procedure, function
 *
 * enter with header as tok
 * exits with tok as ; or :
 *
 *)

const
   extern = true;
   
procedure punitheader(is_external: boolean);
var
   proc:    string40;
   proclit: string40;
   vars:    paramlist;
   types:   paramlist;
   i:       integer;
   ii:      integer;
   rtype:   string40;
   rsym:    symptr;
   varval:  integer;
   varon:   boolean;
   locvar:  integer;
   iptr:    integer;

begin
   gettok;                 {skip unit type}
   proclit := ltok;

   if (unitlevel > 1) and (not in_interface) then
   begin
      {make name unique if it clashes with an existing global}
      if cursym = nil then
         proc := proclit
      else
         proc := procnum + '_' + proclit;
         
      warning('Nested function');
      
      writeln(ofd[unitlevel-1],^M^J'   /* Nested function: ',proc,' */ ');
      inc(objtotal,2);
   end
   else
      proc := proclit;

   gettok;                 {skip unit identifier}

   vars.n := 0;
   varval := 0;       { 0 bit means value, 1 = var }
   varon  := false;

   (* process param list, if any *)
   if tok[1] = '(' then
   begin
      gettok;

      while (tok[1] <> ')') and not recovery do
      begin

         ii := vars.n + 1;
         repeat
            if tok[1] = ',' then
               gettok;

            if tok = 'VAR' then
            begin
               gettok;
               varon := true;
            end;

            inc(vars.n);
            if vars.n > maxparam then
               fatal('Too many params (punitheader)');

            vars.id[vars.n] := ltok;
            gettok;

         until tok[1] <> ',';

         if tok[1] = ':' then       
         begin
            gettok;   {consume the :}
   
            {parse the param type}
            rtype := psimpletype;
            rsym := curparent;
         end
         else

         begin    {untyped variable if ':' is missing}
            rtype := 'void';
            rsym := voidsym;
         end;

         {assign and param types, converting 'var' and 'array' params}
         if rtype[1] = '^' then
            rtype[1] := '*';

         {flag var parameters; strings and arrays are implicitly var in C}
         iptr := 0;
         if rsym^.symtype = ss_array then
            rtype := rsym^.parent^.repid + ' *'
         else
         if varon then
            iptr := 1 shl (ii - 1);

         {assign data types for each ident}
         for i := ii to vars.n do   
         begin
            types.id[i] := rtype;
            types.sym[i] := rsym;
            varval := varval or iptr;
            iptr := iptr shl 1;
         end;

         if tok[1] = ';' then
         begin
            gettok;
            varon := false;
         end;

      end;   {) seen}

      gettok;   {consume the )}
   end;

   (* process function return type, if any *)
   if tok[1] = ':' then
   begin
      gettok;            {consume the :}
      rtype := psimpletype;
      rsym := curparent;
      
      if rsym^.symtype = ss_array then
         rtype := rsym^.parent^.repid + ' *';

(* writeln('return rtype=',rtype); *)
   end
   else

   begin
      rtype := 'void';
      rsym := voidsym;
   end;

   putline;
   
   (* prefix procedure decl's when external *)
   if is_external then
   begin
      putln(ljust('extern '+rtype,identlen)+proc+'();');
      addsym(globals,proc,ss_func,0,varval,0,0,cexprsym,false);
      exit;
   end;


   (* process 'as NEWNAME' clause, if present (tptc extention to specify
      the replacement name in the symbol table *)
   if tok = 'AS' then
   begin
      gettok;
      proc := usetok;
   end;
    

   (* output the return type, proc name, formal param list *)
   if in_interface then
      rtype := 'extern '+rtype;
   puts(ljust(rtype,identlen)+proc+'(');

   if vars.n = 0 then
      puts('void');


   (* output the formal param declarations *)
   locvar := varval;
   for i := 1 to vars.n do
   begin
      iptr := -1;

      if (locvar and 1) = 1 then
      begin
         iptr := -2;
         types.id[i] := types.id[i] + ' *';
      end;

      puts(ljust(types.id[i],identlen)+vars.id[i]);
      addsym(locals,vars.id[i],ss_scalar,iptr,0,0,
                    types.sym[i]^.base,types.sym[i],true);
      locvar := locvar shr 1;

      if i < vars.n then
      begin
         putln(','); 
         puts(ljust('',identlen+length(proc)+1));
      end;
   end;

   puts(')');
   nospace := false;

   {enter the procedure in the global symbol table}
   addsym(globals,proclit,ss_func,vars.n,varval,0,0,rsym,false);
   cursym^.repid := proc;
end;


(********************************************************************)
(*
 * process body of program unit
 *   handles all declaration sections
 *   and a single begin...end
 *   recursively handles procedure declarations
 *   ends with tok=}
 *)

procedure punitbody;
begin
   gettok;

   if tok = 'INTERRUPT' then
   begin
      gettok;
      warning('Interrupt handler');
   end;
   
   if tok = 'FORWARD' then
   begin
      puts(';');
      gettok;
   end
   else

   if tok = 'EXTERNAL' then
   begin
      puts('/* ');
      repeat
         puttok;
         gettok;
      until tok[1] = ';';
      puts(' */ ;');
   end
   else

   if tok = 'INLINE' then
   begin
      newline;
      putln('{');
      puts('   ');
      pinline;
      putln('}');
   end
   else

   begin
      puts('{ ');

      repeat
         psemi;
         if tok[1] <> '{' then
            psection;
      until tok[1] = '{';

      gettok;                 {get first token of first statement}

      while (tok[1] <> '}') and not recovery do
      begin
         pstatement;             {process the statement}
         psemi;
      end;

      puttok;
   end;
end;


(********************************************************************)
procedure enter_procdef;
   {increase output file level and direct output to the new file}
var
   nam:  anystring;
begin
   {increment this procedure number}
   inc(procnum[2]);
   if procnum[2] > 'Z' then
   begin
      inc(procnum[1]);
      procnum[2] := 'A';
   end;

   inc(unitlevel);
   if unitlevel > maxnest then
      fatal('Functions nested too deeply');

   str(unitlevel,nam);
   nam := workdir + nestfile + nam;

   assign(ofd[unitlevel],nam);
   {$i-} rewrite(ofd[unitlevel]); {$i+}

   if ioresult <> 0 then
   begin
      dec(unitlevel);
      ltok := nam;
      fatal('Can''t create tempfile');
   end;

   if maxavail-300 <= inbufsiz then
   begin
      ltok := nam;
      fatal('Out of memory');
   end;

   getmem(outbuf[unitlevel],inbufsiz);
   SetTextBuf(ofd[unitlevel],outbuf[unitlevel]^,inbufsiz);
end;


(********************************************************************)
procedure exit_procdef;
   {copy the outer output file to the next lower level output
    and reduce output level by 1}
var
   line:  string;

begin
   if unitlevel < 1 then 
      exit;
   
   close(ofd[unitlevel]);
   reset(ofd[unitlevel]);
   SetTextBuf(ofd[unitlevel],outbuf[unitlevel]^,inbufsiz);

   while not eof(ofd[unitlevel]) do
   begin
      readln(ofd[unitlevel],line);
      writeln(ofd[0],line);
   end;

   close(ofd[unitlevel]);
   erase(ofd[unitlevel]);
   freemem(outbuf[unitlevel],inbufsiz);
   dec(unitlevel);
end;


(********************************************************************)
(*
 * process program, procedure and function declaration
 *
 * enter with tok=function
 * exit with tok=;
 *
 *)

procedure progunit;
var
   top: symptr;
begin
   if debug_parse then write(' <unit>');

   nospace := true;
   top := locals;

   if (tok = 'OVERLAY') then
      gettok;

   if (tok = 'EXTERNAL') then  {mt+}
   begin
      gettok;      {consume the EXTERNAL}

      if tok[1] = '[' then
      begin
         gettok;   {consume the '['}

         puts('/* overlay '+ltok+' */ ');
         gettok;   {consume the overlay number}

         gettok;   {consume the ']'}
      end;

      punitheader(extern);
      usesemi;
      purgetable(locals,top);
   end
   else

   if in_interface then
   begin
      nospace := false;
      punitheader(not extern);

      puts(';');
      usesemi;
      
      if tok = 'INLINE' then
      begin
         pinline;
         warning('Inline procedure');
      end;

      purgetable(locals,top);
   end
   else
   
   begin
      {enter a (possibly nested) procedure}
      enter_procdef;

      punitheader(not extern);
      punitbody;
      gettok;
      usesemi;
      purgetable(locals,top);

      {exit the (possibly nested) procedure, append text to toplevel outfile}
      exit_procdef;
   end;

end;



(********************************************************************)
(*
 * process main program
 *
 *  expects program head
 *  optional declarations
 *  block of main code
 *  .
 *
 *)

procedure pmain;
   {process unit initializer block (or top-level main), if any}
var
   un: integer;

begin
   putline;

   if in_unit then
   begin
      if unitheader then
         putln('void '+unitproc+'()')
      else
         putln('void tptcsys_init(int argc, char **argv)');

      putln('{');
      putln('   static char unit_initialized = 0;');
      putln('   if (unit_initialized) return;');
      putline;
      putln('   unit_initialized = 1;');
   end
   else

   begin
      putln('void main(int argc, char **argv)');
      putln('{');
      putln('   tptcsys_init(argc,argv);');
   end;

   if unitheader then
      un := 2
   else
      un := 1;

   while un <= init_count do
   begin
      putln('   '+init_tab[un]+';');
      inc(un);
   end;
   newline;

   if tok[1] = '{' then
      gettok;                 {get first token of main block}

   while (tok[1] <> '}') and (tok[1] <> '.') do
   begin
      pstatement;                {process the statement}
      psemi;
   end;

   putln('}');
   putline;
end;


procedure pprogram;
begin
   getchar;  {get first char}
   gettok;   {get first token}

   if (tok = 'PROGRAM') then
   begin
      comment_statement;
      gettok;
   end;

   if tok = 'MODULE' then
   begin
      mt_plus := true;   {shift into pascal/mt+ mode}
      comment_statement;
      gettok;
   end;

   repeat
      psemi;
      if tok = 'MODEND' then
         exit;

      if (tok[1] <> '{') then
         psection;
   until (tok[1] = '{') or (tok[1] = '.') or recovery;

   {process the main block, if any}
   pmain;
end;

