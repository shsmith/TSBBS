
(*
 * TPTC - Turbo Pascal to C translator
 *
 * (C) 1988 Samuel H. Smith (rev. 13-Feb-88)
 *
 *)

const
   previd:  string40 = '?';

   
   
(********************************************************************)
function findsym( table: symptr;
                  id:    string40): symptr;
   {locate a symbol in a specified symbol table.  returns pointer to
    the entry if found, otherwise nil is returned}
var
   sym: symptr;

begin
   stoupper(id);
   sym := table;

   while true do
   begin

(*
 *    while (sym <> nil) and
 *          ((length(sym^.id) <> length(id)) or
 *           (sym^.id[1] <> id[1])) do
 *       sym := sym^.next;
 *)
      Inline(
        $C4/$7E/$CF/       {   les di,[bp-$31]}      {es:di=sym^}
        $8B/$4E/$D3/       {   mov cx,[bp-$2d]}      {cl=id[0], ch=id[1]}
                           {loop:}
        $8C/$C0/           {   mov ax,es}            {sym=0?}
        $09/$F8/           {   or ax,di}
        $74/$0C/           {   jz exit}
        $26/$3B/$4D/$05/   {   es: cmp cx,[di+5]}    {length and [1] ==?}
        $74/$06/           {   jz exit}
        $26/$C4/$7D/$5F/   {   es: les di,[di+$5f]}  {sym=sym^.next}
        $EB/$EE/           {   jmp loop}
                           {exit:}
        $89/$7E/$CF/       {   mov [bp-$31],di}      {update sym}
        $8C/$46/$D1);      {   mov [bp-$2f],es}

      if (sym = nil) or
         (sym^.id = id) then
      begin
         findsym := sym;
         exit;
      end;

      sym := sym^.next;
   end;

   findsym := nil;   {symbol not found}
end;


(********************************************************************)
function locatesym(id:    string40): symptr;
   {locate a symbol in either the local or the global symbol table.
    returns the symbol table entry pointer, if found.  returns
    nil when not in either table}
var
   sym: symptr;
const
   prevsym: symptr = nil;

