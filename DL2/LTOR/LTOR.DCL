type
   long_int = record
      case integer of
         1: (b: array[1..4] of byte);
         2: (lsw: integer;
             msw: integer);
   end;
