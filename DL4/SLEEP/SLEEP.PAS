{sleep for 1 second}

{$I regpack.inc}
{$i givetime.inc}

var
   i: integer;

begin
   write(con,'sleeping 1 second...');
   for i := 1 to 20 do
      give_up_time;

   write(con,#13);
   clreol;
end.
