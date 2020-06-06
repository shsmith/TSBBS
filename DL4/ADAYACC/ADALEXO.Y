
/*
 * adalex.y - yacc grammar for ADA lexical elements
 *
 * For documentation only, should be hand-coded into adalex.c.
 * S.H.Smith, 29-sep-86
 *
 */


/* 2.1 */

graphic_character
   : basic_graphic_character | lower_case_letter | other_special_character ;

basic_graphic_character
   : upper_case_letter | digit | special_character | space_character ;

basic_character
   : basic_graphic_character | format_effector ;


/* 2.3 */

identifier
   : letter r.identifier ;
r.identifier
   : o.underline letter_or_digit r.identifier | ;
o.underline
   : underline | ;

letter_or_digit
   : letter | digit ;

letter
   : upper_case_letter | lower_case_letter ;


/* 2.4 */

numeric_literal
   : decimal_literal | based_literal ;


/* 2.4.1 */

decimal_literal
   : integer o.integer o.exponent ;
o.integer
   : '.' integer | ;
o.exponent
   : exponent | ;

integer
   : digit r.digit ;
r.digit
   : o.underline digit | ;

exponent
   : 'E' o.plus integer | 'E' o.minus integer ;
o.plus
   : '+' | ;
o.minus
   : '-' | ;


/* 2.4.2 */

based_literal
   : base '#' based_integer o.based_integer '#' o.exponent ;
o.based_integer
   : '.' based_integer | ;

base
   : integer ;

based_integer
   : extended_digit r.extended_digit ;
r.extended_digit
   : o.underline extended_digit | ;

extended_digit
   : digit | letter ;


/* 2.5 */

character_literal
   : '\'' graphic_character '\'' ;


/* 2.6 */

string_literal
  : '"' r.graphic_character '"' ;
r.graphic_character
  : r.graphic_character graphic_character | ;


