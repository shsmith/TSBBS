
(*****************************
 *
 * Rescue -   Find and save a section of memory containing a
 *            keyword string.   This is useful in case of a program
 *            crash, exit without saving, or just for general snoopieness.
 *
 * Inspired by the (poorly written) program called RESQ from CP/M.
 *
 * Author:    Samuel H. Smith,  28-Dec-85
 *
 * Language:  Turbo Pascal 3.0
 *
 *)

program rescue_lost_text;

const
   bufsize = 255;      { size of buffers to search.  minimum 16 }


type
   anystring = string[bufsize];
                           { general purpose string }


var
   legals:   set of char;  { the set of legal characters to save }

   segment:  integer;      { the current segment number to search }

   offset:   integer;      { the offset into the current segment }

   key:      anystring;    { the keyword string to search for }

   keylen:   integer;      { the length of the key string }

   membuf:   anystring;    { characters starting in current segment of memory }

   trys:     integer;      { number of searches so far }



(*****************************
 *
 * Procedure:    change_location(integer)
 *
 * Description:  Adds or subtracts a number from the current memory
 *               location.  Knows about segments and will change the
 *               segment number to always keep the offset legal.
 *
 * Inputs:       by - the number of locations to increment or decrement by
 *
 * Outputs:      segment and offset
 *
 *)

procedure change_location(by: integer);
begin
   offset := offset + by;          { change the offset }

   while offset >= $100 do         { move up to higher segments }
   begin
      offset := offset - $100;
      segment := segment + $10;
   end;

   while offset < 0 do             { move down to lower segments }
   begin
      offset := offset + $100;
      segment := segment - $10;
   end;
end;



(*****************************
 *
 * Function:     hex(integer): anystring
 *
 * Description:  Returns a 4 digit hex string corresponding to the
 *               unsigned value of an integer.
 *
 * Inputs:       integer to convert
 *
 * Outputs:      the hex string
 *
 *)

function hex(int: integer): anystring;
var
   place:   integer;
   digit:   integer;
   c:       char;
   hexstr:  anystring;

begin

   hexstr := '';
   for place := 1 to 4 do
   begin
      digit := ((int shr 12) and 15);
      if digit < 10 then
         c := chr(digit + ord('0'))
      else
         c := chr(digit + ord('0') + 7);

      hexstr := hexstr + c;
      int := int shl 4;
   end;

   hex := hexstr;

end;


(*****************************
 *
 * Procedure:    display_string(anystring)
 *
 * Description:  Displays the contents of a string with special handling
 *               for characters that do not display.   There is also
 *               special handling for newlines:  a RETURN is marked on
 *               the screen as "<", and a LINEFEED causes the screen
 *               to both RETURN and LINEFEED.  This allows you to view
 *               text that has only LINEFEEDs or only RETURNs without
 *               geting pure garbage.   Non-ascii characters are printed
 *               as "<ascii-code>".
 *
 * Inputs:       the funny string to display
 *
 * Outputs:      the filtered out string on the screen
 *
 *)

procedure display_string(str: anystring);
var
   i:    integer;
   c:    char;

begin

   for i := 1 to length(str) do
   begin
      c := str[i];

      case c of
         ^I,' '..'~':  write(c);      { write normal characters }

         ^J:           writeln;       { map linefeed to newline }

         ^M:           write(^Q);     { map return into "<" }

         else          write('<',ord(c),'>');
                                      { print ascii code of all others }
      end;

   end;

end;



(*****************************
 *
 * Function:     askyn(anystring): boolean
 *
 * Description:  Asks a yes/no question and returns true/false
 *               based on the answer.
 *
 * Inputs:       the prompt string
 *
 * Outputs:      TRUE if yes, FALSE if no
 *
 *)

function askyn(prompt: anystring): boolean;
var
   c:  char;

begin

   write(prompt);            { give the prompt }

   repeat
      read(kbd,c);           { wait for a legal answer }
      c := upcase(c);
   until c in ['Y','N'];

   writeln(c);               { echo the answer }

   askyn := (c = 'Y');       { and return TRUE/FALSE }

end;



(*****************************
 *
 * Function:     key_in_segment: boolean
 *
 * Description:  Searches for 'key' in segment number 'segment'.
 *               Returns TRUE if found, otherwise FALSE.
 *
 * Inputs:       segment:offset specify where to search
 *               key is the search string
 *
 * Outputs:      TRUE if key is in membuf at this location
 *               FALSE if not
 *               segment:offset adjusted to point to first byte of
 *               key when key is found.
 *
 *)

