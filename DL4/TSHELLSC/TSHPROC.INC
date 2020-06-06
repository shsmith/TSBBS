
const tshproc_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Process interrupts 1.1'#0;
#log Process interrupts 1.1

(*
 * tshproc - process each of the turbo interrupts
 *)

{variables that are stacked when a nested include is encountered}

type
   sector = array [1..128] of byte;

   include_stackrec = record
      include:      byte;
      incname:      zstring;
      next_incbuf:  integer;
      end_incbuf:   integer;
      outer_dirbits:integer;
      inc_handle:   integer;
      inc_buffer:   sector;
   end;


const
   max_include = 5;        {maximum levels of include nesting}

var
   include_stack:  array[1..max_include] of include_stackrec;
   include_level:  integer;


{these pointers refer to data in turbo's data segment}

var
   line_nump:          ^integer;      {current linenumber pointer}
   line_textp:         ^zstring;      {current line text pointer}
   in_includep:        ^byte;         {non-0 while in include file}
   include_namep:      ^zstring;      {include filename pointer}
   main_namep:         ^zstring;      {main filename pointer}
   work_namep:         ^zstring;      {work filename pointer}
   error_codep:        ^byte;         {compile error code, 0=ok}
   compile_typep:      ^byte;         {0=find-error, 1=mem, 2=com, 3=chn}

   next_incbufp:       ^integer;      {saved in push_include}
   end_incbufp:        ^integer;
   inc_fileposp:       ^integer;
   outer_dirbitsp:     ^integer;
   inc_handlep:        ^integer;
   inc_bufferp:        ^sector;

   mainfile:           anystring;     {main filename}
   wasinclude:         byte;



(*------------------------------------------
 *
 * initialize_pointers
 *    initialize all data pointers to point into
 *    the turbo.com data segment.
 *)

procedure initialize_pointers;
begin

   with special [version] do
   begin
      line_nump       := ptr (turbo_ds, line_number  ); {total line number}
      line_textp      := ptr (turbo_ds, line_buffer  ); {current line text}
      in_includep     := ptr (turbo_ds, in_include   ); {include status flag}
      include_namep   := ptr (turbo_ds, include_fname); {include filename}
      main_namep      := ptr (turbo_ds, main_filename); {main filename}
      work_namep      := ptr (turbo_ds, work_filename); {work filename}
      error_codep     := ptr (turbo_ds, error_code   ); {compile error code}
      compile_typep   := ptr (turbo_ds, compile_type ); {2=com 3=chn}

      next_incbufp    := ptr (turbo_ds, next_incbuf  ); {pushed}
      end_incbufp     := ptr (turbo_ds, end_incbuf   ); {pushed}
      inc_fileposp    := ptr (turbo_ds, inc_filepos  ); {pushed}
      outer_dirbitsp  := ptr (turbo_ds, outer_dirbits); {pushed}
      inc_handlep     := ptr (turbo_ds, inc_handle   ); {pushed}
      inc_bufferp     := ptr (turbo_ds, inc_buffer   ); {pushed}
   end;

end;


(*------------------------------------------
 *
 * first_line_initialization
 *    perform initialization before
 *    first line of source is compiled
 *)

procedure first_line_initialization;
begin
   include_level := 0;
   current_entry := 0;

   ztos(main_namep^,mainfile);
   if LEN(mainfile) = 0 then        {use work filename if no main filename}
      ztos(work_namep^,mainfile);

   preprocess_initialize;

   preproc_current_file(mainfile);

   if compile_typep^ = 2 then
   begin
      open_logfile(mainfile);
      log_sourcefile(mainfile);
   end
   else
      logging := false;

   gotoxy(15,wherey);            {display mainfile name on screen}
   write(con,mainfile);

end; {first_line_initialization}



(*------------------------------------------
 *
 * include_status_check
 *    keep track of include files and line numbers.
 *    put include file status on the screen.
 *    (line numbers are not reset to 1 when an include file is entered.)
 *
 *)

procedure include_status_check;
var
   name: anystring;

begin

   if in_includep^ <> 0 then
   begin                         {in an include file}

      if wasinclude = 0 then           {if just entered...}
      begin
         ztos(include_namep^,name);
         preproc_current_file(name);   {let preprocessor know current file}

         writeln;
         gotoxy(15,wherey);            {display include name on screen}
         write(con,name);
         clreol;
      end;

   end;

   wasinclude := in_includep^;
end;



(*------------------------------------------
 *
 * line_no_process
 *    this interrupt occurs each time Turbo.com
 *    starts to process a new line of text
 *)

procedure line_no_process;
begin
   {check for starting conditions}
   if memw[turbo_ds : special[version].line_number] = 1 then
   begin
      initialize_pointers;
      first_line_initialization;
   end;

   {display include file status}
   include_status_check;

   {fetch the current source line}
   ztos(line_textp^,line_txt);

   {preprocess it}
   preprocess_source_line;

   {pass the result back to turbo}
   stoz(line_txt,line_textp^);
end;



(*------------------------------------------
 *
 * push_include_state
 *    this interrupt occurs each time Turbo.com
 *    starts to process a new include statement.
 *    the include state-variables must be pushed
 *    on a stack to allow include nesting.
 *)

procedure push_include_state;
begin
   if include_level >= max_include then
   begin
      error('Include files nested too deeply');
      exit;
   end;

   INCR(include_level);

   with include_stack[include_level] do
   begin
      include        := in_includep^;
      incname        := include_namep^;
      next_incbuf    := next_incbufp^;
      end_incbuf     := end_incbufp^;
      outer_dirbits  := outer_dirbitsp^;
      inc_handle     := inc_handlep^;
      inc_buffer     := inc_bufferp^;
   end;

   in_includep^ := 0;   {fool turbo into thinking there is no include active}
   wasinclude := 0;     {force filename display}
end;



(*------------------------------------------
 *
 * pop_include_state
 *    this interrupt occurs each time Turbo.com
 *    detects EOF on an include file.
 *    the include state-variables must be popped
 *    off a stack to allow include nesting.
 *)

procedure pop_include_state;
var
   name:  anystring;

begin
   if include_level < 1 then
   begin
      error('Include stack underflow');
      exit;
   end;

   with include_stack[include_level] do
   begin
      in_includep^    := include;
      include_namep^  := incname;
      next_incbufp^   := next_incbuf;
      end_incbufp^    := end_incbuf;
      outer_dirbitsp^ := outer_dirbits;
      inc_handlep^    := inc_handle;
      inc_bufferp^    := inc_buffer;
   end;

   DECR(include_level);

   write(#13);
   clreol;    {remove include file indication after
               last line of include has been processed}
   gotoxy(1,wherey-1);

   {determine active filename}
   if in_includep^ = 0 then
      COPY_STR(name, mainfile)
   else
      ztos(include_namep^,name);

   preproc_current_file(name);

end;



(*------------------------------------------
 *
 * end_compile_process
 *    this interrupt occurs each time Turbo.com
 *    completes a compile and does an error check.
 *)

procedure end_compile_process;
begin
   close_logfile(error_codep^, line_nump^);
end;



(*------------------------------------------
 *
 * pop_replacement
 *    pop the line from the top of the replacement stack
 *    into the turbo line input buffer
 *    (called by a patch into turbo's cseg)
 *)

procedure pop_replacement;
var
   trash:    replace_ptr;

begin
   {pass the line back to turbo}
   stoz(repstack^.line^,line_textp^);

   {dispose of the line and prepare for next line down}
   trash := repstack;
   repstack := repstack^.prior;
   freemem(trash^.line,LEN(trash^.line^));
   DECR(replevel);
end;

