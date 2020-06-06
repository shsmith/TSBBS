
#log Preprocessor macro replacement 1.1

(*------------------------------------------
 *
 * tshmacr.inc - macro_replacement module
 *    does replacement based on macro table contents.
 *
 *)

{$r-,k-  rangecheck off,this file only!}

#include "idtable.inc"  {table of legal identifier characters}


{these variables must be global for the best speed}
var
   next_c:         char;            {current character being scanned}
   lpos:           integer;         {current line position}
   lineout:        string[255];     {scratch output line buffer}
   nword:          anystring;       {current word/replacement}
   key_entry:      integer;         {current replacement table entry}
   change_cnt:     integer;         {count of replacements on current line}
   line_changed:   boolean;         {a replacement has been done on this line}



(*
 * these macros define a set of inline functions used in scanning the
 * the line during macro replacement.  the inline code was generated
 * by inliner and formatted into tshell macros.
 *
 *)

#define SCAN                                         \
   inline($FF/$06/lpos/      {inc (w) lpos        }  \
          $8B/$36/lpos/      {mov si,lpos         }  \
          $8A/$84/line_txt/  {mov al,[si]line_txt }  \
          $A2/%1)            {mov %1,al           }
   {-- scan next char from line_txt into a global char:  ...(tochar)}


#define APPEND                                       \
   inline($FE/$06/%1/        {inc (b) %1          }  \
          $8A/$1E/%1/        {mov bl,%1           }  \
          $32/$FF/           {xor bh,bh           }  \
          $A0/%2/            {mov al,%2           }  \
          $88/$87/%1)        {mov [bx]%1,al       }
   {-- append a global char to a global buffer:  ...(buffer,char)}



(*------------------------------------------
 *
 * perform_substitution
 *    perform macro replacement on nword
 *    enter:  key_entry is define table entry to replace
 *    exit:   nword    is the replacement string
 *
 * actual parameters are processed and replaced by %1..%9
 *
 *)

procedure perform_substitution;
var
   actual_param:  array[1..9] of anystring;   {table of actual parameters}
   replacement:   anystring;                  {string under construction}
   lev:           integer;                    {the paren level in param list}
   p:             integer;
   last:          replace_ptr;
   lastc:         char;
   lastpos:       integer;
   rest:          anystring;

   procedure collect_actual_params;
   begin
      line_changed := true;
      for p := 1 to 9 do
         TRUNC( actual_param[p] );

      {skip optional blanks before the parameter list}
      lastpos := lpos;
      while next_c = ' ' do
         SCAN( next_c );

      {check for and collect actual parameters to the macro}
      if next_c = '(' then
      begin
         {put the actual params into actual_param[n],  blank for unpassed pars}
         p := 1;
         lev := 1;
         repeat
            SCAN( next_c );

            case next_c of
               ',':  {advance to next actual parameter (only if not within
                      nested parens)}
                     if ( p < 9 ) and ( lev = 1 ) then
                        INCR( p )
                     else
                        actual_param[p] := actual_param[p] + next_c;

               '(':  {increase paren nesting}
                     begin
                        actual_param[p] := actual_param[p] + next_c;
                        INCR( lev );
                     end;

               ')':  {decrease paren nesting; avoid appending final ")"}
                     begin
                        DECR( lev );
                        if ( lev > 0 ) then
                           actual_param[p] := actual_param[p] + next_c;
                     end;

               ^@:   {unexpected end of line}
                     begin
                        error( 'Missing ")" in macro call' );
                        exit;
                     end;

               else  {copy all other characters unchanged}
                     actual_param[p] := actual_param[p] + next_c;
            end;

         until lev < 1;    {stop when final ")" is seen}

         {consume the final ")"}
         SCAN( next_c );
      end
      else
      begin
         lpos := lastpos-1;
         SCAN( next_c );
      end;

      lastc := next_c;
   end;

