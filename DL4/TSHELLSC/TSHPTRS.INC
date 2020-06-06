
const tshptrs_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Turbo pointer tables 1.1'#0;
#log Turbo pointer tables 1.1


{--------- version specific information for turbo ----------------
  note: the following four items relate to the turbo version compiling this
   program, not the one being loaded!  however, except for flag_bits,
   the four items are identical for all four.
}


const
  turbo_ds: integer = 0;    {reserve 2 words in cseg for a pointer}
  turbom_cs = $176; {turbo's cs from program in memory}

var
  err_addr : integer absolute dseg : $188; {pc where error was found}
  screenmode : byte absolute dseg : $6; {where current screen mode stored}
  flag_bits : integer; {bit 0 = 1 if prog is in memory, else a compiled prog
                         value found in checkwhichcompiler}

  {-------------checkwhichcompiler}
  procedure checkwhichcompiler;
  {-see which compiler compiled this. numbers apply to plain vanilla
    turbo only.}
  begin
    if memw[cseg:$101] = $2c4a then {the first jmp instruction}
      flag_bits := $174 {version 3.02a}
    else flag_bits := $172; {versions 3.00b and 3.01a}
  end;



{the following items apply to the turbo being loaded.}

type {the versions supported}
  versiontype = (v301a, toofar);


{turbo compiler data table}

const
  version_name: array[versiontype] of string[10] =
     ('3.01a','INVALID');

  special : array[versiontype] of
  record
    line_number,         {accumulated line numbers}
    line_buffer,         {holds current line being compiled}
    in_include,          {non zero when compiling in include file}
    include_fname,       {name of current include file}
    main_filename,       {main filename of program being compiled}
    work_filename,       {work filename}
    error_code,          {compile error code at end of compile}
    compile_type,        {0=find error, 1=mem, 2=com, 3=chn}

    next_incbuf,         {saved during nested includes}
    end_incbuf,          {      "      "      }
    inc_filepos,
    outer_dirbits,       {compiler directives before include}
    inc_handle,          {include file handle}
    inc_buffer           {include read buffer - 128 bytes long}

        : integer;
  end =

  ( ( line_number:     $05b0;       {version 3.01a}
      line_buffer:     $00b6;
      in_include:      $05bd;
      include_fname:   $06b6;
      main_filename:   $0307;
      work_filename:   $02c7;
      error_code:      $0284;
      compile_type:    $0283;
      next_incbuf:     $06f8;
      end_incbuf:      $06fa;
      inc_filepos:     $06fe;
      outer_dirbits:   $06aa;
      inc_handle:      $06f6;
      inc_buffer:      $0792
    ),

    ( line_number:     $0000       {toofar}
    )
  );

  type
     break_rec = record
        ofst, contents: integer;
     end;

var
  version : versiontype;


{turbo compiler breakpoint table}

const
  before_line_compile = 1;   {breakpoint codes}
  include_open        = 2;
  include_eof         = 3;
  end_compile         = 4;
  maxturbbrk          = 4;


  turb_brk: array[versiontype, 1..maxturbbrk] of break_rec =

                                        {v3.01a}
  ( ((ofst: $91cf;  contents: $b6bf),   {before a line is compiled}
     (ofst: $90f3;  contents: $3e80),   {before opening an include file}
     (ofst: $91c9;  contents: $8be8),   {eof on include file}
     (ofst: $3953;  contents: $3e80)    {end of compilation}
    ),

    ((ofst: $0000;  contents: $0000),   {toofar}
     (ofst: $0000;  contents: $0000),
     (ofst: $0000;  contents: $0000),
     (ofst: $0000;  contents: $0000))
  );

