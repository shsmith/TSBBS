
(*
 * table of legal starting characters in an identifier
 *      'A'..'Z','a'..'z','_'
 *)

const start_ident_table:  array[char] of boolean = (
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true, false, false, false, false,  true,
   false,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false);


(*
 * table of legal characters in an identifier
 *      'A'..'Z','0'..'9','a'..'z','_'
 *)

const ident_table:  array[char] of boolean = (
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true, false, false, false, false, false, false,
   false,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true, false, false, false, false,  true,
   false,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true,  true,  true,  true,  true,  true,
    true,  true,  true, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false,
   false, false, false, false, false, false, false, false);

