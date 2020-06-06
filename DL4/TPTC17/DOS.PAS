
{$D-,I-,S-}

unit Dos;

interface

const
  FCarry     = $0001;
  FParity    = $0004;
  FAuxiliary = $0010;
  FZero      = $0040;
  FSign      = $0080;
  FOverflow  = $0800;

type
  Registers = record
                case Integer of
                  0: (AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags: Word);
                  1: (AL,AH,BL,BH,CL,CH,DL,DH: Byte);
              end;

   procedure Intr(IntNo: Byte; var Regs: Registers) as Pintr;
   procedure MsDos(var Regs: Registers) as Pmsdos;


implementation

   procedure Intr(IntNo: Byte; var Regs: Registers) as Pintr;
   begin
\     int86(intno,regs);
   end;

   procedure MsDos(var Regs: Registers) as Pmsdos;
   begin
\     int86(0x21,regs);
   end;

end.

