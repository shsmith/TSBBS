
(*
 * visible - filter to translate control characters in a file
 *           into visible characters
 *
 * shs 29-oct-85
 *
 *)

{$g1024,p10240,d-,c-}

program translate_control_characters_into_visible_strings;

var
   c:   char;

begin
   while not eof do
   begin
      read(input,c);
      case c of
      ^@..^I,^K,^L,^N..#31:
         write('^',chr(ord(c) + ord('@')));
       else
         write(c);
      end;
   end;

end.

