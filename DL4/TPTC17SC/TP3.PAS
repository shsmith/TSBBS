
(* 
 * Extra identifiers needed when translating tpas3.0 sources
 *
 * Add the line "uses tp3;" to Turbo Pascal 3.0 programs to gain
 * access to these definitions.
 *
 * (C) 1988 Samuel H. Smith
 *
 *)

unit tp3;

interface

   procedure Mark(ptr: pointer);
   procedure Release(ptr: pointer);

   procedure MsDos(var reg);
   procedure Intr(fun: integer; var reg);

   function WhereX: integer;
   function WhereY: integer;
   function KeyPressed: boolean;

   procedure GotoXY(x,y: integer);
   procedure Window(x1,y1,x2,y2);
   procedure TextColor(fg: integer);
   procedure TextBackground(bg: integer);
   procedure ClrScr;
   procedure ClrEol;

   function ptr(s,o: word): pointer;

   procedure blockread(var fd: file; var buf; blocks: word; var stat: word);
   procedure blockwrite(var fd: file; var buf; blocks: word; var stat: word);
   function filepos(var fd: file): integer;
   function filesize(var fd: file): integer;
   function sizeof(rec: byte{anytype}): integer;


   var
      Lst:     text;
      Con:     text;
      Kbd:     text;
      

implementation

   function KeyPressed: boolean;
   begin
\     return kbhit();
   end;   


begin
   assign(lst,'prn');
   rewrite(lst);

   assign(con,'con');
   rewrite(con);

   assign(kbd,'con');
   reset(kbd);
end.

