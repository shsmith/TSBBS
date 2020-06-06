
(*
 * Example of character and enumeration subrange types
 *)
 
program Scaler_Operations;

type 
     Days = (Mon,Tue,Wed,Thu,Fri,Sat,Sun);
     Work = Mon..Fri;
     Rest = Sat..Sun;

var  
     Day      : Days; (* This is any day of the week *)
     Workday  : Work; (* These are the the working days *)
     Weekend  : Rest; (* The two weekend days only *)
     Index    : 1..12;
     Alphabet : 'a'..'z';
     Start    : 'a'..'e';

begin  (* main program *)
   Workday := Tue;
   Weekend := Sat;
   Day := Workday;
   Day := Weekend;
   Index := 3+2*2;
   Start := 'd';
   Alphabet := Start;
                             (* since Alphabet is "d"    *)
   Start := Succ(Alphabet);  (* Start will be 'e'        *)
   Start := Pred(Alphabet);  (* Start will be 'c'        *)
   Day := Wed;
   Day := Succ(Day);  (* Day will now be 'Thu' *)
   Day := Succ(Day);  (* Day will now be 'Fri' *)
   Index := Ord(Day); (* Index will be 4 (Fri = 4) *)
end. (* of main program *)
