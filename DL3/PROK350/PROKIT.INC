
(*
 * Copyright 1987, 1991 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * ProKit.INC - include file to provide access to ProKit facilities (3-1-89)
 *
 *)

Uses
   Dos,
   MiniCrt,    {BIOS-only crt functions}
   OpenShare,  {Shared text files}
   MdosIO,     {Dos-level random access files}
   BufIO,      {Buffered record i/o}
   qRead,      {Quick string qReadLn procedure}
   Tools,      {Various utilities}
   ProData,    {ProDoor/pcboard data}
   ProRoot,    {ProKit main support library}
   ProSysf,    {ProKit Status display, function keys, system functions}
   ProScan,    {File display and colorization}
   ProRead,
   ProUtil,    {ProKit utility library #1}
   ProUtil2,   {proKit utility library #2}
   KitInit;    {ProKit initialization/deinit}


{$DEFINE PCB14}         {Compile for PCBoard 14.0 (otherwise 12.1)}

