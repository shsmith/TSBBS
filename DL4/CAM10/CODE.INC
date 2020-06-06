

(*
 * code - emit code file
 *
 * S.H.Smith, 6-May-86
 *
 *)


procedure code_newline;     {generate a newline}

begin
   writeln;
   flush(output);
end;


procedure code_string (str:     anystring);
                           {generate a string of characters}

begin

   if str [1]= '"' then
      write(copy (str, 2, length (str)- 2))
   else
      write(str);

end;



