
{$i options.inc}

unit HARDWARE;

interface
   uses common;

   {$i \mlts\hardware\HARDWARE.DCL}

   {$i \mlts\hardware\COUNTERS.DCL}
   {$i \mlts\hardware\COUNTERS.INT}

   {$i \mlts\hardware\VALVES.DCL}
   {$i \mlts\hardware\VALVES.INT}

   {$i \mlts\hardware\MOTION.DCL}
   {$i \mlts\hardware\MOTION.INT}

   {$i \mlts\hardware\ANALOG.DCL}
   {$i \mlts\hardware\TRNSDUCR.DCL}
   {$i \mlts\hardware\ANALOGV3.INT}
   {$i \mlts\hardware\ANLGSTUP.INT}


implementation
   uses crt,misc;

{ I \PCC\SYSTEM\FILEIDS.DCL}
{ I \PCC\SYSTEM\RECORDMN.DCL}
{stubbed}

   {$i \mlts\hardware\COUNTERS.INC}

{$ifdef NO_VALVE_SYSTEM}
   {$i \mlts\hardware\NOVALVES.INC}
{$else}
   {$i \mlts\hardware\NOVALVES.INC}
{$endif}

{$ifdef NO_MOTION}
   {$i \mlts\hardware\NOMOTION.INC}
{$else}
   {$i \mlts\hardware\MOTION.INC}
{$endif}

   {$i \mlts\hardware\ANALOGV3.INC}

   {$i \mlts\hardware\ANLGSTUP.INC}

begin
end.

