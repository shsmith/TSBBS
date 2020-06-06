
(*
 * openshar.inc - shared mode file handlers
 *
 * This library allows you to open files in the various sharing
 * modes allowed by DOS 3.x under SHARE.
 *
 * (C) 1987 Samuel H. Smith, 20-may-87
 *
 * Thanks to John W. Wulff who documented these procedures!
 *
 * This routine is implemented as a macro (or an inline procedure).
 * This implementation allows you to use any combination of file types
 * without writing a special handler for each file type.
 *
 * Compile with TSHELL 1.2+ (Available from the Tool Shop BBS 602 279 2673)
 *
 *
 * Usage:
 *    OPEN_SHARE(name, fd, function, mode, ok);
 *    if ok then  process-file
 *    else        couldn't open, name=open_file_name
 *
 * Where:
 *    name        is the filename to assign to the file variable
 *                (left behind in open_file_name for error reporting)
 *
 *    fd          is the file variable to open
 *
 *    function    is the open function, one of:
 *                   reset, rewrite, append
 *
 *    mode        is the file sharing mode, composed of:
 *                   allow_xxx+deny_yyy
 *                where xxx is:  read, write, update and
 *                      yyy is:  all, read, write, nothing
 *
 *    ok          is the result status code, on exit:
 *                   true - open was successful
 *                   false - open failed after n tries
 *
 * Revision history
 *    20-may-87 s.h.smith, initial coding
 *
 *    21-may-87 s.h.smith, changed shared modes to deny nothing to other nodes
 *
 *    22-may-86 s.h.smith, changed modes again.  allow and deny fields are now
 *              specified separately.  'append' doesn't work with deny-none.
 *
 *    04-jun-87 s.h.smith, bracketed OPENSHAR body with begin..end so the
 *              macro can be used with the IF statement.
 *
 *    28-Jun-87 s.h.smith, added filename parameter to ease error message
 *              reporting.
 *)

procedure reset_textshare (name:         anystring;
                           var fd:       text;
                           mode:         byte;
                           var okstatus: boolean);
begin                     
   open_file_name := name;                                      
   FileMode := mode;
   open_try_count := 0;                                        
   okstatus := false;
   assign (fd,open_file_name);
   while (open_try_count < retry_count) and (ok = false) do
   begin                                                       
      {$i-} reset(fd); {$i+}
      if ioresult = 0 then                                     
         ok := true
      else                                                     
         inc(open_try_count);                                 
   end;    
   FileMode := default_mode;                             
end;


(* ------------------------------------------------------------ *)
procedure share_append (name:         anystring;
                        var fd:       text);
   (* append a file in shared mode; create the file if needed *)
begin                     
   open_file_name := name;                                      
   FileMode := share_update;
   open_try_count := 0;                                        
   ok := false;
   assign (fd,open_file_name);
   while (open_try_count < retry_count) and (ok = false) do
   begin                                                       
      {$i-} append(fd); {$i+}
      if ioresult = 0 then                                     
         ok := true
      else                                                     
         inc(open_try_count);                                 
   end;    

   FileMode := default_mode;                             
  
  if not ok then
   begin
      {$i-} rewrite(fd); {$i+}
      ok := ioresult = 0;
   end;
end;

