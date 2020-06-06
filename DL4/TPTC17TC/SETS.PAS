
(*
 * Examples of set manipulation
 *
 *)
 
program Define_Some_Sets;

type 
    Goodies = (Ice_Cream,Whipped_Cream,Banana,Nuts,Cherry,
                Choc_Syrup,Strawberries,Caramel,Soda_Water,
                Salt,Pepper,Cone,Straw,Spoon,Stick);

     Treat = set of Goodies;

var  
     Sundae         : Treat;
     Banana_Split   : Treat;
     Soda           : Treat;
     Ice_Cream_Cone : Treat;
     Nutty_Buddy    : Treat;
     Mixed          : Treat;
     Index          : byte;

begin
                (* define all ingredients used in each treat *)
   Ice_Cream_Cone := [Ice_Cream,Cone];
   Soda := [Straw,Soda_Water,Ice_Cream,Cherry];
   Banana_Split := [Ice_Cream..Caramel];
   Banana_Split := Banana_Split + [Spoon];
   Nutty_Buddy := [Cone,Ice_Cream,Choc_Syrup,Nuts];
   Sundae := [Ice_Cream,Whipped_Cream,Nuts,Cherry,Choc_Syrup,
              Spoon];

                 (* combine for a list of all ingredients used *)

   Mixed := Ice_Cream_Cone + Soda + Banana_Split + Nutty_Buddy +
            Sundae;
   Mixed := [Ice_Cream..Stick] - Mixed; (* all ingredients not used *)

   if Ice_Cream     in Mixed then Writeln('Ice cream not used');
   if Whipped_Cream in Mixed then Writeln('Whipped cream not used');
   if Banana        in Mixed then Writeln('Bananas not used');
   if Nuts          in Mixed then Writeln('Nuts are not used');
   if Cherry        in Mixed then Writeln('Cherrys not used');
   if Choc_Syrup    in Mixed then Writeln('Chocolate syrup not used');
   if Strawberries  in Mixed then Writeln('Strawberries not used');
   if Caramel       in Mixed then Writeln('Caramel is not used');
   if Soda_Water    in Mixed then Writeln('Soda water is not used');
   if Salt          in Mixed then Writeln('Salt not used');
   if Pepper        in Mixed then Writeln('Pepper not used');
   if Cone          in Mixed then Writeln('Cone not used');
   if Straw         in Mixed then Writeln('Straw not used');
   if Spoon         in Mixed then Writeln('Spoon not used');
   if Stick         in Mixed then Writeln('Stick not used');
end.
