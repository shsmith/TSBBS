
(*
 * afiles - find all files in a subdirectory tree
 *
 * Author: S.H.Smith, 5-Apr-86
 *
 *)

uses DOS;

{$r+,s+}

{$I treelib.inc  Utility to create and format visual trees}

const
   version = 'afiles v2.0  (S.H.Smith, 11-29-88)';

type
   anystring = string[65];

var
   allfiles:  boolean;


(*
 * get_sub_directories - recursively get all subdirectories for a given
 *                       path and put them into a given node record
 *
 *)

procedure get_sub_directories (path:       anystring;
                               var node:   node_ptr);
var
   reg:      registers;
   dta:      string[255];
   pattern:  anystring;
   filename: anystring;
   cf:       byte;
   c:        char;
   i:        integer;
   isadir:   array [subnode_index] of boolean;
   dirbit:   boolean;

begin
   reg.ax := $1a00;
   reg.ds := seg (dta [1]);
   reg.dx := ofs (dta [1]);
   msdos(reg);              {set dta address}

   pattern := path + '*.*' + #0;
   reg.ax := $4e00;
   reg.cx := $37;           {match any file attribute but volume label}
   reg.ds := seg (pattern [1]);
   reg.dx := ofs (pattern [1]);
   msdos(reg);              {find first subdirectory}

   cf := reg.flags and 1;

   while (cf <> 1) and (node^.count < maxsubs) do
   begin
      filename := '';
      i := 0;

      repeat
         c := dta [31 + i];        {build up filename from dta buffer}
         if c <> #0 then
            filename := filename + c;

         i := i + 1;
      until c = #0;

      if filename[1] = '.' then
         filename := '';            {exclude . and .. from listing}

      dirbit := (ord(dta [22]) and $10) <> 0;

      if filename <> '' then
      with node^ do                 {add filename to the node, if ok}
      begin
         if count = 0 then
            new(subs);

         count := count + 1;
         subs^[count] := new_node;
         isadir[count] := dirbit;

         if dirbit then
            subs^[count]^.name := filename + '\'
         else
            subs^[count]^.name := filename;
      end;

      reg.ax := $4f00;
      reg.ds := seg (dta [1]);
      reg.dx := ofs (dta [1]);
      msdos(reg);              {keep searching for next file}

      cf := reg.flags and 1;
   end;

   if cf = 0 then
      writeln('warning:  more than ',maxsubs,' entries in ',path);


   with node^ do        {find the subdirectories for each of the
                         directories found in this node}

      for i := 1 to count do
         if isadir[i] then
            get_sub_directories(path + subs^[i]^.name, subs^[i])
         else
            writeln(path + subs^[i]^.name);

   sort_node(node);

end;                     {subdirs}



(*
 * dotree - build and output the tree for a given path
 *
 *)

procedure dotree(path:  anystring);
var
   root:  node_ptr;
   i:     integer;

begin

(* make the path all upper case.  make sure it always ends with '\' *)

   for i := 1 to length(path) do
      path[i] := upcase(path[i]);

   if path[length(path)] <> '\' then
      path := path + '\';


(* create a new (empty) tree structure *)

   root := new_node;
   root^.name := path;


(* scan all subdirectories and build them into the tree *)

   get_sub_directories(path, root);

end;



(*
 * print program usage instructions
 *
 *)

procedure usage;
begin
   writeln;
   writeln(version);
   writeln;
   writeln('Usage:    afiles DIRECTORY_PATH >FILE_LIST');
   writeln;
   writeln('Example:  afiles \shs\proj | tar c a:backup -f');
   halt;
end;



(*
 * main program
 *
 *)

var
   i: integer;

begin
   if paramcount < 1 then
      usage;

(* process the specified paths *)

   for i := 1 to paramcount do
      dotree(paramstr(i));
end.

