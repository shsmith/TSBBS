
(*
 * Example of tpas4.0 WORD data type
 *)
 
program Get_Time_And_Date;           

uses Dos;

var 
    Year,Month,Day,Weekday        : word;
    Hour,Minute,Second,Hundredths : word;

begin
   GetTime(Hour, Minute, Second, Hundredths);
   GetDate(Year, Month, Day, Weekday);
   Writeln('The date is ',Month:2,'/',Day:2,'/',Year);
   Writeln('The time is ',Hour:2,':',Minute:2,':',Second:2);
end.
