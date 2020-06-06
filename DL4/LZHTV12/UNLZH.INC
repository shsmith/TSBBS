
(* --------------------------------------------------------------
 *   UNLZH.INC
 *
 *   Based on parts of lzhuf.c
 *   Written by Haruyasu Yoshizaki 11/20/1988
 *   Some minor changes 4/6/1989
 *   Comments translated by Haruhiko Okumura 4/7/1989
 *   Translated to turbo pascal by Samuel H. Smith 4/20/1989
 *   Modified for use with LZHTV by Samuel H. Smith 4/21/1989
 *
 *)

const
   N_CHAR = (256-THRESHOLD+lookahead);
                           (* kinds of characters (code = 0..N_CHAR-1) *)

   T = (N_CHAR * 2 - 1);   (* size of table *)

   R = (T - 1);            (* position of root *)

   MAX_FREQ = $8000;       (* updates tree when the *)
                           (* root frequency comes to this value. *)

var
   freq:   array[0..T+1] of word;   (* frequency table *)

   parent:  array[0..T+N_CHAR] of word;
               (* pointers to parent nodes, except for the *)
               (* elements[T..T + N_CHAR - 1] which are used to get *)
               (* the positions of leaves corresponding to the codes. *)

   son:  array[0..T] of integer;
               (* pointers to child nodes (son[], son[] + 1) *)


(* table for encoding and decoding the upper 6 bits of position *)
const
   d_code: array[0..255] of byte = (
        $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
        $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
        $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01,
        $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02,
        $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $03,
        $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03,
        $03, $03, $04, $04, $04, $04, $04, $04, $04, $04, $05, $05, $05,
        $05, $05, $05, $05, $05, $06, $06, $06, $06, $06, $06, $06, $06,
        $07, $07, $07, $07, $07, $07, $07, $07, $08, $08, $08, $08, $08,
        $08, $08, $08, $09, $09, $09, $09, $09, $09, $09, $09, $0A, $0A,
        $0A, $0A, $0A, $0A, $0A, $0A, $0B, $0B, $0B, $0B, $0B, $0B, $0B,
        $0B, $0C, $0C, $0C, $0C, $0D, $0D, $0D, $0D, $0E, $0E, $0E, $0E,
        $0F, $0F, $0F, $0F, $10, $10, $10, $10, $11, $11, $11, $11, $12,
        $12, $12, $12, $13, $13, $13, $13, $14, $14, $14, $14, $15, $15,
        $15, $15, $16, $16, $16, $16, $17, $17, $17, $17, $18, $18, $19,
        $19, $1A, $1A, $1B, $1B, $1C, $1C, $1D, $1D, $1E, $1E, $1F, $1F,
        $20, $20, $21, $21, $22, $22, $23, $23, $24, $24, $25, $25, $26,
        $26, $27, $27, $28, $28, $29, $29, $2A, $2A, $2B, $2B, $2C, $2C,
        $2D, $2D, $2E, $2E, $2F, $2F, $30, $31, $32, $33, $34, $35, $36,
        $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F);

   d_len: array[0..255] of byte = (
        $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03,
        $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03,
        $03, $03, $03, $03, $03, $03, $04, $04, $04, $04, $04, $04, $04,
        $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04,
        $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04,
        $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04,
        $04, $04, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05,
        $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05,
        $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05,
        $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05,
        $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05,
        $05, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06,
        $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06,
        $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06,
        $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $07, $07, $07,
        $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07,
        $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07,
        $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07,
        $07, $07, $07, $07, $07, $07, $08, $08, $08, $08, $08, $08, $08,
        $08, $08, $08, $08, $08, $08, $08, $08, $08);


(* ------------------------------------------------------------- *)
const
   getbuf: word = 0;
   getlen: byte = 0;

function GetBit: integer;  (* get one bit *)
var
   i:   byte;
   
begin
   while (getlen <= 8) do
   begin
      ReadByte(i);
      getbuf := getbuf or (word(i) shl (8 - getlen));
      inc(getlen, 8);
   end;
   
   if (getbuf and $8000) <> 0 then
      GetBit := 1
   else
      GetBit := 0;

   getbuf := getbuf shl 1;
   dec(getlen);
end;


function GetByte: integer; (* get one byte *)
var
   i:   byte;
   
begin
   while (getlen <= 8) do
   begin
      ReadByte(i);
      getbuf := getbuf or (word(i) shl (8 - getlen));
      inc(getlen, 8);
   end;
   
   GetByte := getbuf shr 8;
   getbuf := getbuf shl 8;
   dec(getlen, 8);
end;


