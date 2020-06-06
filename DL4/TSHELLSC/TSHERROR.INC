
#log Error reporting 1.1

(*------------------------------------------
 *
 * error - report errors detected in source
 *
 *)

procedure error(message: longstring);
begin

   writeln(con);
   writeln(con,^G,whoami,':  ',message);
   writeln(con,'Source:  ',line_txt);
   writeln(con);

#ifndef STAND_ALONE
   log_message(whoami+':  '+message);
   log_message('Source:  '+line_txt);
#endif

   INCR(error_count);

end;
