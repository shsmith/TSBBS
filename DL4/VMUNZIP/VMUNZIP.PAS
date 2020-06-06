%margins 1 80
%check on
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 * Modifications to run under VM/CMS made by John McKown
 * CompuServe Id: 72325,1705
 * Last Modified date: July, 1989
 *)
(*
 * UnZip - A simple zipfile extract utility
 *
 *)


program VmUnZip;

%include CMS

const
   version = 'UnZip:  Zipfile Extract v1.1. of 03-06-89;  (C) 1989 S.H.Smith';

(*
 * ProZip2.int - ZIP file interface library      (2-15-89 shs)
 * Data declarations for the archive text-view functions.
 *)

(*
 * ZIPfile layout declarations
 *
 *)

const
   local_file_header_signature = '04034b50'x;
   central_file_header_signature = '02014b50'x;
   end_central_dir_signature = '06054b50'x;
   def_string_size = 3000;

(*
 * defines for turbo pascal datatypes
 *)
type
 pcint = packed -32768..32767;
 byte = packed 0..255;
 shortint = packed -128..127;
 UPCINT = PACKED 0..65535;
 LONGINT = ARRAY(.0..3.) OF BYTE ;
 WORD = ARRAY(.0..1.) OF BYTE;

type
   zipfile = record
         filename: string(20);
         realfile: file of byte;
         end;
   outfile = record
         filename: string(20);
         realfile: file of byte;
         end;
   signature_type = longint;
   local_file_header = record
     $version_needed_to_extract:    word;
     $general_purpose_bit_flag:     word;
     $compression_method:           word;
     $last_mod_file_time:           word;
     $last_mod_file_date:           word;
     $crc32:                        longint;
     $compressed_size:              longint;
     $uncompressed_size:            longint;
     $filename_length:              word;
     $extra_field_length:           word;
   end;
   central_directory_file_header = record
     $version_made_by:                 word;
     $version_needed_to_extract:       word;
     $general_purpose_bit_flag:        word;
     $compression_method:              word;
     $last_mod_file_time:              word;
     $last_mod_file_date:              word;
     $crc32:                           longint;
     $compressed_size:                 longint;
     $uncompressed_size:               longint;
     $filename_length:                 word;
     $extra_field_length:              word;
     $file_comment_length:             word;
     $disk_number_start:               word;
     $internal_file_attributes:        word;
     $external_file_attributes:        longint;
     $relative_offset_local_header:    longint;
   end;
   end_central_dir_record = record
     $number_this_disk:                         word;
     $number_disk_with_start_central_directory: word;
     $total_entries_central_dir_on_this_disk:   word;
     $total_entries_central_dir:                word;
     $size_central_directory:                   longint;
     $offset_start_central_directory:           longint;
     $zipfile_comment_length:                   word;
   end;



(* ----------------------------------------------------------- *)
(*
 * input file variables
 *
 *)

const
   uinbufsize = 512;    /*input buffer size*/

type
 uinbufarray = array(.1..uinbufsize.) of byte;
 outbufarray = array(.0..4096.) of byte;

var
   Crc32Val:    Integer;
   InCrc:       Integer;
   zipname:     string(8);
   zipeof:      boolean;
   csize:       integer;
   cusize:      integer;
   cmethod:     pcint;
   ctime:       integer;
   cdate:       integer;
   inbuf:       uinbufarray;
   inpos:       pcint;
   incnt:       pcint;
   pc:          byte;
   pcbits:      byte;
   pcbitv:      byte;
   zipfn:       zipfile;
   myparms:     string(120);
   i:           integer;
   filename_length:integer;
   extra_field_length:integer;
   zipfile_comment_length:integer;
   file_comment_length:integer;
   coptions : (PROMPT, REPLACE, BYPASS);
   optstr : ALPHA;

(*
 * output stream variables
 *
 *)

var
   outbuf:      outbufarray;            /*for rle look-back*/
   outpos:      integer;                /*absolute position in outfile*/
   outcnt:      pcint;
   outfd:       outfile;
   filename:    string(def_string_size);
   extra:       string(def_string_size);
   out_zip:     file of byte;

(* ----------------------------------------------------------- *)

type
   Sarray = array(.0..255.) of string(64);

var
   factor:     pcint;
   followers:  Sarray;
   ExState:    pcint;
   C:          pcint;
   V:          pcint;
   Len:        pcint;

const
   hsize =     8192;

type
   hsize_array_integer = array(.0..hsize.) of pcint;
   hsize_array_byte    = array(.0..hsize.) of byte;

var
   prefix_of:  hsize_array_integer;
   suffix_of:  hsize_array_byte;
   stack:      hsize_array_byte;
   stackp:     pcint;

(*
 * Zipfile input/output handlers
 *
 *)

