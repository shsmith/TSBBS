
(*
 * cnmerge - merge fragmented conferences in cndump output
 * s.h.smith, 22-sep-93
 *
 *)

const
   maxlen = 40;
   maxnet = 64;

type
   stringptr = ^string;
   nodeptr = ^noderec;
   noderec = record
      id: stringptr;
      next: nodeptr;
   end;
   netrec = record
      id: string[maxlen];
      first: nodeptr;
   end;

var
   net:     array[1..maxnet] of netrec;
   netcnt:  integer;
   curnet:  integer;
   i,j:     integer;
   node:    nodeptr;
   insp:    nodeptr;
   prev:    nodeptr;
   temp:    nodeptr;
   line:    string;
   tnet:    netrec;

begin
   netcnt := 0;
   curnet := 0;

   while not eof do
   begin
      readln(line);
      if pos(':',line) > 0 then
      begin
         curnet := 0;
         for i := 1 to netcnt do
            if net[i].id = line then
               curnet := i;

         if curnet = 0 then
         begin
            inc(netcnt);
            curnet := netcnt;
            net[curnet].id := line;
            net[curnet].first := nil;
         end;
      end
      else

      if line <> '' then
      begin
         new(node);
         getmem(node^.id,length(line)+1);
         node^.id^ := line;
         node^.next := nil;

         if net[curnet].first = nil then
            net[curnet].first := node
         else
         begin
            temp := net[curnet].first;
            insp := nil;
            prev := nil;
            while (insp = nil) and (temp <> nil) do
               if copy(temp^.id^,6,10) > copy(line,6,10) then
                  insp := temp
               else
               begin
                  prev := temp;
                  temp := temp^.next;
               end;

            if prev = nil then
            begin
               node^.next := net[curnet].first;
               net[curnet].first := node;
            end
            else

            if temp = nil then
            begin
               node^.next := nil;
               prev^.next := node;
            end
            else
            begin
               node^.next := insp;
               prev^.next := node;
            end;
         end;
      end;
   end;

   for i := netcnt downto 2 do
      for j := 1 to i-1 do
         if net[j].id > net[j+1].id then
         begin
            tnet := net[j];
            net[j] := net[j+1];
            net[j+1] := tnet;
         end;

   for i := 1 to netcnt do
   begin
      writeln;
      writeln(net[i].id);
      node := net[i].first;
      while node <> nil do
      begin
         writeln(node^.id^);
         node := node^.next;
      end;
   end;

end.