function key_in_segment: boolean;
type
   chars     = array[0..bufsize] of char;
                     { memory image of characters }

var
   mem:   chars  absolute membuf;
                     { char array "on top of" membuf string }

   look:  ^chars;    { pointer into memory where we are looking now }

   index: integer;   { index into buffer where key was found }


begin

(* display the current search location once in a while *)
   if (trys mod 64) = 0 then
      write(^M,'Searching location ',hex(segment),':',hex(offset));
   trys := trys + 1;

   look := ptr(segment,offset);    { make a pointer to the memory under test }
   mem := look^;                   { copy this into a string }
   membuf[0] := chr(bufsize);      { set the length of the string }

   index := pos(key,membuf);       { search for the text in this buffer }

   if index > 0 then               { if the key was in this buffer, then
                                     make the text start the current location
                                     and return TRUE to indicate success }
   begin
      change_location(index);
      key_in_segment := true;
   end
   else
      key_in_segment := false;

end;


(*****************************
 *
 * Procedure:    save_text
 *
 * Description:  save the text that the current segment crosses.  This
 *               involves backing up to find the start of the text, then
 *               writing from here to the "end" of text.
 *               The user is given a chance to throw out some text, and
 *               to continue searching after this segment.
 *
 * Inputs:       segment:offset specify the location in the middle of the
 *               text to save
 *
 *               legals is the set of characters that are legal to save
 *
 * Outputs:      segment:offset points to first illegal location after
 *               text is saved.
 *
 *)

procedure save_text;
var
   c:        char;
   name:     anystring;
   fd:       text;

begin

(* see if user wants to save this *)
   write(^G^M,'Searching location ',hex(segment),':',hex(offset));
   writeln(' - Text found!!!',^G);
   writeln;
   display_string(membuf);
   writeln;
   writeln;


(* save the text if wanted *)
   if askyn('Rescue it? (Y/N) ') then
   begin

      (* setup the file for saving *)
      write('Enter filename to save the text into: ');
      readln(name);


      (* look for the start of the text area *)
      writeln;
      write('Searching for text start:');

      repeat
         change_location(-1);              { backup 1 location }
         c := chr(mem[segment:offset]);    { get the char that is here }

      until not (c in legals);       { until an illegal char is found }


      (* write out what's there *)
      writeln;
      writeln('Saving text:');

      assign(fd,name);
      rewrite(fd);

      change_location(1);
      c := chr(mem[segment:offset]);     { get the first char }
      repeat
         write(fd,c);                        { write out this char }
         display_string(c);
         change_location(1);                 { advance to next location }
         c := chr(mem[segment:offset]);      { and get the next char }

      until not (c in legals);           { until an illegal char is found }


      writeln(fd);
      close(fd);

      writeln;
      writeln('Saved.');
      writeln;
   end;



(* see if the user wants to keep searching *)
   if askyn('Search for another match? (Y/N) ')=false then
   begin
      writeln;
      writeln('End of search');
      writeln;
      halt;
   end
   else
      writeln;

end;



begin   {main program}

(* this set specifies the legal characters to save while searching for
   the beginning or the end of a file in memory.   you may want to add
   some additional control characters to this list. *)

   legals := [#27,^I,^J,^M,^@,^W,^B,^U,' '..'~'];

   clrscr;
   writeln;
   writeln('Rescue - The lost text saver            S.H.Smith, 28-Dec-85');
   writeln;

   writeln('This program will find and save a section of memory containing');
   writeln('a keyword string.   This is useful in case of a program');
   writeln('crash, exit without saving, or just for general snoopieness.');
   writeln;
   writeln;

   writeln('Enter the string to search for:');
   write('>');
   readln(key);
   writeln;

   keylen := length(key);


(* walk through memory and look for the search string *)
   segment := 0;
   offset := 0;
   trys := 0;

   repeat

      if key_in_segment then   { look for the keyword at this location }
         save_text;            { and save the text if it's here }

      change_location(bufsize - keylen);
                               { move ahead to the next buffer, leaving
                                 enough buffer overlap to catch text that
                                 crosses a buffer boundary }

   until (segment shr 4) >= $FFE;
                          { keep this up until we land in high memory.
                            the 'shr' allows a simple (unsigned) compare
                            of the segment number }


   writeln;
   writeln;
   writeln('End of search');
   writeln;

end.