/* Converted to IBM VS Pascal 1.0 July, 1989 by John McKown                  */
/* Converted to Turbo Pascal (tm) V4.0 March, 1988 by J.R.Louvau             */
/* COPYRIGHT (C) 1986 Gary S. Brown. You may use this program, or            */
/* code or tables extracted from it, as desired without restriction.         */
/*                                                                           */
/* First, the polynomial itself and its table of feedback terms. The         */
/* polynomial is                                                             */
/* X@32+X@26+X@23+X@22+X@16+X@12+X@11+X@10+X@8+X@7+X@5+X@4+X@2+X@1+X@0       */
/*                                                                           */
/* Note that we take it "backwards" and put the highest-order term in        */
/* the lowest-order bit. The X@32 term is "implied"; the LSB is the          */
/* X@31 term, etc. The X@0 term (usually shown as "+1") results in           */
/* the MSB being 1.                                                          */
/*                                                                           */
/* Note that the usual hardware shift register implementation, which         */
/* is what we're using (we're merely optimizing it by doing eight-bit        */
/* chunks at a time) shifts bits into the lowest-order term. In our          */
/* implementation, that means shifting towards the right. Why do we          */
/* do it this way? Because the calculated CRC must be transmitted in         */
/* order from highest-order term to lowest-order term. UARTs transmit        */
/* characters in order from LSB to MSB. By storing the CRC this way,         */
/* we hand it to the UART in the order low-byte to high-byte; the UART       */
/* sends each low-bit to hight-bit; and the result is transmission bit       */
/* by bit from highest- to lowest-order term without requiring any bit       */
/* shuffling on our part. Reception works similarly.                         */
/*                                                                           */
/* The feedback terms table consists of 256, 32-bit entries. Notes:          */
/*                                                                           */
/*    The table can be generated at runtime if desired; code to do so        */
/*    is shown later.  It might not be obvious, but the feedback             */
/*    terms simply represent the results of eight shift/xor opera-           */
/*    tions for all combinations of data and CRC register values.            */
/*                                                                           */
/*    The values must be right-shifted by eight bits by the "updcrc"         */
/*    logic; the shift must be unsigned (bring in zeroes).  On some          */
/*    hardware you could probably optimize the shift in assembler by         */
/*    using byte-swap instructions.                                          */
/*    polynomial 'edb88320'x                                                 */
/*                                                                           */


Function UpdC32(Octet: Byte; Crc: Integer) : Integer;
(*
 Note that the Crc needs to be initialized to -1 (all bits on)
 Thereafter, this function is called as follows:
 NewCrcVal := UpdC32(InputByte,OldCrcVal);
*)
type
 Int256 = Array(.0..255.) of Integer;
Static
 CRC_32_TAB : Int256;
Value
   CRC_32_TAB := Int256 (
'00000000'x, '77073096'x, 'ee0e612c'x, '990951ba'x, '076dc419'x,
'706af48f'x, 'e963a535'x, '9e6495a3'x, '0edb8832'x, '79dcb8a4'x,
'e0d5e91e'x, '97d2d988'x, '09b64c2b'x, '7eb17cbd'x, 'e7b82d07'x,
'90bf1d91'x, '1db71064'x, '6ab020f2'x, 'f3b97148'x, '84be41de'x,
'1adad47d'x, '6ddde4eb'x, 'f4d4b551'x, '83d385c7'x, '136c9856'x,
'646ba8c0'x, 'fd62f97a'x, '8a65c9ec'x, '14015c4f'x, '63066cd9'x,
'fa0f3d63'x, '8d080df5'x, '3b6e20c8'x, '4c69105e'x, 'd56041e4'x,
'a2677172'x, '3c03e4d1'x, '4b04d447'x, 'd20d85fd'x, 'a50ab56b'x,
'35b5a8fa'x, '42b2986c'x, 'dbbbc9d6'x, 'acbcf940'x, '32d86ce3'x,
'45df5c75'x, 'dcd60dcf'x, 'abd13d59'x, '26d930ac'x, '51de003a'x,
'c8d75180'x, 'bfd06116'x, '21b4f4b5'x, '56b3c423'x, 'cfba9599'x,
'b8bda50f'x, '2802b89e'x, '5f058808'x, 'c60cd9b2'x, 'b10be924'x,
'2f6f7c87'x, '58684c11'x, 'c1611dab'x, 'b6662d3d'x, '76dc4190'x,
'01db7106'x, '98d220bc'x, 'efd5102a'x, '71b18589'x, '06b6b51f'x,
'9fbfe4a5'x, 'e8b8d433'x, '7807c9a2'x, '0f00f934'x, '9609a88e'x,
'e10e9818'x, '7f6a0dbb'x, '086d3d2d'x, '91646c97'x, 'e6635c01'x,
'6b6b51f4'x, '1c6c6162'x, '856530d8'x, 'f262004e'x, '6c0695ed'x,
'1b01a57b'x, '8208f4c1'x, 'f50fc457'x, '65b0d9c6'x, '12b7e950'x,
'8bbeb8ea'x, 'fcb9887c'x, '62dd1ddf'x, '15da2d49'x, '8cd37cf3'x,
'fbd44c65'x, '4db26158'x, '3ab551ce'x, 'a3bc0074'x, 'd4bb30e2'x,
'4adfa541'x, '3dd895d7'x, 'a4d1c46d'x, 'd3d6f4fb'x, '4369e96a'x,
'346ed9fc'x, 'ad678846'x, 'da60b8d0'x, '44042d73'x, '33031de5'x,
'aa0a4c5f'x, 'dd0d7cc9'x, '5005713c'x, '270241aa'x, 'be0b1010'x,
'c90c2086'x, '5768b525'x, '206f85b3'x, 'b966d409'x, 'ce61e49f'x,
'5edef90e'x, '29d9c998'x, 'b0d09822'x, 'c7d7a8b4'x, '59b33d17'x,
'2eb40d81'x, 'b7bd5c3b'x, 'c0ba6cad'x, 'edb88320'x, '9abfb3b6'x,
'03b6e20c'x, '74b1d29a'x, 'ead54739'x, '9dd277af'x, '04db2615'x,
'73dc1683'x, 'e3630b12'x, '94643b84'x, '0d6d6a3e'x, '7a6a5aa8'x,
'e40ecf0b'x, '9309ff9d'x, '0a00ae27'x, '7d079eb1'x, 'f00f9344'x,
'8708a3d2'x, '1e01f268'x, '6906c2fe'x, 'f762575d'x, '806567cb'x,
'196c3671'x, '6e6b06e7'x, 'fed41b76'x, '89d32be0'x, '10da7a5a'x,
'67dd4acc'x, 'f9b9df6f'x, '8ebeeff9'x, '17b7be43'x, '60b08ed5'x,
'd6d6a3e8'x, 'a1d1937e'x, '38d8c2c4'x, '4fdff252'x, 'd1bb67f1'x,
'a6bc5767'x, '3fb506dd'x, '48b2364b'x, 'd80d2bda'x, 'af0a1b4c'x,
'36034af6'x, '41047a60'x, 'df60efc3'x, 'a867df55'x, '316e8eef'x,
'4669be79'x, 'cb61b38c'x, 'bc66831a'x, '256fd2a0'x, '5268e236'x,
'cc0c7795'x, 'bb0b4703'x, '220216b9'x, '5505262f'x, 'c5ba3bbe'x,
'b2bd0b28'x, '2bb45a92'x, '5cb36a04'x, 'c2d7ffa7'x, 'b5d0cf31'x,
'2cd99e8b'x, '5bdeae1d'x, '9b64c2b0'x, 'ec63f226'x, '756aa39c'x,
'026d930a'x, '9c0906a9'x, 'eb0e363f'x, '72076785'x, '05005713'x,
'95bf4a82'x, 'e2b87a14'x, '7bb12bae'x, '0cb61b38'x, '92d28e9b'x,
'e5d5be0d'x, '7cdcefb7'x, '0bdbdf21'x, '86d3d2d4'x, 'f1d4e242'x,
'68ddb3f8'x, '1fda836e'x, '81be16cd'x, 'f6b9265b'x, '6fb077e1'x,
'18b74777'x, '88085ae6'x, 'ff0f6a70'x, '66063bca'x, '11010b5c'x,
'8f659eff'x, 'f862ae69'x, '616bffd3'x, '166ccf45'x, 'a00ae278'x,
'd70dd2ee'x, '4e048354'x, '3903b3c2'x, 'a7672661'x, 'd06016f7'x,
'4969474d'x, '3e6e77db'x, 'aed16a4a'x, 'd9d65adc'x, '40df0b66'x,
'37d83bf0'x, 'a9bcae53'x, 'debb9ec5'x, '47b2cf7f'x, '30b5ffe9'x,
'bdbdf21c'x, 'cabac28a'x, '53b39330'x, '24b4a3a6'x, 'bad03605'x,
'cdd70693'x, '54de5729'x, '23d967bf'x, 'b3667a2e'x, 'c4614ab8'x,
'5d681b02'x, '2a6f2b94'x, 'b40bbe37'x, 'c30c8ea1'x, '5a05df1b'x,
'2d02ef8d'x
);

