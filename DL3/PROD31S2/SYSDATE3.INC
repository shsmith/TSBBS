
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

function yymmdd_date: string8;   {format: yy-mm-dd}
begin
   yymmdd_date := system_yy + '-' + system_mm + '-' + system_dd;
end;

