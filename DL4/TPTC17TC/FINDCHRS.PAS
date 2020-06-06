
(*
 * Example of sets of characters
 *
 *)
 
program Find_All_Lower_Case_Characters;

const 
    String_Size = 30;

type 
    Low_Set = set of 'a'..'z';

var 
    Data_Set    : Low_Set;
    Storage     : string[String_Size];
    Index       : 1..String_Size;
    Print_Group : string[26];

begin  (* main program *)
   Data_Set := [];
   Print_Group := '';
   Storage := 'This is a set test.';

   for Index := 1 to Length(Storage) do begin
      if Storage[Index] in ['a'..'z'] then begin
         if Storage[Index] in Data_Set then
            Writeln(Index:4,'   ',Storage[Index],
                         ' is already in the set')
         else begin
            Data_Set := Data_Set + [Storage[Index]];
            Print_Group := Print_Group + Storage[Index];
            Writeln(Index:4,'   ',Storage[Index],
                         ' added to group, complete group = ',
                         Print_Group);
         end;
      end
      else
         Writeln(Index:4,'   ',Storage[Index],
                       ' is not a lower case letter');
   end;
end.  (* of main program *)
