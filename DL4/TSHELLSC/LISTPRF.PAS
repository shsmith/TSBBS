

(*
 * writeprf - write profile samples to a file for analysis
 * s.h.smith, 2-apr-87
 *
 *)

{$k-}

const
   maxseg = 100;

type
   anystring = string[80];
   bigarray = record
      d: array[0..$ff] of integer;
   end;

var
   TableOfs:   integer absolute CSeg:$5C;   {PROFILE stores seg:ofs of}
   TableSeg:   integer absolute CSeg:$5E;   {the data table here}

   fd:         text[8096];
   seg:        integer;
   ofs:        integer;

   segtab:     array[1..maxseg] of integer;
   nseg:       integer;

   ofstab:     array[0..$ff] of ^bigarray;



#include <itoh.inc>

procedure sort_segments;
   var
      j: integer;

   #define SORT_COUNT nseg
   #define SORT_REVERSED (itoh(segtab[%1]) > itoh(segtab[%1+1]))
   #define SORT_SWAP j := segtab[%1]; segtab[%1] := segtab[%1+1]; segtab[%1+1] := j
   #include <bsort.inc>

begin
   sort;
end;



procedure build_segment_table;
var
   ns:         integer;
   n:          integer;
   i,j:        integer;

   procedure addseg;
   begin
      for j := 1 to nseg do
         if segtab[j] = seg then
            exit;

      nseg := nseg + 1;
      segtab[nseg] := seg;
      write('   ',itoh(seg));
   end;

begin
   writeln;
   writeln('Segments:');
   nseg := 0;
   ns := MemW [TableSeg :(TableOfs - 2)];
   n := 0;
   for i := 1 to ns do
   begin
      seg := MemW [TableSeg :(TableOfs + n + 2)];
      addseg;
      n := n + 4;
   end;
   writeln;

end;


procedure tally_segment(tseg: integer);
var
   ns:         integer;
   n:          integer;
   i,j:        integer;
   hits:       integer;

begin
   writeln;
   write('Tally segment: ',itoh(tseg));

   with ofstab[0]^ do
      for j := 0 to $ff do
         d[j] := 0;
   for i := 1 to $ff do
      ofstab[i]^ := ofstab[0]^;

   writeln;

   hits := 0;
   nseg := 0;

   ns := MemW [TableSeg :(TableOfs - 2)];
   n := 0;
   for i := 1 to ns do
   begin

      seg := MemW [TableSeg :(TableOfs + n + 2)];
      if seg = tseg then
      begin
         ofs := MemW [TableSeg :(TableOfs + n)];
         j := lo(ofs);
         with ofstab[hi(ofs)]^ do
            d[j] := succ(d[j]);
         hits := succ(hits);
      end;

      n := n + 4;
   end;

   writeln('   ',itoh(hits),' hits');
end;


procedure report_segment(seg: integer);
var
   i,j:   integer;
   cnt:   integer;

begin
   writeln(fd,'Segment: ',itoh(seg));

   for i := 0 to $ff do
   with ofstab[i]^ do
      for j := 0 to $ff do
      begin
         cnt := d[j];
         if cnt <> 0 then
         begin
            write(fd,itoh((i shl 8) + j));
            if cnt > 1 then
               write(fd,' *',cnt);
            writeln(fd);
         end;
      end;

   writeln(fd);
end;


var
   s: integer;

begin
   build_segment_table;
   sort_segments;

   writeln;
   writeln('Writing samples to PROFILE.OUT...');
   assign(fd,'PROFILE.OUT');
   rewrite(fd);

   for s := 0 to $ff do
      new(ofstab[s]);

   for s := 1 to nseg do
   begin
      tally_segment(segtab[s]);
      report_segment(segtab[s]);
   end;

   close(fd);
end.

