
(* TOPUTIL.INC *)

(* ---------------------------------------------------------------- *)
procedure check_varno(  varno:         integer;
                        reason:        string);
begin
   case varno of
      FIRST_VAR..LAST_VAR:
         if varno < pulldown_nvars+FIRST_VAR then
            exit;

      FIRST_SVAR..LAST_SVAR:
         if varno < pulldown_nsvars+FIRST_SVAR then
            exit;
   end;

   writeln;
   writeln('[FAULT: ',reason,' varno=',varno,' out of range] Hit ESC: ');
   repeat
   until getkey = ESC;

end;


(* ---------------------------------------------------------------- *)
procedure edit_variable( pullno:        integer;
                         varno:         integer);
var
   save: ^window_save_rec;
   x,x2: integer;
   y:    integer;
   ans:  pulldown_string;
   v:    real;
   p:    integer;

begin
   check_varno(varno,'edit_variable');

   new(save);
   save_window(save^);

   window(1,1,80,25);

   y := wherey+1;
   x := wherex+1;
   x2 := x + sizeof(pulldown_string)+15;
   if x2 >= 79 then
   begin
      x2 := wherex + pulldown_table^[pullno].longest;
      x := x2 - sizeof(pulldown_string)-15;
   end;

   display_border(x,y,x2,y+2,evensolid_border);
   window(x+1,y+1,x2-2,y+1);

   gotoxy(1,1);
   disp(' New value: ');
   clreol;
   ans := '';
   readln(ans);

   if ans <> '' then
   begin
      case varno of
         FIRST_VAR..LAST_VAR:
            begin
               val(ans,v,p);
               if p = 0 then
                  pulldown_vars^[varno] := v;
            end;

         FIRST_SVAR..LAST_SVAR:
            begin
               pulldown_svars^[varno] := ans;
            end;
      end;
   end;

   restore_window(save^);
   dispose(save);
end;


(* ---------------------------------------------------------------- *)
procedure fixup_vars( pullno:   integer);
   {update pulldown titles to include current values of any
    defined variables}
var
   i: integer;
   p: integer;

begin
   for i := 1 to MAX_PULLDOWN do
   with pulldown_table^[pullno].line[i] do
      case action of

         FIRST_VAR..LAST_VAR:
            begin
               p := pos('=',title);
               if p > 0 then
                  title[0] := chr(p-1);   {remove previous value and "="}

               while title[length(title)] = ' ' do
                  dec(title[0]);          {remove trailing spaces}

               title := title + ' = ' + format_real(pulldown_vars^[action]);
            end;

         FIRST_SVAR..LAST_SVAR:
            begin
               p := pos('=',title);
               if p > 0 then
                  title[0] := chr(p-1);   {remove previous value and "="}

               while title[length(title)] = ' ' do
                  dec(title[0]);          {remove trailing spaces}

               title := title + ' = ' + pulldown_svars^[action];
            end;
      end;
end;


(* ---------------------------------------------------------------- *)
procedure do_store_settings;
var
   fd:   text;
   i:    integer;

begin
   assign(fd,pulldown_cnf);
   rewrite(fd);

   writeln(fd,pulldown_cnf);

   writeln(fd,pulldown_size,' Selections:');
   for i := 1 to pulldown_size do
      writeln(fd,pulldown_table^[i].curline);

   writeln(fd,pulldown_nvars,' Values:');
   for i := 1 to pulldown_nvars do
      writeln(fd,format_real(pulldown_vars^[i+FIRST_VAR-1]));

   writeln(fd,pulldown_nsvars,' Strings:');
   for i := 1 to pulldown_nsvars do
      writeln(fd,pulldown_svars^[i+FIRST_SVAR-1]);

   close(fd);
end;


(* ---------------------------------------------------------------- *)
procedure do_load_settings;
var
   fd:   text;
   n:    integer;
   i:    integer;
   s:    string;

begin
   assign(fd,pulldown_cnf);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      exit;

   readln(fd,s);

   read(fd,n);
   readln(fd,s);
   if n > pulldown_size then
      n := pulldown_size;
   for i := 1 to n do
      readln(fd,pulldown_table^[i].curline);

   read(fd,n);
   readln(fd,s);
   for i := 1 to n do
   begin
      check_varno(i+FIRST_VAR-1,'load settings(1)');
      readln(fd,pulldown_vars^[i+FIRST_VAR-1]);
   end;

   read(fd,n);
   readln(fd,s);
   for i := 1 to n do
   begin
      check_varno(i+FIRST_SVAR-1,'load settings(2)');
      readln(fd,pulldown_svars^[i+FIRST_SVAR-1]);
   end;

   close(fd);
end;


(* ---------------------------------------------------------------- *)
function get_ivar(  varno: integer ): integer;
begin
   check_varno(varno,'get_ivar');
   get_ivar := trunc(pulldown_vars^[varno]);
end;


(* ---------------------------------------------------------------- *)
function get_var(  varno: integer ): real;
begin
   check_varno(varno,'get_var');
   get_var := pulldown_vars^[varno];
end;


(* ---------------------------------------------------------------- *)
procedure put_var( varno: integer;
                   value: real );
begin
   check_varno(varno,'put_var');
   pulldown_vars^[varno] := value;
end;


(* ---------------------------------------------------------------- *)
function get_svar( varno: integer ): string;
begin
   check_varno(varno,'get_svar');
   get_svar := pulldown_svars^[varno];
end;


(* ---------------------------------------------------------------- *)
procedure put_svar(varno: integer;
                   value: string );
begin
   check_varno(varno,'put_svar');
   pulldown_svars^[varno] := value;
end;

