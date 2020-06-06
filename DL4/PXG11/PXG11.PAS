

(* -------------------------------------------------------
 *
 *   PXG - A Pascal Expert Generator
 *
 *   By Samuel H. Smith,  Public Domain Material
 *
 *   Version 1.0, 4-Oct-85
 *      Initial public domain release
 *
 *   Version 1.1, 6-Oct-85
 *      This version uses a new, more compact format for .KDB files
 *      and is not compatible with old .KDB files.
 *
 *)

{$D-,U+,R+}


program pascal_expert_generator;

type
   anystring = string[80];

   treeptr = ^tree;           {this is the basic structure of the}
   tree = record              {knowledge base tree}

      question:   anystring;      {question to ask at this node in the tree}
      ifyes:      treeptr;           {subtree if answer is yes}
      ifno:       treeptr;           {subtree if answer is no}

      conclusion: anystring;      {conclusion if there is no question}

   end;



var
   title:  anystring;    {the title of the current knowledge base}

   root:   treeptr;      {the root of the knowledge tree}

   fd:     text[1024];   {file for read/write tree to disk}

   line:   anystring;    {a working line buffer}

   saved:  boolean;      {has the current knowledge base been saved?}



(* -------------------------------------------------------
 *
 *   ask a yes/no question
 *
 *   returns true if the answer is yes
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



(* -------------------------------------------------------
 *
 *   make a conclusion
 *
 *)

procedure conclude(conc: anystring);
begin
   writeln;
   writeln('Conclusion: ',conc);
   writeln;
end;



(* -------------------------------------------------------
 *
 *   learn a new rule
 *
 *   entered when an incorrect conclusion is drawn
 *   moves the current conclusion down the 'no' branch of the tree
 *   makes a new question and moves it's conclusion down the 'yes' branch
 *
 *)

procedure learn(var node: treeptr);
var
   temptree: treeptr;

begin
   saved := false;

   with node^ do
   begin
      new(ifno);       {initialize the new subtrees}
      with ifno^ do
      begin
         ifyes      := nil;
         ifno       := nil;
         question   := node^.question;    {the ifno subtree inherits the}
         conclusion := node^.conclusion;  {question and conclusion that}
      end;                                {used to be at this node}

      new(ifyes);
      with ifyes^ do
      begin
         ifyes      := nil;
         ifno       := nil;
         question   := '';
      end;


      {now gather the information needed to enter a new question and
       conclusion into the tree}

      writeln;
      writeln('Please enter the correct conclusion:');
      write('> ');
      readln(conclusion);
      ifyes^.conclusion := conclusion;

      repeat
         writeln;
         writeln('Please enter a new question.  Phrase the question');
         writeln('so that when answered "yes" it gives the conclusion: ');
         writeln('   ',ifyes^.conclusion);
         writeln('and that when answered "no" gives the conclusion:');
         writeln('   ',ifno^.conclusion);

         writeln;
         writeln('Enter "X" to exchange the "yes" and "no" conclusions,');
         writeln('otherwise enter the actual question.');
         write('> ');
         readln(question);
         question[1] := upcase(question[1]);
         writeln;

         if question = 'X' then
         begin
            temptree := ifno;
            ifno := ifyes;
            ifyes := temptree;
         end;

      until question <> 'X';
   end;
end;



(* -------------------------------------------------------
 *
 *   solve a problem with a knowledge tree
 *
 *   makes a conclusion if there is no question in the current node.
 *   otherwise, it asks the question and then tries to solve
 *   the remaining subtree.
 *   will learn a new fact if an incorrect conclusion is drawn.
 *
 *)

procedure solvetree(node: treeptr);
begin
   with node^ do
   begin
      if question <> '' then   {ask the question if there is one}
      begin
         if ask(question) then
            solvetree(ifyes)      {decide which branch of the tree}
         else                     {to solve based on the answer}
            solvetree(ifno);
      end
      else

      begin           {there is no question; just make a conclusion}
         conclude(conclusion);

         if ask('Is this the right conclusion?') = false then
            learn(node);
      end;

   end;
end;



(* -------------------------------------------------------
 *
 *   list all of the knowledge contained in a knowledge tree
 *
 *)

procedure disptree(level: integer;  node: treeptr);
begin
   with node^ do
   begin
      if question <> '' then
      begin
         writeln('':level,'If ''',question,''' is true:');
         disptree(level+3,ifyes);

         writeln;
         writeln('':level,'If ''',question,''' is false:');
         disptree(level+3,ifno);
      end
      else
         writeln('':level,conclusion)
   end;
end;



(* -------------------------------------------------------
 *
 *   write a node in the knowledge tree to a file
 *
 *)

procedure writenode(level: integer; node: treeptr);
begin
   with node^ do
   begin
      if question <> '' then
      begin
         writeln(fd,'Q:',question);
         write(fd,'':level,'Y');
         writenode(level+1,ifyes);

         write(fd,'':level,'N');
         writenode(level+1,ifno);
      end
      else
         writeln(fd,'C:',conclusion);
   end;
end;



(* -------------------------------------------------------
 *
 *   write the entire knowledge tree to a file
 *
 *)

procedure writetree;
begin
   write('Enter the name of the file to write to [.KDB]: ');
   readln(line);
   if line = '' then
      exit;

   if pos('.',line) = 0 then
      line := line + '.KDB';

   assign(fd,line);

{$I-}
   rewrite(fd);
   writeln(fd,title);
   writenode(0,root);
   close(fd);

   if ioresult <> 0 then
      writeln('Error writing file!')
   else
      saved := true;
{$I+}

end;



(* -------------------------------------------------------
 *
 *   read a node of the knowledge tree from a file
 *   and verify that the file is valid
 *
 *)

procedure readnode(node: treeptr);
var
   c: char;

   procedure expect(message: anystring);
   begin
      repeat
         read(fd,c);
      until c <> ' ';

      if c <> message then
         writeln('"',message,'" expected, "',c,'" found.');
   end;

begin
   with node^ do
   begin

      read(fd,c);
      if c = 'Q' then
      begin
         conclusion := '';
         expect(':');
         readln(fd,question);

         expect('Y');
         new(ifyes);
         readnode(ifyes);

         expect('N');
         new(ifno);
         readnode(ifno);
      end
      else

      begin
         if c <> 'C' then
            writeln('"C" expected, "',c,'" found.');

         expect(':');
         readln(fd,conclusion);
      end;
   end;
end;



(* -------------------------------------------------------
 *
 *   read a new knowledge tree from a file
 *
 *)

procedure readtree;
begin

   {if there is anything in the current knowledge tree, then see if}
   {the user wants to save it}

   if not saved then
      if ask('Do you want to save the current knowledge base?') then
         writetree;

   write('Enter the name of the file to read from [.KDB]: ');
   readln(line);
   if line = '' then
      exit;

   if pos('.',line) = 0 then
      line := line + '.KDB';

   assign(fd,line);

{$I-}
   reset(fd);
   if ioresult <> 0 then
      writeln('File not found!')
   else

   begin
      readln(fd,title);
      readnode(root);
      close(fd);
   end;

   if ioresult <> 0 then
      writeln('Error reading file!');
{$I+}

   saved := true;

end;




(* -------------------------------------------------------
 *
 *   generate a program fragment for the current node in the knowledge tree
 *
 *)

procedure prognode(level: integer;  node: treeptr);
begin
   with node^ do
   begin
      if question <> '' then
      begin
         writeln(fd,'':level,'if ask(''',question,''') = true then');
         prognode(level+3,ifyes);

         writeln(fd);
         writeln(fd,'':level,'else    {',question,' = false}');
         prognode(level+3,ifno);
      end
      else
         writeln(fd,'':level,'conclude(''',conclusion,''')');
   end;
end;



(* -------------------------------------------------------
 *
 *   generate a program to walk the knowledge tree
 *
 *)

procedure progtree;
begin
   write('Enter the name of the file to save the program in [.PAS]: ');
   readln(line);
   if line = '' then
      exit;

   if pos('.',line) = 0 then
      line := line + '.PAS';

   assign(fd,line);

{$I-}
   reset(fd);
{$I+}

   if ioresult = 0 then
   begin
      close(fd);
      if ask('The file '+line+' exists!   Overwrite it?') = false then
         exit;
   end;

{$I-}
   rewrite(fd);
   writeln(fd);
   writeln(fd,'{Expert program ',line,' generated by PXG}');
   writeln(fd);
   writeln(fd,'{$I PXG.INC}');
   writeln(fd);
   writeln(fd,'begin');
   writeln(fd,'   repeat');
   writeln(fd,'      writeln;');
   writeln(fd,'      writeln(''',title,''');');
   writeln(fd,'      writeln;');
   writeln(fd);
   prognode(6,root);
   writeln(fd);
   writeln(fd,'   until ask(''Run again?'') = false;');
   writeln(fd,'end.');
   close(fd);

   if ioresult <> 0 then
      writeln('Error writing file!')
   else

   begin
      writeln;
      writeln('Use Turbo Pascal to compile ',line);
      writeln;
   end;

{$I+}

end;



(* -------------------------------------------------------
 *
 *   initialize a new knowledge tree
 *
 *)

procedure inittree;
begin
   new(root);
   with root^ do
   begin
      ifyes      := nil;
      ifno       := nil;
      question   := '';
      conclusion := 'No conclusion';
   end;

   saved := true;
   title := 'Default knowledge base';

end;



(* -------------------------------------------------------
 *
 *   initialize a new knowledge tree
 *
 *)

procedure newtree;
begin

   {if there is anything in the current knowledge tree, then see if}
   {the user wants to save it}

   if not saved then
      if ask('Do you want to save the current knowledge base?') then
         writetree;

   writeln('Enter the title of the new expert:');
   write('> ');
   readln(title);

end;



(* -------------------------------------------------------
 *
 *   help - give some help
 *
 *)

procedure help;
begin
   clrscr;
   writeln;
   writeln('PXG - A Pascal Expert Generator');
   writeln;
   writeln('This program allows you to prepare a set of rules for a');
   writeln('decision-tree based expert system.');
   writeln;
   writeln('You teach the expert by repeatedly "Learning" new facts. ');
   writeln('When you have your rules working properly, you can generate ');
   writeln('a stand-alone expert program in turbo pascal!');
   writeln;
   writeln('Actions:');
   writeln('   New          Create a new knowledge base');
   writeln('   Read         Read a knowledge base from a disk file');
   writeln('   Write        Write the current knowledge base to a file');
   writeln('   Display      Display the rules in the current knowledge base');
   writeln('   Program      Generate an expert program from this knowledge base');
   writeln('   Learn        Test this knowledge base and learn new rules');
   writeln('   Quit         Exit to the system');
   writeln;

end;



(* -------------------------------------------------------
 *
 *   main program
 *   select expert commands and process them
 *
 *)

var
   command:  char;

begin
   clrscr;
   writeln;
   writeln('PXG - A Pascal Expert Generator');
   writeln;
   writeln('This program allows you to prepare a set of rules for a');
   writeln('decision-tree based expert system.');
   writeln;
   writeln('You teach the expert by repeatedly "Learning" new facts. ');
   writeln('When you have your rules working properly, you can generate ');
   writeln('a stand-alone expert program in turbo pascal!');
   writeln;
   writeln('By Samuel H. Smith,  Public Domain Material');
   writeln('Version 1.1, 6-Oct-85');

   sound(3000);
   delay(100);
   nosound;

   delay(3000);
   help;

   inittree;

   repeat
      writeln;
      writeln('Working on:');
      writeln('   ',title);
      writeln;
      write('Action:  New, Read, Write, Display, Program, Learn, Quit, ?: ');

      read(kbd,command);
      command := upcase(command);
      writeln(command);
      writeln;

      case command of
         'N':  newtree;
         'R':  readtree;
         'W':  writetree;
         'D':  disptree(3,root);
         'P':  progtree;
         'L':  solvetree(root);
         '?':  help;
         'Q':  ;

         else  writeln('What?   Type "?" for help.');
      end;

   until command = 'Q';


   {if there is anything in the current knowledge tree, then see if}
   {the user wants to save it}

   if not saved then
      if ask('Do you want to save the current knowledge base?') then
         writetree;

   writeln('Goodbye.');
end.

