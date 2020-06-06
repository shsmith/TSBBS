
(*
 * stp - Smalltalk to Pascal translator
 *
 * s. h. smith, 11-mar-86
 *
 *)



(*$V+       compiler option to not require string parameters
 *          to match declared length; default +  *)

(*$R+       compiler option to check ranges and subscripts; default -  *)

(*$D-       compiler option to allow file buffering to devices; default +  *)



program smalltalk_to_pascal (infile, outfile, display, keyboard);


{$I data.inc}      {data declarations}
{$I utility.inc}   {utility procedures}
{$I symtable.inc}  {symbol table maintenance}
{$I scanner.inc}   {lexical scanner}
{$I genexpr.inc}   {code generator for expressions}
{$I gendecl.inc}   {code generator for declarations}
{$I parsexpr.inc}  {parser for method expressions}
{$I parsmeth.inc}  {parser for method declarations}
{$I parsdecl.inc}  {parser for declaration sections}
{$I inits.inc}     {initialization}

begin                { main block }
   initialize;
   openfiles;

   ch := ' ';        { get the first character for the scanner }
   gettk;            { get the first token for the parser }

   while tk.code <> end_of_file do
      parse_declaration;

   closefiles;
end.