Var
 Temp:record
   case boolean of
   true:(L:Integer;);
   false:(W:Array(.1..4.) of Byte;);
   end;
Begin

   Temp.L := 0;
   Temp.W(.4.) := Octet;
(* the above two lines convert a byte to an integer *)
   Temp.L := Crc XOR Temp.L;
   UpdC32 := CRC_32_TAB(.Temp.W(.4.).) XOR (Crc >> 8);

end /*UpdC32*/;

Function a2e(in_char:char):char;
type
 a2edata = array(.0..255.) of char;
static
 a2evalue:a2edata;
value
 a2evalue := a2edata (
   '00'xc,'01'xc,'02'xc,'03'xc,'37'xc,'2D'xc,'2E'xc,'2F'xc,
   '16'xc,'05'xc,'25'xc,'0B'xc,'0C'xc,'0D'xc,'0E'xc,'0F'xc,
   '10'xc,'11'xc,'12'xc,'13'xc,'3C'xc,'3D'xc,'32'xc,'26'xc,
   '18'xc,'19'xc,'3F'xc,'27'xc,'1C'xc,'1D'xc,'1E'xc,'1F'xc,
   '40'xc,'5A'xc,'7F'xc,'7B'xc,'5B'xc,'6C'xc,'50'xc,'7D'xc,
   '4D'xc,'5D'xc,'5C'xc,'4E'xc,'6B'xc,'60'xc,'4B'xc,'61'xc,
   'F0'xc,'F1'xc,'F2'xc,'F3'xc,'F4'xc,'F5'xc,'F6'xc,'F7'xc,
   'F8'xc,'F9'xc,'7A'xc,'5E'xc,'4C'xc,'7E'xc,'6E'xc,'6F'xc,
   '7C'xc,'C1'xc,'C2'xc,'C3'xc,'C4'xc,'C5'xc,'C6'xc,'C7'xc,
   'C8'xc,'C9'xc,'D1'xc,'D2'xc,'D3'xc,'D4'xc,'D5'xc,'D6'xc,
   'D7'xc,'D8'xc,'D9'xc,'E2'xc,'E3'xc,'E4'xc,'E5'xc,'E6'xc,
   'E7'xc,'E8'xc,'E9'xc,'AD'xc,'E0'xc,'BD'xc,'5F'xc,'6D'xc,
   '79'xc,'81'xc,'82'xc,'83'xc,'84'xc,'85'xc,'86'xc,'87'xc,
   '88'xc,'89'xc,'91'xc,'92'xc,'93'xc,'94'xc,'95'xc,'96'xc,
   '97'xc,'98'xc,'99'xc,'A2'xc,'A3'xc,'A4'xc,'A5'xc,'A6'xc,
   'A7'xc,'A8'xc,'A9'xc,'8B'xc,'4F'xc,'9B'xc,'A1'xc,'07'xc,
   '00'xc,'01'xc,'02'xc,'03'xc,'37'xc,'2D'xc,'2E'xc,'2F'xc,
   '16'xc,'05'xc,'25'xc,'0B'xc,'0C'xc,'0D'xc,'0E'xc,'0F'xc,
   '10'xc,'11'xc,'12'xc,'13'xc,'3C'xc,'3D'xc,'32'xc,'26'xc,
   '18'xc,'19'xc,'3F'xc,'27'xc,'1C'xc,'1D'xc,'1E'xc,'1F'xc,
   '40'xc,'5A'xc,'7F'xc,'7B'xc,'5B'xc,'6C'xc,'50'xc,'7D'xc,
   '4D'xc,'5D'xc,'5C'xc,'4E'xc,'6B'xc,'60'xc,'4B'xc,'61'xc,
   'F0'xc,'F1'xc,'F2'xc,'F3'xc,'F4'xc,'F5'xc,'F6'xc,'F7'xc,
   'F8'xc,'F9'xc,'7A'xc,'5E'xc,'4C'xc,'7E'xc,'6E'xc,'6F'xc,
   '7C'xc,'C1'xc,'C2'xc,'C3'xc,'C4'xc,'C5'xc,'C6'xc,'C7'xc,
   'C8'xc,'C9'xc,'D1'xc,'D2'xc,'D3'xc,'D4'xc,'D5'xc,'D6'xc,
   'D7'xc,'D8'xc,'D9'xc,'E2'xc,'E3'xc,'E4'xc,'E5'xc,'E6'xc,
   'E7'xc,'E8'xc,'E9'xc,'AD'xc,'E0'xc,'BD'xc,'5F'xc,'6D'xc,
   '79'xc,'81'xc,'82'xc,'83'xc,'84'xc,'85'xc,'86'xc,'87'xc,
   '88'xc,'89'xc,'91'xc,'92'xc,'93'xc,'94'xc,'95'xc,'96'xc,
   '97'xc,'98'xc,'99'xc,'A2'xc,'A3'xc,'A4'xc,'A5'xc,'A6'xc,
   'A7'xc,'A8'xc,'A9'xc,'8B'xc,'4F'xc,'9B'xc,'A1'xc,'07'xc
  );
