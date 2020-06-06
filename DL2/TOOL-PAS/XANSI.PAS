
const
   graphics = true;
type
   ansi_str = string[20];

function translate_ansi(xansi: ansi_str): ansi_str;
type
   string5 = string[5];

const
   fgtab:   array['0'..'?'] of string5 =
      (';30',   ';34',   ';32',   ';36',   ';31',   ';35',   ';33',   '',
       ';1;30', ';1;34', ';1;32', ';1;36', ';1;31', ';1;35', ';1;33', ';1');

   bgtab:   array['0'..'?'] of string5 =
      ('',  ';44',   ';42',   ';46',   ';41',   ';45',   ';43',   ';47',
      ';5', ';5;44', ';5;42', ';5;46', ';5;41', ';5;45', ';5;43', ';5;47');

begin
   translate_ansi := '';
   if not graphics then exit;

   if xansi[3] > '9' then dec(xansi[3],7);
   if xansi[4] > '9' then dec(xansi[4],7);

   if (xansi[3] < '0') or (xansi[3] > '?') then exit;
   if (xansi[4] < '0') or (xansi[4] > '?') then exit;

   translate_ansi := #27'[0'+ fgtab[xansi[4]] + bgtab[xansi[3]] + 'm';
end;

begin
{   writeln(translate_ansi('@X07'),'normal'); }
   writeln(translate_ansi('@X1F'),'white on blue');
   writeln(translate_ansi('@X2E'),'yellow on green');
   writeln(translate_ansi('@XF1'),'blink/blue on white');
{   writeln(translate_ansi('@X2E'),'yellow on green'); }
   writeln(translate_ansi('@X07'),'normal');
{   writeln(translate_ansi('@X1F'),'white on blue');
   writeln(translate_ansi('@X07'),'normal'); }
end.
