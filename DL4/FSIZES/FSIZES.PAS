
{fsizes - filter to print sizes of files listed in standard input}

{$p80,g8,d-}

type
   anystring = string[80];

{$i regpack.inc}
{$i ltor.inc}
{$i filesize.inc}
{$i filedate.inc}

var
   name:  anystring;
   date:  anystring;
   size:  real;
   i:     integer;

begin
   for i := 1 to paramcount do
   begin
      name := paramstr(i);

      size := file_size(name);        {123456}
      str(filedate(name):5:0,date);   {yymmdd}
      date := '8'+date;

      date := copy(date,3,2) + '-' +    (* convert to mm-dd-yy *)
              copy(date,5,2) + '-' +
              copy(date,1,2);

      while length(name) < 12 do
            name := name + ' ';

      writeln(name,size:9:0,'  ',date);
      flush(output);
   end;
end.


