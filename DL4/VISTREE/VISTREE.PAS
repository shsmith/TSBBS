
(*
 * vistree - visual directory tree
 *
 * Author: S.H.Smith, 5-Apr-86
 *
 * This program will display your directory layout as a visual "tree"
 * structure.   VisTree does not use the "partial tree" format found
 * in most other programs of this kind.
 *
 * This program may be freely used and copied, provided it is never
 * sold or otherwise used for profit.
 *
 *)

{$P1024,D-}


{$I \shs\tools\treelib.inc  Utility to create and format visual trees}

{$I \shs\tools\regpack.inc  MSDOS register package declaration}


const
   version = 'VisTree v1.3  (S.H.Smith, 08-Sep-86)';

type
   anystring = string[65];

   inforec = record
                isadir: boolean;
                day:    byte;
                month:  byte;
                year:   byte;
             end;
var
   allfiles:     boolean;
   alldates:     boolean;
   locatenewest: boolean;
   locateoldest: boolean;



(*
 * isnewer - determine if date 1 is newer than date 2
 *
 *)

function isnewer(f1,f2: inforec): boolean;
begin
   isnewer := false;

   if f1.year > f2.year then
      isnewer := true
   else
   if f1.year = f2.year then
      if f1.month > f2.month then
         isnewer := true
      else
      if f1.month = f2.month then
         if f1.day > f2.day then
            isnewer := true;
end;


(*
 * add_date_to - format the date in info and add it to the end of
 *               the given name
 *)

procedure add_date_to( var name: name_string;
                       info:     inforec);

   function format(n: integer): anystring;
   var
      s: anystring;
   begin
      str(n,s);
      if length(s) = 1 then s := '0'+s;
      format := s;
   end;

begin
   with info do
      name := format(year)+'/'+format(month)+'/'+format(day)+'-'+name;
end;


(*
 * get_sub_directories - recursively get all subdirectories for a given
 *                       path and put them into a given node record
 *
 *)

procedure get_sub_directories (path:       anystring;  {the directory path}
                               var node:   node_ptr;   {tree node for entries}
                               var newest: inforec);   {newest entry in subdir}
var
   reg:      regpack;
   dta:      string[255];
   pattern:  anystring;
   filename: anystring;
   isadir:   array [subnode_index] of boolean;
   info:     array [subnode_index] of inforec;
   fdate:    inforec;
   cf:       byte;
   c:        char;
   i:        integer;
   dirbit:   boolean;

begin
   write(con,path);         {show what's happening on screen}

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

      dirbit := (ord(dta [22]) and $10) <> 0;
                            {is this a directory?}

      if filename[1] = '.' then
         filename := '';    {exclude . and .. from listing}

      if dirbit=false then
         if allfiles=false then
            filename := '';    {exclude non-directories, if wanted}

      with fdate do         {fill in all file information}
      begin
         year := (ord(dta[26]) shr 1) + 80;
         month := (ord(dta[25]) shr 5)+ ((ord(dta[26]) and 1) shl 3);
         day := ord(dta[25]) and 31;
      end;

      if dirbit = true then
      with fdate do
      begin
         if locatenewest then
         begin
            year := 80;
            month := 0;
            day := 0;
         end
         else

         if locateoldest then
         begin
            year := 99;
            month := 12;
            day := 31;
         end;
      end;

      if locatenewest then
         if isnewer(fdate,newest) then
            newest := fdate;

      if locateoldest then              {if looking for oldest files}
         if isnewer(newest,fdate) then
            newest := fdate;


      if filename <> '' then
      with node^ do                 {add filename to the node, if ok}
      begin
         if count = 0 then
            new(subs);

         count := count + 1;
         isadir[count] := dirbit;
         info[count] := fdate;
         subs^[count] := new_node;

         if dirbit then                            {if a directory then add}
            filename := filename + '\';            {the trailing "\"}

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

   write(con,#13);
   clreol;


   with node^ do        {find the subdirectories for each of the
                         directories found in this node}
      for i := 1 to count do
      begin
         if isadir[i] then
            get_sub_directories(path + subs^[i]^.name, subs^[i], info[i]);


         if alldates then
         begin
            if locatenewest then
               if isnewer(info[i],newest) then
                  newest := info[i];

            if locateoldest then
               if isnewer(newest,info[i]) then
                  newest := info[i];

            add_date_to(subs^[i]^.name, info[i]);
         end;
      end;

   sort_node(node);      {sort the names in this node (can be done only
                          after 'fileinfo' is no longer needed)}

end;                     {subdirs}



(*
 * dotree - build and output the tree for a given path
 *
 *)

procedure dotree(path:  anystring);
var
   root:  node_ptr;
   i:     integer;
   newest:inforec;

begin
   writeln;
   flush(output);


(* make the path all upper case.  make sure it always ends with '\' *)

   for i := 1 to length(path) do
      path[i] := upcase(path[i]);

   if path[length(path)] <> '\' then
      path := path + '\';


(* create a new (empty) tree structure *)

   root := new_node;
   root^.name := path;
   with newest do
   begin
      isadir := true;
      year := 0;
      month := 0;
      day := 0;
   end;

(* scan all subdirectories and build them into the tree *)

   get_sub_directories(path, root, newest);


(* output the visual tree to standard output *)

   put_tree(output,root);


(* release all memory used by the tree *)

   dispose_tree(root);
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
   writeln('This program will display your directory layout as a visual "tree"');
   writeln('structure.   VisTree does not use the "partial tree" format found');
   writeln('in most other programs of this kind.');
   writeln;
   writeln('Usage:  vistree PATH [OPTIONS] >OUTFILE');
   writeln;
   writeln('Options:  -A        ;include all files in tree listing');
   writeln('          -G        ;don''t use line drawing graphics');
   writeln('          -D        ;include file dates');
   writeln('          -O        ;locate oldest files');
   writeln('          -N        ;locate newest files');
   writeln;
   writeln('Examples:');
   writeln('   vistree                 ;list directory tree from current dir');
   writeln('   vistree c: -a >prn      ;list all files on C: to printer');
   writeln('   vistree \work           ;list structure of \work subdirectory');
   writeln;
   halt;
end;



(*
 * main program
 *
 *)

var
   dir:        anystring;
   param:      anystring;
   paths:      array [1..20] of anystring;
   count:      integer;
   i:          integer;

begin

(* provide defaults for command options *)

   allfiles := false;
   ascii_tree := false;
   count := 0;
   alldates := false;
   locateoldest := false;
   locatenewest := false;

(* scan command line for paths and options *)

   for i := 1 to paramcount do         {process each iamater, if any}
   begin
      param := paramstr(i);

      if param[1] = '-' then            {param is an option}
         case upcase(param[2]) of
            'A':  allfiles := true;
            'G':  ascii_tree := true;
            'D':  alldates := true;
            'N':  begin locatenewest := true; alldates := true; end;
            'O':  begin locateoldest := true; alldates := true; end;
            else  usage;
         end

      else

      begin                             {param is a path; tree it}
         count := count + 1;
         paths[count] := param;
      end;
   end;


(* process the specified paths *)

   if count = 0 then      {give current directory listing if paths}
   begin
      getdir(0,dir);
      dotree(dir);
   end
   else

   for i := 1 to count do
      dotree(paths[i]);

end.

