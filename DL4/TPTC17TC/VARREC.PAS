
(*
 * Examples of variant record types
 *)
 
program Variant_Record_Example;

type 
     Kind_Of_Vehicle = (Car,Truck,Bicycle,Boat);

     Vehicle = record
       Owner_Name   : string[25];
       Gross_Weight : integer;
       Value        : real;
       case What_Kind : Kind_Of_Vehicle of
         Car     : (Wheels : integer;
                    Engine : string[8]);
         Truck   : (Motor  : string[8];
                    Tires  : integer;
                    Payload : integer);
         Bicycle : (Tyres   : integer);
         Boat    : (Prop_Blades : byte;
                    Sail    : boolean;
                    Power   : string[8]);
       end; (* of record *)

var 
    Sunfish,Ford,Schwinn,Mac : Vehicle;

begin  (* main program *)
   Ford.Owner_Name := 'Walter'; (* fields defined in order *)
   Ford.Gross_Weight := 5750;
   Ford.Value := 2595.00;
   Ford.What_Kind := Truck;
   Ford.Motor := 'V8';
   Ford.Tires := 18;
   Ford.Payload := 12000;

   with Sunfish do begin
      What_Kind := Boat; (* fields defined in random order *)
      Sail := TRUE;
      Prop_Blades := 3;
      Power := 'wind';
      Gross_Weight := 375;
      Value := 1300.00;
      Owner_Name := 'Herman and George';
   end;

   Ford.Engine := 'flathead';  (* tag-field not defined yet but it *)
   Ford.What_Kind := Car;      (* must be before it can be used    *)
   Ford.Wheels := 4;
      (* notice that the non variant part is not redefined here *)

   Mac := Sunfish; (* entire record copied, including the tag-field *)

   if Ford.What_Kind = Car then        (* this should print *)
      Writeln(Ford.Owner_Name,' owns the car with a ',Ford.Engine,
              ' engine');

   if Sunfish.What_Kind = Bicycle then  (* this should not print *)
      Writeln('The sunfish is a bicycle which it shouldn''t be');

   if Mac.What_Kind = Boat then         (* this should print *)
      Writeln('The mac is now a boat with',Mac.Prop_Blades:2,
               ' propeller blades.');
end.  (* of main program *)
