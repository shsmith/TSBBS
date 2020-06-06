
unit debugs;   {debugging support unit}

interface

uses dos;

type
   textptr = ^text;

var
   debugfd:    textptr;    {debugging output file}

   debugging:  boolean;    {true while debugging}

implementation

begin
   debugfd := @output;
   debugging := getenv('PRODEBUG') = 'ON';
end.