begin
 a2e := a2evalue(.ord(in_char).);
end;

Procedure UpCase(var x:char);
Var
 y: integer;
begin
 y := ord(x);
 if (y>128) and (y<138) then y := y + 64;
 if (y>144) and (y<154) then y := y + 64;
 if (y>161) and (y<170) then y := y + 64;
 x := chr(y);
end;

Procedure valid_name(var x:string(8));
  Var
    i : integer;
    t : char;
  begin
    for i:= 1 to length(x) do
      begin
        t := x(.i.);
        UpCase(t);
        x(.i.) := t;
        case x(.i.) of
          'A'..'I',
          'J'..'R',
          'S'..'Z',
          '0'..'9',
          '@', '#', '$': ;
          otherwise x(.i.) := '#';
        end;
      end;
  end;


procedure vm_write(var x:outfile;
          oarea:outbufarray;
          outcnt:pcint);
var
 i:integer;
begin
 for i := 0 to outcnt-1 do
  Write(x.realfile,oarea(.i.));

end;

function vm_create(fn:string(def_string_size);
         var x:outfile):boolean;
var
    ftype    : string(8);
    fname    : string(8);
    filename : string(20);
    cmdline   : string(100);
    i        : integer;
    Ans      : Char;
begin
  begin
    i := rindex(fn,'\');
    if i <> 0
    then filename := substr(fn,i+1)
    else filename := fn;
    i := index(filename,'.');
    if i<> 0
    then begin
         fname := trim(ltrim(substr(filename,1,i-1)));
         ftype := trim(ltrim(substr(filename,i+1)));
         end
    else begin
         fname := ltrim(trim(filename));
         ftype := '$extract';
         end;
    if ftype = '' then ftype := '$extract';
    valid_name(fname);
    valid_name(ftype);
    filename := fname || '.' || ftype || '.A1';
(*
    I use a REXX program to check for the existance of the output
    file. I do this because invoking STATE directly can cause a
    return code of 88 if the file exists and has more that 65536
    records. This is because the Pascal CMS routine uses the old,
    non extended version of the PLIST. Using the REXX exec avoids this
    problem.
*)
    Ans := 'Y';
    if coptions <> REPLACE
    then begin
         cmdline := 'EXEC CHECK '||fname|| ' ' || ftype || ' A';
         CMS(cmdline,i);
         if i=0
         then begin
              if coptions = BYPASS then Ans := 'N'
              else begin
                   WriteLn('Warning! File:',fname,' ',ftype,
                       ' A already exists. Overwrite?');
                   ReadLn(Ans);
                   UpCase(Ans);
                   end
              end
         else if i<> 28
              then begin
                   Ans := 'N';
                   WriteLn('Unsupported return code from STATE =',i:3,
                     ' file:',fn,' bypassed.');
                   end;
         end;
    if Ans = 'Y'
    then begin
         x.filename := filename;
         ReWrite(x.realfile,'name=' || x.filename);
         vm_create := true;
         end
    else vm_create := false;
  end;
end;

procedure vm_close(var x:outfile);
begin
 close(x.realfile);

end;

function vm_read_string(var x:zipfile;
         var iarea:string(def_string_size);
         inpos:pcint):pcint;
var
 i:integer;
 j:integer;
 in_data:record
    case boolean of
    false:(in_byte:byte;);
    true:(in_char:char;);
    end;
begin

 iarea := '';
 j:=0;
 for i := 1 to inpos do
  begin
  read(x.realfile,in_data.in_byte);
  in_data.in_char := a2e(in_data.in_char);
  j:=i;
  iarea := iarea || str(in_data.in_char);
  if eof(x.realfile)
  then begin WriteLn('vm_read_string eof'); leave; end;
  end;
 vm_read_string := j;
end;

function vm_read_bytes(var x:zipfile;
         var iarea:uinbufarray;
         inpos:pcint):pcint;
Var
 i:integer;
 j:integer;
begin
 j := 0;
 for i := 1 to inpos do
  begin
  read(x.realfile,iarea(.i.));
  j := i;
  if eof(x.realfile) then leave;
  end;
 vm_read_bytes := j;
end;

function vm_read_local(var x:zipfile;
         var iarea:local_file_header;
         inpos:pcint):pcint;
var
 i:integer;
 j:integer;
 temp:record
      case boolean of
      true:(temp_hdr:local_file_header;);
      false:(temp_byte:array (.1..sizeof(local_file_header).) of byte;);
      end;
begin
 j := 0;
 for i := 1 to inpos do begin
  read(x.realfile,temp.temp_byte(.i.));
  j := i;
  if eof(x.realfile) then leave;
  end;
 iarea := temp.temp_hdr;
 vm_read_local := j;
end;

function vm_read_central(var x:zipfile;
         var iarea:central_directory_file_header;
         inpos:pcint):pcint;
var
 i:integer;
 j:integer;
 temp:record
  case boolean of
  true:(temp_hdr:central_directory_file_header;);
  false:(temp_byte:array (.1..sizeof(central_directory_file_header).)
                   of byte;);
  end;
begin
 j := 0;
 for i := 1 to inpos do begin
  read(x.realfile,temp.temp_byte(.i.));
  j := i;
  if eof(x.realfile) then leave;
  end;
 iarea := temp.temp_hdr;
 vm_read_central := j;
end;

function vm_read_ecent(var x:zipfile;
         var iarea:end_central_dir_record;
         inpos:pcint):pcint;
var
 i:integer;
 j:integer;
 temp:record
      case boolean of
      true:(temp_hdr:end_central_dir_record;);
      false:(temp_byte:array (.1..sizeof(end_central_dir_record).)
                       of byte;);
      end;
begin
 j := 0;
 for i := 1 to inpos do begin
  read(x.realfile,temp.temp_byte(.i.));
  j := i;
  if eof(x.realfile) then leave;
  end;
 iarea := temp.temp_hdr;
 vm_read_ecent := j;
end;

function vm_read_sig(var x:zipfile;
         var iarea:longint;
         inpos:pcint):pcint;
var
 i:integer;
 j:integer;
 temp:record
      case boolean of
      true:(temp_data:longint;);
      false:(temp_byte:array (.1..sizeof(longint).) of byte;);
      end;
begin
 j:=0;
 for i := 1 to inpos do begin
  read(x.realfile,temp.temp_byte(.i.));
  j := i;
  if eof(x.realfile) then leave;
  end;
 iarea := temp.temp_data;
 vm_read_sig := j;
end;

function val_word(word_val:word):integer;
var
 hold:byte;
 temp:record
    case integer of
    1:(x1,x2:byte;);
    2:(x:word;);
    3:(y:pcint;);
    end;
begin
 temp.x := word_val ;
 hold:=temp.x1;
 temp.x1:=temp.x2;
 temp.x2:=hold;
 val_word := temp.y;
end;

function val_longint(longint_val:longint):integer;
var
 temp:record
     case integer of
     1:(x1,x2,x3,x4:byte;);
     2:(x:longint;);
     3:(y:integer;);
     end;
 hold:byte;
begin
 temp.x := longint_val;
 hold := temp.x1;
 temp.x1 := temp.x4;
 temp.x4 := hold;
 hold := temp.x2;
 temp.x2 := temp.x3;
 temp.x3 := hold;
 val_longint := temp.y;
end;

(* ------------------------------------------------------------- *)
procedure skip_csize;
var
 i:integer;
begin
   for i:= 1 to csize do get(zipfn.realfile);
   zipeof := true;
   csize := 0;
   incnt := 0;
end;


(* ------------------------------------------------------------- *)
procedure ReadByte(var x: byte);
begin
   if incnt = 0 then
   begin
      if csize = 0 then
      begin
         zipeof := true;
         return;
      end;

      inpos := sizeof(inbuf);
      if inpos > csize then
         inpos := csize;
      incnt := vm_read_bytes(zipfn,inbuf,inpos);

      inpos := 1;
(*    pred(csize,incnt);  *)
      csize := csize - incnt;
   end;

   x := inbuf(.inpos.);
(* succ(inpos);  *)
   inpos := inpos + 1;
(* pred(incnt); *)
   incnt := incnt - 1;
end;


(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(******************************************************
 *
 * Procedure:  itoh
 *
 * Purpose:    converts an integer into a string of hex digits
 *
 * Example:    s := itoh(i);
 *
 *)


(* ------------------------------------------------------------- *)
procedure ReadBits(bits: pcint; var result: pcint);
   /*read the specified number of bits*/
var
   bit:     pcint ;
   bitv:    pcint ;
   x:       pcint ;
(*
value
   bit := 0;
   bitv := 0;
   x := 0;
*)
begin
   x := 0;
   bitv := 1;

   for bit := 0 to bits-1 do
   begin

      if pcbits > 0 then
      begin
         pcbits := pcbits - 1;
         pcbitv := pcbitv << 1;
      end
      else

      begin
         ReadByte(pc);
         pcbits := 7;
         pcbitv := 1;
      end;

      if (pc and pcbitv) <> 0 then
         x := x or bitv;

      bitv := bitv << 1;
   end;

(* WriteLn(bits,'-',itohs(x)); *)
   result := x;
end;


(* ---------------------------------------------------------- *)
procedure get_string(ln: integer; var s: string(def_string_size));
var
   n: integer;
begin
   s := '';
   if ln = 0 then return;
   if ln > 255 then
      ln := 255;
   n := vm_read_string(zipfn,s,ln);
   if n<>ln then WriteLn('get_string n=',n,' ln=',ln);
end;


(* ------------------------------------------------------------- *)
procedure OutByte (c: byte);
   (* output each character from archive to screen *)
begin
   Crc32Val := UpdC32(c,Crc32Val);
   outbuf(.outcnt.) := c;
   outpos := outpos + 1;
   outcnt := outcnt + 1;
   if outcnt = sizeof(outbuf) then
   begin
      vm_write(outfd,outbuf,outcnt);
      outcnt := 0;
   end;
end;


(*
 * expand 'reduced' members of a zipfile
 *
 * The Reducing algorithm is actually a combination of two
 * distinct algorithms.  The first algorithm compresses repeated
 * byte sequences, and the second algorithm takes the compressed
 * stream from the first algorithm and applies a probabilistic
 * compression method.
 *
 *)

function reduce_L(x: byte): byte;
type
  byte4 = array(.1..4.) of byte;
static
  values : byte4;
value
  values := byte4 ('7f'x,'3f'x,'1f'x,'0f'x);
begin
  reduce_L := x and values(.factor.);
end;

function reduce_F(x: byte): byte;
begin
   case factor of
      1: if x = 127 then reduce_F := 2 else reduce_F := 3;
      2: if x = 63  then reduce_F := 2 else reduce_F := 3;
      3: if x = 31  then reduce_F := 2 else reduce_F := 3;
      4: if x = 15  then reduce_F := 2 else reduce_F := 3;
   end;
end;

function reduce_D(x,y: byte): pcint;
var
 result:pcint;
begin
result := x;
result := ((result << factor) and '0f00'x) +y+1;
reduce_D := result;
end;

function reduce_B(x: byte): pcint;
   /*number of bits needed to encode the specified number*/
begin
   case x-1 of
      0..1:    reduce_B := 1;
      2..3:    reduce_B := 2;
      4..7:    reduce_B := 3;
      8..15:   reduce_B := 4;
     16..31:   reduce_B := 5;
     32..63:   reduce_B := 6;
     64..127:  reduce_B := 7;
   otherwise   reduce_B := 8;
   end;
end;

procedure Expand(c: byte);
const
   DLE = 144;
var
   op:   integer;
   i:    pcint;

begin

   case ExState of
        0:  if C <> DLE then
                OutByte(C)
            else
                ExState := 1;

        1:  if C <> 0 then
            begin
                V := C;
                Len := reduce_L(V);
                ExState := reduce_F(Len);
            end
            else
            begin
                OutByte(DLE);
                ExState := 0;
            end;

        2:  begin
               Len := Len + C;
               ExState := 3;
            end;

        3:  begin
               op := outpos-reduce_D(V,C);
               for i := 0 to Len+2 do
               begin
                  if op < 0 then
                     OutByte(0)
                  else
                     OutByte(outbuf(.(op mod sizeof(outbuf)).));
                  op := op + 1;
               end;

               ExState := 0;
            end;
   end;
end;


procedure LoadFollowers;
var
   x: pcint;
   i: pcint;
   b: pcint;
begin
   for x := 255 downto 0 do
   begin
      ReadBits(6,b);
      followers(.x.) := '';
      for i := 1 to b do
      begin
         ReadBits(8,b);
         followers(.x.) := followers(.x.) || str(chr(b));
      end;
   end;
end;


(* ----------------------------------------------------------- *)
procedure unReduce;
   /*expand probablisticly reduced data*/

var
   lchar:   pcint;
   lout:    pcint;
   I:       pcint;

begin
   factor := cmethod - 1;
   if (factor < 1) or (factor > 4) then
   begin
      skip_csize;
      return;
   end;

   ExState := 0;
   LoadFollowers;
   lchar := 0;

   while (not zipeof) and (outpos < cusize) do
   begin

      if followers(.lchar.) = '' then
         ReadBits( 8,lout )
      else

      begin
         ReadBits(1,lout);
         if lout <> 0 then
            ReadBits( 8,lout )
         else
         begin
            ReadBits( reduce_B(length(followers(.lchar.))), I );
            lout := ord( followers(.lchar.)(.I+1.) );
         end;
      end;

      if zipeof then
         return;

      Expand( lout );
      lchar := lout;
   end;
end;



(*
 * expand 'shrunk' members of a zipfile
 *
 * UnShrinking
 * -----------
 *
 * Shrinking is a Dynamic Ziv-Lempel-Welch compression algorithm
 * with partial clearing.  The initial code size is 9 bits, and
 * the maximum code size is 13 bits.  Shrinking differs from
 * conventional Dynamic Ziv-lempel-Welch implementations in several
 * respects:
 *
 * 1)  The code size is controlled by the compressor, and is not
 *     automatically increased when codes larger than the current
 *     code size are created (but not necessarily used).  When
 *     the decompressor encounters the code sequence 256
 *     (decimal) followed by 1, it should increase the code size
 *     read from the input stream to the next bit size.  No
 *     blocking of the codes is performed, so the next code at
 *     the increased size should be read from the input stream
 *     immediately after where the previous code at the smaller
 *     bit size was read.  Again, the decompressor should not
 *     increase the code size used until the sequence 256,1 is
 *     encountered.
 *
 * 2)  When the table becomes full, total clearing is not
 *     performed.  Rather, when the compresser emits the code
 *     sequence 256,2 (decimal), the decompressor should clear
 *     all leaf nodes from the Ziv-Lempel tree, and continue to
 *     use the current code size.  The nodes that are cleared
 *     from the Ziv-Lempel tree are then re-used, with the lowest
 *     code value re-used first, and the highest code value
 *     re-used last.  The compressor can emit the sequence 256,2
 *     at any time.
 *
 *)

