
const
   lowend = 100;
   highend = 200;
type
   anystring = string[80];
   myint = integer;
   myarray = array[1..100] of real;
   range1 = 100..200;
   range2 = lowend..highend;
   set1 = set of char;
   set2 = set of 'a'..'z';
   set3 = set of byte;
   
const
   r1:  range1 = 150;
   st1: anystring = 'Hello';
   se1: set1 = ['a'..'f'];
   
var
   str1: string[80];
   str2: anystring;
   in1:  integer;
   in2:  myint;
   in3:  integer absolute in1;
   in4:  byte absolute str1;
   in5:  anystring absolute cseg:$80;
   
   ar1:  array[1..100] of real;
   ar2:  myarray;
   ar3:  array[100..200] of byte;
   ar4:  array[lowend..highend] of byte;
   ar5:  array[range1] of byte;
   ar6:  array[range2] of byte;

begin
   str1 := 'hello';
   str2 := 'hello2';
   str1[1] := 'H';
   str2[1] := 'H';
   in1 := 1;
   in2 := 1;
   ar1[1] := 1;
   ar2[1] := 1;
   if in5[1] <> '-' then writeln('tail=',in5);
   writeln(str1,str2,str1[1],str2[1],in1,in2,ar1[1],ar2[2]);
   writeln(ar3[101],ar4[101],ar5[101],ar6[101]);
end.