begin

   {walk through overflows looking for the correct keyword}
   while define_table[key_entry].key <> nword do
   begin
      if key_entry = max_define then
         key_entry := 1
      else
         INCR( key_entry );

      if LEN( define_table[key_entry].key ) = 0 then
         exit;                       {didn't find it!}
   end;


   {found the proper keyword; do the replacement}

   collect_actual_params;
   TRUNC( nword );
   last := define_table[key_entry].last;

   while last <> nil do
   begin

      {if this is not the first line, then push current line
       into replacement stack and start a new one}
      if LEN( nword ) <> 0 then
      begin

         {stack the rest of the source line for processing later}
         if lastc <> EOS then
         begin
            rest := copy(line_txt,lpos,255);
            link_line(repstack, rest);
            lastc := EOS;
            INCR( replevel );
         end;

         link_line(repstack, nword);
         TRUNC( nword );
         INCR( replevel );
      end;

      {replace formal parameters with actual parameters}
      p := 1;
      replacement := last^.line^;

      while p <= LEN( replacement ) do
      begin
         next_c := replacement[p];
         INCR( p );

         if next_c = '%' then       {check for %n type params}
         begin
            next_c := replacement[p];
            INCR( p );

            if ( next_c < '1' ) or ( next_c > '9' ) then
               error( 'Invalid parameter substitution:  '+replacement )

            else       {replace %n with actual_param[n]}
               nword := nword + actual_param[ ord( next_c )-ord( '0' ) ];
         end
         else          {copy other chars}
            APPEND( nword, next_c );

      end;

      last := last^.prior;
   end;

   {restore character following the macro call}
   next_c := lastc;

   {check for looping expansions}
   INCR( change_cnt );
   if ( change_cnt > 100 ) then
   begin
      error( 'Endless macro expansion:  '+replacement );
      line_changed := false;
   end;

end;


(*------------------------------------------
 *
 * macro_replacement
 *    performs macro replacement on line_txt
 *    leaves processed text in line_txt
 *    repeatedly replaces line until no more replacements are possible
 *
 *)

procedure macro_replacement;
begin
   change_cnt := 0;

   repeat
      line_changed := false;
      TRUNC( nword );
      TRUNC( lineout );
      lpos := 0;
      line_txt[ LEN( line_txt )+1 ] := EOS;

      {scan first character on line}
      SCAN( next_c );

      {scan each character in the source line}
      while ( next_c <> EOS ) do
      begin

         {scan delimiters}
         if start_ident_table[ next_c ]=false then
         begin
Inline(
 $8A/$1E/lineout            {    mov bl,lineout }
/$32/$FF                    {    xor bh,bh     ;bx=lineout }
/$8B/$36/lpos               {    mov si,lpos   ;si=lpos    }
/$32/$E4                    {    xor ah,ah     ;ax=nextc }
/$A0/next_c                 {    mov al,next_c         }
                            { ;                      }
                            { loop:                }
/$FE/$C3                    {    inc bl          }
/$88/$87/lineout            {    mov [bx]lineout,al    ;append }
/$46                        {    inc si                      }
/$8A/$84/line_txt           {    mov al,[si]line_txt ;scan }
/$0A/$C0                    {    or al,al                }
/$74/$0B                    {    jz endline          ;stop if end of line }
/$8B/$F8                    {    mov di,ax                              }
/$2E/$8A/$8D/
        start_ident_table   {    mov cl,cs:[di]start_ident_table }
/$0A/$C9                    {    or cl,cl                           }
/$74/$E6                    {    jz loop             ;loop while not legal }
                            { ;                                                }
                            { endline:                                       }
/$89/$36/lpos               {    mov lpos,si                               }
/$88/$1E/lineout            {    mov lineout,bl                          }
/$A2/next_c  );             {    mov next_c,al                         }
          (*
           *  repeat
           *     APPEND( lineout, next_c );
           *     SCAN( next_c );
           *  until (next_c = EOS) or start_ident_table[ next_c ];
           *)

         end
         else

         {build up the identifier}
         begin
Inline(
 $8A/$1E/nword              {    mov bl,nword }
/$32/$FF                    {    xor bh,bh     ;bx=nword }
/$8B/$36/lpos               {    mov si,lpos   ;si=lpos }
/$32/$E4                    {    xor ah,ah     ;ax=nextc }
/$A0/next_c                 {    mov al,next_c         }
                            { ;                      }
                            { loop:                }
/$FE/$C3                    {    inc bl          }
/$88/$87/nword              {    mov [bx]nword,al    ;append }
/$46                        {    inc si                    }
/$8A/$84/line_txt           {    mov al,[si]line_txt ;scan }
/$8B/$F8                    {    mov di,ax               }
/$2E/$8A/$8D/ident_table    {    mov cl,cs:[di]ident_table }
/$0A/$C9                    {    or cl,cl                }
/$75/$EA                    {    jnz loop            ;loop while legal ident }
                            { ;                                            }
/$89/$36/lpos               {    mov lpos,si                             }
/$88/$1E/nword              {    mov nword,bl                          }
/$A2/next_c  );             {    mov next_c,al                       }

(*
 *          repeat
 *             APPEND( nword, next_c );
 *             SCAN( next_c );
 *          until ident_table[ next_c ]=false;
 *)

            {replace ident with it's replacement if it is in
             the table; otherwise just copy the original word}

            key_entry := key_hash( nword );

#ifdef DEBUGGING
   flush(output);
   writeln('entry=',key_entry:3,' word=<',nword,'>');
#endif

            if LEN( define_table[key_entry].key ) <> 0 then
               perform_substitution;

            {append the word or it's replacement}
            CONCAT_STR(lineout,nword);
            TRUNC(nword);

            {append the delimiter}
            if next_c <> EOS then     {prevent scanning past end of line}
            begin
               APPEND( lineout, next_c );
               SCAN( next_c );
            end;
         end;
      end;


      {verify that the line did not overflow}
      if LEN( lineout ) >= longest_line then
      begin
         error( 'Processed line is too long' );
         line_changed := false;
      end;


      {replace line_txt with the new version}
      if line_changed then
         COPY_STR( line_txt, lineout )

   until line_changed=false;
end;

