

(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * Function:     char_bit(char, int, int): boolean
 *
 * Description:  Get the specified pixel bit in a character.
 *               The rom character set is used for all but special
 *               characters (128..255).
 *
 * Inputs:       the ascii character
 *               the scan line number 1..8
 *               the scan column 1..8
 *
 * Outputs:      true if the specified bit is set (lit)
 *
 *)

function char_bit(ch:        char;
                  scanline:  integer;
                  scancol:   integer):  boolean;
type
   rom_character = array [1..8] of byte;
   string8       = string[8];

var
   char_table:    array[#0..#127] of rom_character  absolute $F000:$FA6E;
                             { this is the character set in the bios
                               rom which is used in text display
                               in graphic video modes.  unfortunately,
                               this table does not include codes > #127 }

   function special_char(l1,l2,l3,l4,l5,l6,l7,l8: string8): boolean;
                             { return the pixel bits for a special char
                               that is not in the rom.  this is called with
                               8 strings that give a "picture" of how
                               the character should look on the output }
   var
      line:  string8;

   begin
      case scanline of
         1:  line := l1;
         2:  line := l2;
         3:  line := l3;
         4:  line := l4;
         5:  line := l5;
         6:  line := l6;
         7:  line := l7;
         8:  line := l8;
      end;

      special_char := (line[scancol] <> ' ');
   end;


begin  {char_bit}

   { look up the special characters that are not in the rom }

   case ch of
         'Ú','Õ','Ö','É':
               char_bit := special_char('        ',
                                        '        ',
                                        '        ',
                                        '   #####',
                                        '   #####',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ');

         '¿','¸','·','»':
               char_bit := special_char('        ',
                                        '        ',
                                        '        ',
                                        '#####   ',
                                        '#####   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ');

         'À','Ô','Ó','È':
               char_bit := special_char('   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   #####',
                                        '   #####',
                                        '        ',
                                        '        ',
                                        '        ');

         'Ù','¾','½','¼':
               char_bit := special_char('   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '#####   ',
                                        '#####   ',
                                        '        ',
                                        '        ',
                                        '        ');

         '³','º':
               char_bit := special_char('   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ');

         'Ä','Í':
               char_bit := special_char('        ',
                                        '        ',
                                        '        ',
                                        '########',
                                        '########',
                                        '        ',
                                        '        ',
                                        '        ');

         '´','µ','¹','¶':
               char_bit := special_char('   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '#####   ',
                                        '#####   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ');

         'Ã','Æ','Ì','Ç':
               char_bit := special_char('   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '   #####',
                                        '   #####',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ');

         'Á','Ð','Ï','Ê':
               char_bit := special_char('   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '########',
                                        '########',
                                        '        ',
                                        '        ',
                                        '        ');

         'Â','Ò','Ñ','Ë':
               char_bit := special_char('        ',
                                        '        ',
                                        '        ',
                                        '########',
                                        '########',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ');

         'Å','Ø','×','Î':
               char_bit := special_char('   ##   ',
                                        '   ##   ',
                                        '   ##   ',
                                        '########',
                                        '########',
                                        '   ##   ',
                                        '   ##   ',
                                        '   ##   ');

         '_':  char_bit := special_char('        ',
                                        '        ',
                                        '        ',
                                        '        ',
                                        '        ',
                                        '        ',
                                        '########',
                                        '########');

         ^@..#127:    {these characters are in the rom}
            char_bit := (char_table[ch][scanline] and ($100 shr scancol)) <> 0;

         else         {invalid characters will be printed as solid blocks}
            char_bit := true;
   end;
end;

