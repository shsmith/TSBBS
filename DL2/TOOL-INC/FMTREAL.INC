
function format_real(v: real): string;
var
   b:  string[40];

begin
   str(v:40:19,b);

   while b[1] = ' ' do           {remove leading spaces}
      delete(b,1,1);

   while (b[length(b)] = '0') do
      dec(b[0]);                 {remove trailing zeros}

   if b[length(b)] = '.' then
      dec(b[0]);                 {remove trailing period}

   format_real := b;
end;