procedure unShrink;

const
   max_bits =  13;
   init_bits = 9;
   first_ent = 257;
   clear =     256;

var
   cbits:      pcint;
   i:          pcint;
   maxcode:    pcint;
   free_ent:   pcint;
   maxcodemax: pcint;
   offset:     pcint;
   sizex:      pcint;
   finchar:    pcint;
   code:       pcint;
   oldcode:    pcint;
   incode:     pcint;


(* ------------------------------------------------------------- *)
procedure partial_clear;
var
   pr:   pcint;
   cd:   pcint;

begin
   /*mark all nodes as potentially unused*/
   for cd := first_ent to free_ent-1 do
      if prefix_of(.cd.) >= 0
      then prefix_of(.cd.) := -32768 + prefix_of(.cd.) ;

   for cd := first_ent to free_ent-1 do
      begin
   /*unmark those that are used by other nodes*/
      pr := prefix_of(.cd.) and '7fff'x; /*reference to another node?*/
      if pr >= first_ent then           /*flag node as referenced*/
         prefix_of(.pr.) := prefix_of(.pr.) and '7fff'x;
      end;

   /*clear the ones that are still marked*/
   for cd := first_ent to free_ent-1 do
      if (prefix_of(.cd.) < 0)  then
         prefix_of(.cd.) := -1;

   /*find first cleared node as next free_ent*/
   free_ent := first_ent;
   while (free_ent < maxcodemax) and (prefix_of(.free_ent.) <> -1) do
      free_ent := free_ent + 1;
