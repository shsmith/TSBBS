
(*
 * sitv - verbose listing of Macintosh StuffIt files
 *
 * S.H.Smith, 7-10-89
 *
 *)

uses DOS, MdosIO;

type
   OSType = longint;
   sigtype = array[1..4] of char;
   str63 = string[63];

   sitHdr = record
      signature:     sigtype;    {'SIT!'}
      numFiles:      word;       {files in archive}
      arcLength:     longint;    {length of entire file, including header}
      signature2:    sigtype;    {'rLau'}
      version:       byte;       {version number}
      reserved:      array[1..7] of char;
   end;

   fileHdr = record
      compRMethod:   byte;       {resource compression method}
      compDMethod:   byte;       {data compression method}
      fName:         str63;      {a STR63}
      fType:         sigtype;    {file type}
      fCreator:      sigtype;    {er...}
      fndrFlags:     integer;    {finder flags}
      createDate:    longint;
      modDate:       longint;
      rsrcLength:    longint;    {decompressed lengths}
      dataLength:    longint;
      compRLength:   longint;    {compressed lengths}
      compDLength:   longint;
      rsrcCRC:       word;       {crc of resource}
      dataCRC:       word;       {crc of data}
      reserved:      array[1..6] of char;
      hdrCRC:        word;       {crc of file header}
   end;


(* file format is:
	sitArchiveHdr
		file1Hdr
			file1RsrcFork
			file1DataFork
		file2Hdr
			file2RsrcFork
			file2DataFork
		.
		.
		.
		fileNHdr
			fileNRsrcFork
			fileNDataFork
*)

const
   {compression methods}
   noComp = 0;        {just read each byte and write it to archive}
   rleComp = 1;       {RLE compression}
   lzwComp = 2;       {LZW compression}
   hufComp = 3;       {Huffman compression}

   encrypted = 16;    {bit set if encrypted.  ex: encrypted+lpzComp}
   startFolder = 32;  {marks start of a new folder}
   endFolder = 33;    {marks end of the last folder "started"}

{all other numbers are reserved}


procedure swapw(var w: word);
var
   b: array[1..2] of byte absolute w;
   t: byte;
begin
   t := b[1];
   b[1] := b[2];
   b[2] := t;
end;

procedure swapl(var l: longint);
var
   b: array[1..4] of byte absolute l;
   t: byte;
begin
   t := b[1];
   b[1] := b[4];
   b[4] := t;
   t := b[2];
   b[2] := b[3];
   b[3] := t;
end;

procedure error(why: string);
begin
   writeln(why);
   halt(1);
end;

function fmtDate(dt: longint): string;
begin
   fmtDate := 'mm-dd-yy';
end;

function fmtTime(dt: longint): string;
begin
   fmtTime := 'hh:mm:ss';
end;

var
   fd:         dos_handle;
   sitH:       sitHdr;
   fileH:      fileHdr;
   arc:        str63;
   ok:         boolean;
   try:        integer;

begin
   writeln;
   if paramcount <> 1 then
      error('Usage:  sitv FILE.SIT >OUTFILE');

   arc := paramstr(1);
   if pos('.',arc) = 0 then
      arc := arc + '.sit';

   fd := dos_open(arc,open_read);
   if fd = dos_error then
      error('Cannot open: '+arc);

   try := 0;
   repeat
      dos_lseek(fd,try*sizeof(sigtype),seek_start);
      if dos_read(fd,sitH,sizeof(sitH)) <> sizeof(sitH) then
         error('Error reading file header');
      ok := (sitH.signature = 'SIT!') and (sitH.signature2 = 'rLau');
      inc(try);
   until ok or (try > 100);

   if not ok then
      error('This is not a StuffIt file! (incorrect signature)');

   swapw(sitH.numFiles);
   swapl(sitH.arcLength);
   writeln('Archive contains ',sitH.numFiles,' member file(s).');

   writeln;
   writeln('                      File   Rsrc.   Data');
   writeln('File Name             Type   Size    Size     Date      Time ');
   writeln('--------------------  ----  ------  ------  --------  --------');

   ok := dos_read(fd,fileH,sizeof(fileH)) = sizeof(fileH);
   while ok do
   begin
      swapl(fileH.createDate);
      swapl(fileH.modDate);
      swapl(fileH.rsrcLength);
      swapl(fileH.dataLength);
      swapl(fileH.compRLength);
      swapl(fileH.compDLength);
      swapw(fileH.rsrcCRC);
      swapw(fileH.dataCRC);
      swapw(fileH.hdrCRC);

      if (fileH.rsrcLength+fileH.dataLength) > 0 then

      writeln(fileH.fName,'':20-length(fileH.fName),'  ',
              fileH.fType,'  ',
              fileH.rsrcLength:6,'  ',
              fileH.dataLength:6,'  ',
              fmtDate(fileH.modDate),'  ',
              fmtTime(fileH.modDate));
(***
              fileH.compRMethod:3,'/',
              fileH.compDMethod:3);
***)
      dos_lseek(fd,fileH.compRLength+fileH.compDLength,seek_cur);
      ok := dos_read(fd,fileH,sizeof(fileH)) = sizeof(fileH);
   end;

   dos_close(fd);
   halt(0);
end.

