(*
 * Examples of pointer manipulation
 *
 *)

program Pointer_Use_Example;

type 
    Name  = string[20];

var  
    My_Name : ^Name; (* My_Name is a pointer to a string[20] *)
    My_Age  : ^integer;  (* My_Age is a pointer to an integer *)

begin
   New(My_Name);
   New(My_Age);

   My_Name^ := 'John Q Doe';
   My_Age^ := 27;

   Writeln('My name is ',My_Name^);
   Writeln('My age is ',My_Age^:3);

   Dispose(My_Name);
   Dispose(My_Age);
end.