end;


(* ------------------------------------------------------------- *)
begin
   (* decompress the file *)
   maxcodemax := 1 << max_bits;
   cbits := init_bits;
   maxcode := (1 << cbits)- 1;
   free_ent := first_ent;
   offset := 0;
   sizex := 0;

   for i :=1 to hsize do prefix_of(.i.) := -1;
   for code := 255 downto 0 do
   begin
      prefix_of(.code.) := 0;
      suffix_of(.code.) := code;
   end;

   ReadBits(cbits,oldcode);
   if zipeof then
      return;
   finchar := oldcode;

   OutByte(finchar);

   stackp := 0;

   while (not zipeof) do
   begin
      ReadBits(cbits,code);
      if zipeof then
         return;

      while (code = clear) do
      begin
         ReadBits(cbits,code);

         case code of
            1: begin
                  cbits := cbits + 1;
                  if cbits = max_bits then
                     maxcode := maxcodemax
                  else
                     maxcode := (1 << cbits) - 1;
               end;

            2: partial_clear;
         end;

         ReadBits(cbits,code);
         if zipeof then
            return;
      end;


      /*special case for KwKwK string*/
      incode := code;
      if prefix_of(.code.) = -1 then
      begin
         stack(.stackp.) := finchar;
         stackp := stackp + 1;
         code := oldcode;
      end;


      /*generate output characters in reverse order*/
      while (code >= first_ent) do
      begin
         stack(.stackp.) := suffix_of(.code.);
         stackp := stackp + 1;
         code := prefix_of(.code.);
      end;

      finchar := suffix_of(.code.);
      stack(.stackp.) := finchar;
      stackp := stackp + 1;


      /*and put them out in forward order*/
      while (stackp > 0) do
      begin
         stackp := stackp - 1;
         OutByte(stack(.stackp.));
      end;


      /*generate new entry*/
      code := free_ent;
      if code < maxcodemax then
      begin
         prefix_of(.code.) := oldcode;
         suffix_of(.code.) := finchar;
         while (free_ent < maxcodemax) and (prefix_of(.free_ent.) <> -1)
            do free_ent := free_ent + 1;
      end;


      /*remember previous code*/
      oldcode := incode;
   end;
