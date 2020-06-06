
(*
 * sort_node - sort the entries in a node
 *
 *)

procedure sort_node(node: node_ptr);
var
   i:        subnode_index;
   swapped:  boolean;
   temp:     node_ptr;

begin
   with node^ do
      repeat
         swapped := false;

         for i := 1 to count-1 do
            if subs^[i]^.name > subs^[i+1]^.name then
            begin
               temp := subs^[i];
               subs^[i] := subs^[i+1];
               subs^[i+1] := temp;
               swapped := true;
            end;

      until swapped = false;
end;

