
(*
 * cninfrpt - format output of cninfo
 * s.h.smith, 22-sep-93
 *
 *)

uses tools;

const
   maxnetwork = 65;

type
   netrec = record
      id:      string;
      confs:   integer;
      totals:  longint;
      posts:   longint;
      imports: longint;
   end;

(* --------------------------------------------------------- *)
function insert_commas(s: string): string;
var
   i: integer;
begin
   i := length(s);
   while i > 3 do
   begin
      dec(i,3);
      insert(',',s,i+1);
   end;

   insert_commas := s;
end;


(* --------------------------------------------------------- *)
function itoa (n: longint): string;
var
   tstr:          string;

begin
   str(n, tstr);
   itoa := insert_commas(tstr);
end;


(* --------------------------------------------------------- *)
var
   net:        array[1..maxnetwork] of netrec;
   netcount:   integer;
   totconfs:   integer;
   tottotals:  longint;
   totposts:   longint;
   totimports: longint;
   line:       string;

(* --------------------------------------------------------- *)
   procedure net_summary;
   begin
      if netcount > 0 then
      begin
         writeln('':35,'   ---------  ---------  ---------');
         writeln('TOTALS FOR '+net[netcount].id:35,
                  itoa(net[netcount].totals):11,
                  itoa(net[netcount].posts):11,
                  itoa(net[netcount].imports):11);
         inc(totconfs,net[netcount].confs);
         inc(tottotals,net[netcount].totals);
         inc(totposts,net[netcount].posts);
         inc(totimports,net[netcount].imports);
      end;
      writeln;

      inc(netcount);
      net[netcount].confs := 0;
      net[netcount].totals := 0;
      net[netcount].posts := 0;
      net[netcount].imports := 0;
   end;

(* --------------------------------------------------------- *)
   procedure overall_summary;
   var
      i: integer;
   begin
      writeln;
      writeln('                  Overall Summary of Available Message Networks');
      writeln;
      writeln('          Network          Number of      Active      Messages     Messages');
      writeln('            Name          Conferences    Messages      Posted      Imported');
      writeln('    --------------------  -----------  -----------  -----------  -----------');
      for i := 1 to netcount-1 do
         writeln('     ',net[i].id,'':18-length(net[i].id),
               itoa(net[i].confs):13,
               itoa(net[i].totals):13,
               itoa(net[i].posts):13,
               itoa(net[i].imports):13);

      writeln('                          -----------  -----------  -----------  -----------');
      writeln('            GRAND TOTALS',
                  itoa(totconfs):12,
                  itoa(tottotals):13,
                  itoa(totposts):13,
                  itoa(totimports):13);
   end;

(* --------------------------------------------------------- *)
   procedure upd_summary;
   begin
      inc(net[netcount].confs);
      inc(net[netcount].totals,atol(copy(line,31,8)));
      inc(net[netcount].posts,atol(copy(line,41,8)));
      inc(net[netcount].imports,atol(copy(line,51,8)));
   end;

(* --------------------------------------------------------- *)
begin
   totconfs := 0;
   tottotals := 0;
   totposts := 0;
   totimports := 0;
   netcount := 0;

   while not eof do
   begin
      readln(line);

      if pos(':',line) > 0 then
      begin
         net_summary;

         writeln(line);
         net[netcount].id := copy(line,1,length(line)-1);

         writeln('   Conf.    Conference      High Msg    Active    Messages   Messages');
         writeln('     #         Name          Number    Messages    Posted    Imported');
         writeln('   -----   -------------   ---------  ---------  ---------  ---------');
      end
      else

      if line <> '' then
      begin
         writeln('   ',
                  copy(line,1,4),'    ',
                  copy(line,5,14),
                  itoa(atol(copy(line,21,8))):10,
                  itoa(atol(copy(line,31,8))):11,
                  itoa(atol(copy(line,41,8))):11,
                  itoa(atol(copy(line,51,8))):11);
         upd_summary;
      end;
   end;

   net_summary;
   overall_summary;

end.