end;



(*
 * ProZip2.int - ZIP file interface library      (2-15-89 shs)
 *
 * This procedure displays the text contents of a specified archive
 * file.  The filename must be fully specified and verified.
 *
 *)


(* ---------------------------------------------------------- *)
procedure extract_member;
var
   b: byte;

begin
   pcbits := 0;
   incnt := 0;
   outpos := 0;
   outcnt := 0;
   zipeof := false;
   Crc32Val := -1;

   if not vm_create(filename,outfd)
   then begin
        WriteLn(' Bypassing: ',filename);
        skip_csize;
        return;
        end;

   case cmethod of
      0:    /*stored*/
            begin
               WriteLn(' Extracting: ',filename,' to ',outfd.filename);
               while (not zipeof) do
               begin
                  ReadByte(b);
                  OutByte(b);
               end;
            end;

      1:    begin
               WriteLn('UnShrinking: ',filename,' to ',outfd.filename);
               UnShrink;
            end;

      2..5: begin
               WriteLn('  Expanding: ',filename,' to ',outfd.filename);
               UnReduce;
            end;

      otherwise Write('Unknown compression method.');
   end;

   if outcnt > 0 then
      vm_write(outfd,outbuf,outcnt);

   vm_close(outfd);
   Crc32Val := NOT Crc32Val;
   If Crc32Val <> InCrc
   then begin
        WriteLn('WARNING - preceeding file fails CRC check.');
        WriteLn('Stored CRC=',InCrc);
        WriteLn('Calculated CRC=',Crc32Val)
        end;

