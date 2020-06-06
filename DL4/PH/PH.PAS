


(*
 * pheir - generate pascal heirarchy listing from
 *         output of pcrf utility
 *
 * shs 23-aug-85
 *
 * usage:  pcrf SOURCE | pheir >OUTPUT
 *
 *)

{$g1024,p128,d-,c-}

const

   linelen =      100;
   maxlines =     2000;

type
   def_type =     (defined,
                   referenced);

   anystring =    string [linelen];

   def_ptr =      ^def_rec;
   ref_ptr =      ^ref_rec;

   def_rec =      record
         first_ref:     ref_ptr;
         def_ident:     string [41];
         stat:          def_type;
         next:          def_ptr;
   end;

   ref_rec =      record
         ref_def_ptr:   def_ptr;
         next:          ref_ptr;
   end;

var
   first_def:     def_ptr;
   maxlevel:      integer;    {number of levels to show in the heirarchy}
   nomore:        boolean;



function trim (s:             anystring): anystring;
   var
      ident:         anystring;

   begin
      ident := s;

      while ident [length (ident)]= ' ' do
         ident := copy (ident, 1, length (ident)- 1);

      trim := ident;
   end;


function stoupper (s:  anystring): anystring;
   var
      u:  anystring;
      i:  integer;
   begin
      u := s;
      for i := 1 to length(s) do
         u[i] := upcase(s[i]);
      stoupper := u;
   end;



procedure new_definition (var cur_def:   def_ptr;
                          ident:         anystring;
                          new_stat:      def_type);
   var
      definition:    def_ptr;
      new_def:       def_ptr;
      prev_def:      def_ptr;
      c:             char;

   begin

      if keypressed then
      begin
         read(kbd,c);
         if c = ^C then
         begin
            writeln(con,'** ^C');
            halt;
         end;
      end;


(* search for the desired proc *)

      definition := first_def;
      prev_def := nil;

      while (definition <> nil) do
      begin

         if definition^.def_ident = ident then
         begin

            if new_stat = defined then
               definition^.stat := new_stat;

            cur_def := definition;         {make it the current one if found}
            exit;
         end;

         if (definition^.next = nil) or
            (stoupper(definition^.def_ident) > stoupper(ident)) then

         begin
            new(new_def);              {insert a new one in sorted position}


            if prev_def = nil then
            begin
               new_def^.next := first_def;
               first_def := new_def;
            end
            else
            begin
               prev_def^.next := new_def;
               new_def^.next := definition;
            end;

            new_def^.def_ident := ident;
            new_def^.first_ref := nil;
            new_def^.stat := new_stat;
            cur_def := new_def;
            exit;
         end;

         prev_def := definition;
         definition := definition^.next;
      end;
   end;


procedure new_reference (var cur_def:   def_ptr;
                         ident:         anystring);
   var
      new_ref:       ref_ptr;
      reference:     ref_ptr;
      prev_ref:      ref_ptr;
      definition:    def_ptr;

   begin


(* create a new procedure for this reference if needed *)
      new_definition(definition, ident, referenced);


(* search for a matching reference node -
   nothing to do if already referenced *)

      reference := cur_def^.first_ref;
      prev_ref := nil;

      while reference <> nil do
      begin

         if reference^.ref_def_ptr^.def_ident = ident then
            exit;

         if stoupper(reference^.ref_def_ptr^.def_ident) > stoupper(ident) then
         begin
            new(new_ref);

            if prev_ref = nil then
            begin
               new_ref^.next := reference;
               cur_def^.first_ref := new_ref;
            end
            else
            begin
               new_ref^.next := prev_ref^.next;
               prev_ref^.next := new_ref;
            end;

            new_ref^.ref_def_ptr := definition;
            exit;
         end;

         prev_ref := reference;
         reference := reference^.next;
      end;

      if prev_ref = nil then
      begin
         new(new_ref);
         cur_def^.first_ref := new_ref;
         new_ref^.next := nil;
         new_ref^.ref_def_ptr := definition;
         exit;
      end;

      new(new_ref);
      new_ref^.next := prev_ref^.next;
      prev_ref^.next := new_ref;
      new_ref^.ref_def_ptr := definition;
   end;


procedure build_reftab;
   var
      buf:           anystring;
      cur_def:       def_ptr;
      line:          integer;

   begin
      new(first_def);
      cur_def := first_def;
      cur_def^.next := nil;
      cur_def^.first_ref := nil;
      cur_def^.def_ident := '';
      cur_def^.stat := referenced;
      line := 0;

      while not eof (input) do
      begin
         readln(input, buf);
         new_definition(cur_def, trim (copy (buf, 41, 40)), defined);
         new_reference(cur_def, trim (copy (buf, 1, 40)));

         line := line + 1;
         if (line mod 16) = 1 then
            write(con, #13, line);
      end;

      writeln(con, #13, line,' input lines');
   end;


procedure indent_to(level: integer);
   const
      TAB = ^I;
   var
      i:  integer;
   begin
      for i := 1 to level do
         write(TAB);
   end;


procedure display_definition_of (definition:    def_ptr;
                   level:         integer);
   var
      reference:     ref_ptr;
      c:             char;

   begin

      if keypressed then
      begin
         read(kbd,c);
         if c = ^C then
         begin
            writeln(con,'** ^C');
            halt;
         end;
      end;


      indent_to(level);
      writeln(definition^.def_ident);

      if definition^.first_ref = nil then
         exit;

      if level < maxlevel then
      begin
         reference := definition^.first_ref;

         while reference <> nil do
         begin

            if reference^.ref_def_ptr <> definition then
               display_definition_of(reference^.ref_def_ptr, level + 1);

            reference := reference^.next;
         end;
      end
      else

      if nomore = false then
      begin

         indent_to(level);
         writeln('   --(more)');
      end;
   end;


procedure walk_procs;
   var
      definition:    def_ptr;

   begin
      definition := first_def;

      while definition <> nil do
      begin

         if definition^.stat = defined then
         begin
            writeln('---------------------------------------------');
            display_definition_of(definition, 0);
            writeln;
         end;

         definition := definition^.next;
      end;

      writeln('---------------------------------------------');
      writeln(' External symbols:');
      definition := first_def;

      while definition <> nil do
      begin

         if definition^.stat = referenced then
            display_definition_of(definition, 1);

         definition := definition^.next;
      end;
   end;


function atoi(s: anystring): integer;
var
   i:  integer;
   v:  integer;

begin
   v := 0;
   for i := 1 to length(s) do
   begin
      if s[i] in ['0'..'9'] then
         v := v * 10 + ord(s[i]) - ord('0')
      else
      begin
         writeln(con,'Invalid number: ',s);
         halt;
      end;
   end;

   atoi := v;
end;




var
   i:  integer;

begin                         {main}

   nomore := false; {default print --more at limit}
   maxlevel := 3;   {default level limit}

   i := 1;
   while i <= paramcount do
   begin
      if paramstr(i) = '-nomore' then
         nomore := true
      else

      if paramstr(i) = '-limit' then
      begin
         i := i + 1;
         maxlevel := atoi(paramstr(i));
      end
      else

      begin
         writeln(con,'Invalid option: ',paramstr(i));
         writeln(con,'Usage: ph [-nomore] [-limit N]  <INFILE >OUTFILE');
         halt;
      end;

      i := i + 1;
   end;


   build_reftab;
   walk_procs;

end.
