
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

(*
 * General string type declarations
 *
 *)

(* ------------------------------------------------------------ *)
const
   namesizes = 50;      {size of filenames}

type
   filenames  = string[namesizes];
   anystring  = string[128];
   longstring = string[255];

   string2   = string[2];
   string4   = string[4];
   string5   = string[5];
   string6   = string[6];
   string8   = string[8];
   string10  = string[10];
   string12  = string[12];
   string13  = string[13];
   string20  = string[20];
   string25  = string[25];
   string30  = string[30];
   string40  = string[40];
   string45  = string[45];
   string65  = string[65];
   string72  = string[72];
   string80  = string[80];
   string160 = string[160];
   string240 = string[240];
   string255 = string[255];

   char2  = array[1..2] of char;
   char3  = array[1..3] of char;
   char4  = array[1..4] of char;
   char5  = array[1..5] of char;
   char6  = array[1..6] of char;
   char7  = array[1..7] of char;
   char8  = array[1..8] of char;
   char9  = array[1..9] of char;
   char10 = array[1..10] of char;
   char11 = array[1..11] of char;
   char12 = array[1..12] of char;
   char13 = array[1..13] of char;
   char14 = array[1..14] of char;
   char15 = array[1..15] of char;
   char16 = array[1..16] of char;
   char19 = array[1..19] of char;
   char24 = array[1..24] of char;
   char25 = array[1..25] of char;
   char26 = array[1..26] of char;
   char28 = array[1..28] of char;
   char30 = array[1..30] of char;
   char39 = array[1..39] of char;
   char40 = array[1..40] of char;
   char32 = array[1..32] of char;
   char35 = array[1..35] of char;
   char45 = array[1..45] of char;
   char49 = array[1..49] of char;
   char128 = array[1..128] of char;