end;

procedure process_local_file_header;
var
   n:             integer;
   rec:           local_file_header;

begin
   n := vm_read_local(zipfn,rec,sizeof(rec));
   filename_length := val_word(rec.$filename_length);
   get_string(filename_length,filename);
   extra_field_length := val_word(rec.$extra_field_length);
   get_string(extra_field_length,extra);
   csize := val_longint(rec.$compressed_size);
   cusize := val_longint(rec.$uncompressed_size);
   cmethod := val_word(rec.$compression_method);
   ctime := val_word(rec.$last_mod_file_time);
   cdate := val_word(rec.$last_mod_file_date);
   InCrc := val_longint(rec.$crc32);
   extract_member;
end;

procedure process_central_file_header;
var
   n:             integer;
   rec:           central_directory_file_header;
   filename:      string(def_string_size);
   extra:         string(def_string_size);
   comment:       string(def_string_size);

begin
   n := vm_read_central(zipfn,rec,sizeof(rec));
   filename_length := val_word(rec.$filename_length);
   get_string(filename_length,filename);
   extra_field_length := val_word(rec.$extra_field_length);
   get_string(extra_field_length,extra);
   file_comment_length := val_word(rec.$file_comment_length);
   get_string(file_comment_length,comment);
end;

procedure process_end_central_dir;
var
   n:             integer;
   rec:           end_central_dir_record;
   comment:       string(def_string_size);

begin
   n := vm_read_ecent(zipfn,rec,sizeof(rec));
   zipfile_comment_length := val_word(rec.$zipfile_comment_length);
   get_string(zipfile_comment_length,comment);
end;

procedure process_headers;
var
   sig:  longint;

begin
   close(zipfn.realfile);
   reset(zipfn.realfile,'name='||zipfn.filename);

   while true do
   begin
      if vm_read_sig(zipfn,sig,sizeof(sig)) <> sizeof(sig) then
         return
      else

      if val_longint(sig) = local_file_header_signature then
         process_local_file_header
      else

      if val_longint(sig) = central_file_header_signature then
         process_central_file_header
      else

      if val_longint(sig) = end_central_dir_signature then
      begin
         process_end_central_dir;
         return;
      end

      else
      begin
         WriteLn('Invalid Zipfile Header',val_longint(sig));
         return;
      end;
   end;

end;

procedure extract_zipfile;
begin
 reset(zipfn.realfile,'name='||zipfn.filename);
 process_headers;
 close(zipfn.realfile);
end;

(*
 * main program
 *
 *)

begin
   myparms := parms;
   termout(output);
   termin(input);
   WriteLn(myparms);
   writeln;
   WriteLn(version);
   WriteLn('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.');
   writeln;
   WriteLn('Converted to VM/CMS operation by John McKown.');
   WriteLn(' Email address: CompuServe Id: 72325,1705');
   writeln;
   if length(myparms) = 0 then
   begin
      WriteLn('Usage:  VMUNZIP file');
      WriteLn('  NOTICE - the filetype is always PCZIP.');
      WriteLn('  It MUST be fixed with an lrecl of 1.');
      halt;
   end;

   i := 1;
   ltoken(i,myparms,zipname);
   zipfn.filename := zipname||'.pczip.a';

   coptions := PROMPT;
   repeat
     token(i,myparms,optstr);
   until (optstr='(') or (optstr=' ');
   while (optstr <> ' ') do
     begin
       token(i,myparms,optstr);
       if optstr <> ' ' then
         if optstr = 'PROMPT' then coptions := PROMPT
         else
           if optstr = 'REPLACE' then coptions := REPLACE
         else
           if optstr = 'BYPASS' then coptions := BYPASS
         else
           WriteLn('Warning - Invalid option:',optstr,' ignored.');
     end;
   extract_zipfile;
end.
