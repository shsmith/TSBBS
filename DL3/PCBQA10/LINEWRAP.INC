
(*
 * linewrap.inc - wrap a line of text into 1 or more shorter lines
 *
 * S.H.Smith, 24-May-87
 *
 *)

const
   max_lines = 10;   {maximum number of lines}

type
   linearray = array[1..max_lines] of anystring;


procedure line_wrap( line:        anystring;   {input text line}
                     width:       integer;     {width desired}
                     var out:     linearray;   {output lines}
                     var lines:   integer);    {number of lines output}
var
   i: integer;
   c: char;
   p: integer;
   n: integer;

begin
   {make sure the output lines are empty}
   for i := 1 to max_lines do
      out[i] := '';

   lines := 1;
   n := 0;
   p := 0;

   while n < LEN(line) do
   begin

      {get and copy the next character}
      INCR(n);
      c := line[n];
      INCR(p);
      out[lines][p] := c;
      out[lines][0] := chr(p);

      {is it time to wrap a line?}
      if p > width then
      begin
         {truncate line if no more lines}
         if lines = max_lines then
         begin
            DECR(out[lines][0]);
            exit;
         end;

         {find start of current word}
         i := n;
         while (c <> ' ') and (p > 2) do
         begin
            DECR(i);
            DECR(p);
            c := out[lines][p];
         end;

         {see if a word wrap is possible}
         if c = ' ' then
         begin
            out[lines][0] := chr(p-1);
            INCR(lines);
            p := 0;
            n := i;
         end
         else

         {word fills line, chop it up}
         begin
            DECR(out[lines][0]);
            INCR(lines);
            c := line[n];
            p := 1;
            out[lines][p] := c;
         end;
      end;
   end;
end;


