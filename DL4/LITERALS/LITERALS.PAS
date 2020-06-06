


(*
 * literals - filter to pass only the literal strings in a pascal source file
 *
 * 11-oct-85 shs - derived from pp.pas
 *
 *)
{$p5120,g512,c-,d-}


program paspp (input,
               output);
const
   linelen =      128;        {longest line length}

   newline =      ^J;

type
   anystring =    string [linelen];

   toktypes =     (number,
                   identifier,
                   strng,
                   comment,
                   unknown);

var
   ltok:          anystring;
   tok:           anystring;
   toktype:       toktypes;
   unchrflag:     char;
   line:          integer;



(*
 * pascal lexical scanner
 *
 *)

function getchar: char;
var
   c:             char;

begin

   if unchrflag <> chr (0) then
   begin
      getchar := unchrflag;
      unchrflag := chr (0);
   end
   else
   begin

      if eof (input) then
      begin
         writeln(con, ' input lines');
         halt;
      end
      else
         read(input, c);

      if c = newline then
      begin
         line := line + 1;

         if (line mod 16)= 1 then
            write(con, #13, line : 5);
      end;

      getchar := c;
   end;
end;

procedure ungetchar (c:             char);
begin
   unchrflag := c;
end;

procedure scanident;
var
   c:             char;

begin
   toktype := unknown;

   repeat
      c := getchar;

      case c of
         'a'..'z', 'A'..'Z', '0'..'9', '_':
            ltok := ltok + c;

         else           toktype := identifier;
      end;

   until toktype = identifier;

   ungetchar(c);
end;


procedure scannumber;
var
   c:             char;

begin
   toktype := unknown;

   repeat
      c := getchar;

      case c of
         '0'..'9', '.': ltok := ltok + c;

         else           toktype := number;
      end;

   until toktype = number;

   ungetchar(c);
end;


procedure scanstring;
var
   c:             char;

begin
   toktype := unknown;

   repeat
      c := getchar;
      ltok := ltok + c;

      if c = '''' then
      begin
         c := getchar;

         if c = '''' then
            ltok := ltok + c
         else
         begin
            ungetchar(c);
            toktype := strng;
         end;
      end;

   until toktype = strng;
end;



procedure scanhex;
var
   c:             char;

begin
   c := getchar;

   while c in ['0'..'9', 'A'..'F', 'a'..'f'] do
   begin
      ltok := ltok + c;
      c := getchar;
   end;

   ungetchar(c);
   toktype := number;
end;


procedure scantok;
var
   c:             char;

begin

   repeat
      c := getchar;

      case c of
         ' ',^I,^M,^J,^@,^L:
            c := newline;
      end;
   until c <> newline;

   ltok := c;

   case c of
      'a'..'z', '_', 'A'..'Z':
         scanident;

      '0'..'9', '#': scannumber;

      '''':          scanstring;

      '$':           scanhex;

      else           toktype := unknown;
   end;
end;


procedure gettok; forward;

procedure skipcurlycomment;
var
   c:             char;

begin

   c := getchar;
   while c <> '}' do
   begin
      c := getchar;
   end;

   toktype := comment;

end;


procedure skipparencomment;
var
   c:             char;

begin

   repeat
      c := getchar;

      if c = '*' then
      begin
         c := getchar;

         if c = ')' then
            toktype := comment
         else
            ungetchar(c);
      end;

   until toktype = comment;

end;


procedure gettok;
var
   i:             integer;
   c:             char;

begin
      repeat
         scantok;

         if ltok = '{' then
            skipcurlycomment;

         if ltok = '(' then
         begin
            c := getchar;

            if c = '*' then
               skipparencomment
            else
               ungetchar(c);
         end;

      until toktype <> comment;

      tok := ltok;
end;


procedure scaninit;
begin
   ltok := '';
   tok := '';
   toktype := unknown;
   line := 0;
end;


begin
   scaninit;

   repeat
      gettok;

      if toktype = strng then
         writeln(tok);

   until eof(input);
end.