begin
   stoupper(id);
   if id[1] = '^' then
      delete(id,1,1);
      
   {speed hack - don't search if same ident used twice}
   if length(previd) = length(id) then
   if previd = id then
   begin
      locatesym := prevsym;
      exit;
   end;

   sym := findsym(locals,id);
   if sym = nil then
      sym := findsym(globals,id);

   previd := id;
   prevsym := sym;
   locatesym := sym;
end;


(********************************************************************)
procedure addsym( var table: symptr;
                  id:        string40;
                  symtype:   symtypes;
                  parcount:  integer;
                  varmap:    integer;
                  lim:       integer;
                  base:      integer;
                  parent:    symptr;
                  dup_ok:    boolean);
   {add a symbol to a specific symbol table.  duplicates hide prior entries.
    new symbol pointed to by cursym}

begin
   if maxavail-300 < sizeof(cursym^) then
   begin
      ltok := id;
      fatal('Out of memory');
   end;

   if (not dup_ok) and (not in_interface) then
   begin
      cursym := findsym(table,id);
      if cursym <> nil then
      begin
         ltok := id;
         if cursym^.symtype <> ss_builtin then
         if (cursym^.parcount <> parcount) or 
            (cursym^.symtype <> symtype) or (cursym^.limit <> lim) then
            warning('Redeclaration not identical');
         ltok := tok;
      end;
   end;
   
   new(cursym);
   cursym^.next := table;
   table := cursym;

   cursym^.repid := decl_prefix + id;

   stoupper(id);
   cursym^.id := id;

   cursym^.symtype := symtype;
   cursym^.parcount := parcount;
   cursym^.limit := lim;
   cursym^.base := base;
   cursym^.pvar := varmap;

   if parent = nil then
      parent := cursym;    {parent=nil causes self reference}
      
   cursym^.parent := parent;

(* if debug then
writeln(^M^J'newsym: id=',id,' ty=',typename[symtype],
            ' par=',parent^.id,^M^J);
*)

   previd := '?';
end;


(********************************************************************)
procedure newsym( id:       string40;
                  symtype:  symtypes;
                  parcount: integer;
                  varmap:   integer;
                  lim:      integer;
                  base:     integer;
                  parent:   symptr);
   {enter a new symbol into the current symbol table (local or global)}
begin
   if (unitlevel = 0) or (in_interface) then
      addsym(globals,id,symtype,parcount,varmap,lim,base,parent,false)
   else
      addsym(locals,id,symtype,parcount,varmap,lim,base,parent,true);
end;



(********************************************************************)
procedure addinit(init: string80);
   {add a new initializer to the global initializer table}
begin
   if init_count >= max_init then
   begin
      ltok := init;
      fatal('Too many global initializers');
   end;

   inc(init_count);
   init_tab[init_count] := init;
end;


(********************************************************************)
procedure dumptable(sym: symptr; top: symptr);
   {dump entries from the specified symbol table, stopping where indicated}
var
   info: string40;
   
begin
   if (not dumpsymbols) or (sym = nil) or (sym = top) then
      exit;

   putln('/* User symbols:');
   putln(' *    Type                 Class  Base  Limit Pars  Pvar   Identifier');
   putln(' *   -------------------- ------- ---- ------ ---- ------ --------------');
   
   while (sym <> nil) and (sym <> top) and
         ((sym <> builtins) or dumppredef) do
   begin
   
      if sym = builtins then
      begin
         putln(' *');
         putln(' * Predefined symbols:');
         putln(' *    Type                 Class  Base  Limit Pars  Pvar   Identifier');
         putln(' *   -------------------- ------- ---- ------ ---- ------ --------------');
      end;
      
      puts(' *    ');

      if sym^.parent <> sym then
         puts(copy(ljust(sym^.parent^.repid,20),1,20))
      else
         puts(ljust(typename[sym^.symtype],20));

      case sym^.symtype of
         ss_array:   puts('[]     ');
         ss_pointer: puts('*      ');
         ss_func:    puts('()     ');
         ss_struct:  puts('...    ');
         ss_const:   puts('Const  ');
         ss_subtype: puts('Subtype');
         ss_builtin: puts('Builtin');
         ss_scalar:  puts('Scalar ');
         ss_unit:    puts('Unit   ');
         else        puts('       ');
      end;

      write(ofd[unitlevel],
        sym^.base:5,' ',
        sym^.limit:6,' ',
        sym^.parcount:4,' ',
        sym^.pvar:6,'   ',
        sym^.repid);
      putline;

      if sym <> nil then
         sym := sym^.next;
   end;

   putln(' */');
   putline;
end;


(********************************************************************)
procedure purgetable( var table: symptr; top: symptr);
   {purge all entries from the specified symbol table}
var
   sym: symptr;

begin
   dumptable(table, top);
   
   while (table <> nil) and (table <> top) do
   begin
      sym := table;
      table := table^.next;
      dispose(sym);
   end;
   previd := '?';
end;


(********************************************************************)
procedure create_unitfile(name: string64; sym, top: symptr);
   {dump symbol table to the specified unit symbol file}
type
   linkptr = ^linkrec;
   linkrec = record
      sym: symptr;
      next: linkptr;
   end;
var
   fd:      text;
   outbuf:  array[1..inbufsiz] of byte;
   rev:     linkptr;
   node:    linkptr;
   
begin
   {build a table of symbols; this is required to preserve the proper
    symbol ordering in the symbol file}
   rev := nil;
   while (sym <> nil) and (sym <> top) do
   begin
      new(node);
      node^.sym := sym;
      node^.next := rev;
      rev := node;
      sym := sym^.next;
   end;

   assign(fd,name);
{$I-}
   rewrite(fd);
{$I+}
   if ioresult <> 0 then
   begin
      ltok := name;
      fatal('Can''t create');
   end;
   
   setTextBuf(fd,outbuf);

   writeln(fd,symfile_vers);

   while rev <> nil do
   begin
      sym := rev^.sym;
      node := rev;
      rev := rev^.next;
      dispose(node);
      
      writeln(fd,sym^.id);
      writeln(fd,sym^.repid);

      if sym^.parent = sym then
         writeln(fd,'-')
      else
         writeln(fd,sym^.parent^.id);

      writeln(fd,ord(sym^.symtype),' ',
                 sym^.base,' ',
                 sym^.limit,' ',
                 sym^.parcount,' ',
                 sym^.pvar);
      
      inc(objtotal,3);
   end;

   close(fd);
end;


(********************************************************************)
procedure load_unitfile(name: string64; var table: symptr);
   {load symbol table fromthe specified unit symbol file}
var
   fd:      text;
   sym:     symptr;
   stype:   byte;
   inbuf:   array[1..inbufsiz] of byte;
   line:    string;
      
begin
   {enter into initializer table}
   addinit(name + '_init()');

   {generate an include for the unit header file}
   puts('#include <'+name+'.UNH>');
   putline;

   {read file into the symbol table}
   name := name + '.UNS';
   assign(fd,name);
   {$I-} reset(fd); {$I+}
   if ioresult <> 0 then
   begin
      name := symdir + name;
      assign(fd,name);
      {$I-} reset(fd); {$I+}
   end;
   
   if ioresult <> 0 then
   begin
      ltok := name;
      fatal('Can''t open unit symbol file');
   end;
   
   setTextBuf(fd,inbuf);

   readln(fd,line);
   if line <> symfile_vers then
   begin
      ltok := name;
      fatal('Incompatible .UNS format');
   end;
   
   {enter all symbols into symbol table}
   while not eof(fd) do
   begin
      new(sym);
      
      readln(fd,sym^.id);
      readln(fd,sym^.repid);
      readln(fd,line);
      readln(fd,stype,
                sym^.base,
                sym^.limit,
                sym^.parcount,
                sym^.pvar);

      if line[1] = '-' then
         sym^.parent := sym
      else

      begin                       {speed hack-search builtins first}
         sym^.parent := findsym(builtins,line);
         if sym^.parent = nil then
            sym^.parent := findsym(table,line);
      end;

      sym^.symtype := symtypes(stype);
      sym^.next := table;
      table := sym;
   end;

   close(fd);
   previd := '?';
end;


