type
  registers = record
                case Integer of
                  0: (AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags: integer);
                  1: (AL,AH,BL,BH,CL,CH,DL,DH: Byte);
              end;