(* ----------------------------------------------------------- *)
(* initialization of tree *)

procedure StartHuff;
var
   i:   integer;
   j:   integer;

begin

   for i := 0 to N_CHAR - 1 do
   begin
      freq[i] := 1;
      son[i] := i + T;
      parent[i + T] := i;
   end;

   i := 0;
   j := N_CHAR;
   while (j <= R) do
   begin
      freq[j] := freq[i] + freq[i + 1];
      son[j] := i;
      parent[i] := j;
      parent[i + 1] := j;
      inc(i, 2);
      inc(j);
   end;

   freq[T] := $ffff;
   parent[R] := 0;
end;


(* ----------------------------------------------------------- *)
(* reconstruction of tree *)

procedure reconst;
var
   i,j,k:  integer;
   f,l:    word;

begin

(* collect leaf nodes in the first half of the table *)
(* and replace the freq by (freq + 1) / 2. *)
   j := 0;
   for i := 0 to T - 1 do
   begin

      if (son[i] >= T) then
      begin
         freq[j] := (freq[i] + 1) div 2;
         son[j] := son[i];
         inc(j);
      end;
   end;


(* begin constructing tree by connecting sons *)

   i := 0;
   for j := N_CHAR to T - 1 do
   begin
      k := i + 1;
      f := freq[i] + freq[k];
      freq[j] := f;

      k := j - 1;
      while (f < freq[k]) do
         dec(k);

      inc(k);
      l := (j - k) * 2;

      move(freq[k], freq[k+1], l);
      freq[k] := f;

      move(son[k], son[k+1], l);
      son[k] := i;

      inc(i, 2);
   end;


(* connect parent *)

   for i := 0 to T - 1 do
   begin
      k := son[i];
      if k >= T then
         parent[k] := i
      else
      begin
         parent[k] := i;
         parent[k + 1] := i;
      end;
   end;
end;


(* ----------------------------------------------------------- *)
(* increment frequency of given code by one, and update tree *)

procedure update (c:   integer);
var
   i,j,k,l:   integer;

begin

   if (freq[R] = MAX_FREQ) then
      reconst;

   c := parent[c + T];

   repeat
      inc(freq[c]);
      k := freq[c];

(* if the order is disturbed, exchange nodes *)

      l := c+1;
      if (k > freq[l]) then
      begin
         repeat
            inc(l);
         until k <= freq[l];

         dec(l);
         freq[c] := freq[l];
         freq[l] := k;

         i := son[c];

         parent[i] := l;
         if (i < T) then
            parent[i + 1] := l;

         j := son[l];
         son[l] := i;

         parent[j] := c;
         if (j < T) then
            parent[j + 1] := c;

         son[c] := j;
         c := l;
      end;

      c := parent[c];

   until c = 0;   (* repeat up to root *)
end;


(* ----------------------------------------------------------- *)
function DecodeChar: integer;
var
   c:   word;
   b:   integer;

begin
   c := son[R];

(* travel from root to leaf, *)
(* choosing the smaller child node (son[]) if the read bit is 0, *)
(* the bigger (son[] +1end; if 1 *)

   while (c < T) do
   begin
      inc(c,GetBit);
      c := son[c];
   end;

   dec(c, T);
   update(c);
   DecodeChar := c;
end;


(* ----------------------------------------------------------- *)
function DecodePosition: integer;
var
   i,j,c:   word;
   b:       integer;

begin

(* recover upper 6 bits from table *)
   i := GetByte;
   c := d_code[i] shl 6;
   j := d_len[i];

(* read lower 6 bits verbatim *)
   dec(j, 2);
   while j <> 0 do
   begin
      dec(j);
      i := (i shl 1) + GetBit;
   end;

   DecodePosition := c or (i and $3f);
end;


(* ----------------------------------------------------------- *)
procedure unLZHuf;

var
   i,j,k,c: integer;
   count:   longint;

begin
   if (header.compressed_size = 0) then
      exit;

   StartHuff;

   fillchar(outbuf,sizeof(outbuf),' ');
   outpos := obufsize - lookahead;

   count := 0;
   while (count < header.original_size) do
   begin

      c := DecodeChar;
      if (c < 256) then
      begin
         OutByte(c);
         inc(count);
      end
      else

      begin
         i := (outpos - DecodePosition - 1) mod obufsize;
         j := c - 255 + THRESHOLD;

         for k := 0 to j - 1 do
         begin
            c := outbuf[(i + k) mod obufsize];
            OutByte(c);
            inc(count);
         end;
      end;

      if fileeof or dump_user then
         exit;
   end;

end;

