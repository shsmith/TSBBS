


(* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  PXG.INC - Include file used by all experts generated
 *  by the Pascal Expert Generator.
 *
 *
 *  4-Oct-85 S.H.Smith
 *
 *)

type
   anystring = string[80];



(* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * ask a yes/no question
 *
 * returns true if the answer is yes
 *
 *)

function ask(question: anystring): boolean;
var
   answer: char;

begin
   repeat
      write(question,' (Y/N) ');

      read(kbd,answer);
      answer := upcase(answer);
      writeln(answer);

      if not (answer in ['Y','N']) then
         writeln('Please answer the question!');

   until answer in ['Y','N'];

   ask := (answer = 'Y');
end;



(* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * make a conclusion
 *
 *)

procedure conclude(conc: anystring);
begin
   writeln;
   writeln('Conclusion: ',conc);
   writeln;
end;

