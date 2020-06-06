
(*
 * utility - general utility functions
 *
 * S.H.Smith, 6-May-86
 *
 *)


procedure error(message: anystring);
                             {terminate parse with an error message}
begin
   writeln;
   writeln;
   writeln('Error: ',message);
   halt;
end;


procedure assert(condition:  boolean;
                 message:    anystring);
                             {exit with error message is assertion
                              condition is not true}
begin
   if condition = false then
      error('Assertion failed: '+message);

   if trace then
      writeln('Valid assertion: '+message);

   flush(output);
end;


function new_element: element;
                             {allocate a new element node and return
                              a pointer to it}
var
   el:  element;
   i:   integer;
begin
   new(el);

   with el^ do
   begin
      ident := '';
      eltype := unknown;
      parcount := 0;
      next := nil;
      for i := 1 to maxpar do
         par[i] := nil;
   end;

   new_element := el;
end;


procedure dispose_element(var el: element);
                             {dispose of the memory used by an element node}

var
   i:  integer;

begin
   if el <> nil then
   begin
      for i := 1 to el^.parcount do
         dispose_element(el^.par[i]);

      dispose_element(el^.next);
      dispose(el);
      el := nil;
   end;
end;


