
(*
 * Example of array subscripting
 *)
 
program A_Small_Record;

type 
     Description = record
       Year    : integer;
       Model   : string[20];
       Engine  : string[8];
     end;

var  
     Cars  : array[1..10] of Description;
     Index : integer;

begin  (* main program *)
   for Index := 1 to 10 do begin
      Cars[Index].Year := 1930 + Index;   {should be ...[index-1]}
      Cars[Index].Model := 'Duesenburg';
      Cars[Index].Engine := 'V8';
   end;

   Cars[2].Model := 'Stanley Steamer';
   Cars[2].Engine := 'Coal';
   Cars[7].Engine := 'V12';
   Cars[9].Model := 'Ford';
   Cars[9].Engine := 'rusted';

   for Index := 1 to 10 do begin
      Write('My ',Cars[Index].Year:4,' ');
      Write(Cars[Index].Model,' has a ');
      Writeln(Cars[Index].Engine,' engine.');
   end;
end.  (* of main program *)
