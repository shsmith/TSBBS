program ptrstruc;
(*
   program to test some tptc features related to pointer dominated code
   - constructs extracted a much larger program set to isolate problem areas
   Key areas are:
++    1.  string variables passed as untyped parameter pointers
++    2.  stronly typed pointers passed as untyped parameters
      3.  structure pointers passed as untyped parameters
++    4.  references to strings passed as untyped parameters
      5.  proper resolution of WITH pointers when more than 1 is active
   Minor areas:
      1.  translation of pascal booleans
      2.  set operations
++    3.  translation of varient records where varient governed by a
          character - not a number
      4.  missing functions : trunc(), addr(), etc..
*)

type
     xstga  = array [1..15] of string[31];
     xnuma = array [1..127] of integer;
     xstga_ptr = ^xstga;
     xnuma_ptr = ^xnuma;

     kwentry = record
                keyword: string[15];
                used:  boolean;
                numops: integer;
                case optype: char of
                'C': (oplocs: xstga_ptr);
                'N': (oplocn: xnuma_ptr);
               end;

     kwtable = record
               numents: integer;
               kwntry: array [1..127] of kwentry;
             end;

const
  kwtbl1_size: integer = 3;
  kwtbl1_entry1: kwentry = (keyword: 'WORD1'; used: false; numops: 2; optype: 'C');
  kwtbl1_entry2: kwentry = (keyword: 'WORD2'; used: false; numops: 3; optype: 'N');
  kwtbl1_entry3: kwentry = (keyword: 'WORD3'; used: false; numops: 4; optype: 'C');

  kwtbl2_size: integer = 4;
  kwtbl2_entry1: kwentry = (keyword: 'WORD21'; used: false; numops: 4; optype: 'C');
  kwtbl2_entry2: kwentry = (keyword: 'WORD22'; used: false; numops: 2; optype: 'N');
  kwtbl2_entry3: kwentry = (keyword: 'WORD23'; used: false; numops: 3; optype: 'C');
  kwtbl2_entry4: kwentry = (keyword: 'WORD24'; used: false; numops: 1; optype: 'C');

  kword1_1: array[1..2] of string[31] = ('Tbl1 KW1 W1', 'Tbl1 KW1 W2');
  kword1_2: array[1..3] of integer = (121,122,123);
  kword1_3: array[1..4] of string[31] = ('Tbl1 KW3 W1', 'Tbl1 KW3 W2',
                                         'Tbl1 KW3 W3', 'Tbl1 KW3 W4');

  kword2_1: array[1..4] of string[31] = ('Tbl2 KW1 W1', 'Tbl2 KW1 W2',
                                         'Tbl2 KW1 W3', 'Tbl2 KW1 W4');
  kword2_2: array[1..2] of integer = (221,222);
  kword2_3: array[1..3] of string[31] = ('Tbl2 KW3 W1', 'Tbl2 KW3 W2',
                                         'Tbl2 KW3 W3');
  kword2_4:integer = 331;

function lookup(var xkwrd, xtblp): integer;
var
    kwrd: string[31] absolute xkwrd;
    kwtblp: ^kwtable   absolute xtblp;
    ii: integer;
begin
     with kwtblp^ do
     begin
        ii := 0;
        repeat
          ii := ii + 1;
        until ((kwntry[ii].keyword = kwrd) or (ii > numents));
        if ii > numents then ii := 0;
     end;
     lookup := ii;
end;

procedure setkwaddrs;
begin
    kwtbl1_entry1.oplocs := addr(kword1_1);
    kwtbl1_entry2.oplocn := addr(kword1_2);
    kwtbl1_entry3.oplocs := addr(kword1_3);

    kwtbl2_entry1.oplocs := addr(kword2_1);
    kwtbl2_entry2.oplocs := addr(kword2_2);
    kwtbl2_entry3.oplocn := addr(kword2_3);
    kwtbl2_entry4.oplocn := addr(kword2_4);
end;

procedure prtentry(xx: integer; var xkw, xptr);
var
    kwtblp: ^kwtable absolute xptr;
    kword: string[31] absolute xkw;
    ii: integer;
begin
  writeln(' For keyword = ', kword, ' - we found = entry[',xx,']');
  with kwtblp^, kwntry[xx] do
  begin
      writeln('   ... for entry[',xx,'] - we have used = ', used, ' - numops = ',
              numops, ' - and operands = ...');
      for ii := 1 to numops do
      begin
        write(' operand[',ii,'] (',optype,') = ');
        if optype = 'C' then writeln( oplocs^[ii])
        else writeln( oplocn^[ii]);
      end
  end
end;

var
    mykword: string[31];
    myptr: ^kwtable;
    found: integer;

begin
  writeln('  ... test program ');
  setkwaddrs;
  mykword := 'WORD3';
  myptr := addr(kwtbl1_size);
  found := lookup(mykword, myptr);
  prtentry(found,mykword,myptr);
end.

