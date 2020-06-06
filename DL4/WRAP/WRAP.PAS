
(*
 * wrap - filter to wrap long lines at 80 columns
 *
 * s.h.smith, 4-jun-86
 *
 *)

{$g10240,p512,d-,c-}

type
   string3 = string[3];

var
   pos:  integer;
   ch:   char;

function hex(i: integer): string3;
   function digit(d: integer): char;
   begin
      d := d and $0F;
      if d > 9 then
         digit := chr(d + 7 + ord('0'))
      else
         digit := chr(d + ord('0'));
   end;
begin
   hex := '$' + digit(i shr 4) + digit(i);
end;


begin
   pos := 1;
   while not eof do
   begin
      read(ch);

      case ch of
      #13: begin writeln('<Ù'); pos := 1; end;
      #10: ;
      #0..#12,#14..#31,#128..#255:
           begin
              write(hex(ord(ch)));
              pos := pos + 3;
           end;
      else begin write(ch); pos := pos + 1; end;
      end;

      if pos >= 78 then begin writeln('>>'); pos := 1; end;
   end;
end.
