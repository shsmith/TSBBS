
(*
 * Example of PASCAL/MT+
 *)

MODULE MENUS;

CONST
{$I MENUS.CON}

VAR
    DUMMY_B:      BOOLEAN;
    DATE:         STRING[12];
    REVS:         BYTE;
    WAIT_PERIOD:  LONGINT;
    S:            STRING;   {default length?}
    IN_TOP_LEVEL: EXTERNAL BOOLEAN;
    MNS:          EXTERNAL ARRAY [1..200] OF STRING[40];
    L_MARGIN:     EXTERNAL BYTE;

    (*------- notice the external declaration -------*)

    EXTERNAL PROCEDURE PUTCHRS(CH: CHAR ; CNT: INTEGER);
    EXTERNAL FUNCTION WAIT_FOR_CHAR: CHAR;
    EXTERNAL FUNCTION GET_CHR_AND_MESSAGES: CHAR;
    EXTERNAL FUNCTION SYS_TICK: LONGINT;
    EXTERNAL PROCEDURE ANSWER;

    (*------- notice the external declaration in an overlay #1 -------*)

    EXTERNAL  [1] PROCEDURE EDIT;
    EXTERNAL  [2] PROCEDURE PREPARE;
    EXTERNAL  [2] PROCEDURE SAVE_SYS_PARMS;
    EXTERNAL  [5] PROCEDURE LOAD_MSG;
    EXTERNAL  [5] PROCEDURE SAVE_MSG;
    EXTERNAL  [5] PROCEDURE KILL_MSG;
    EXTERNAL  [5] PROCEDURE VIEW_MSG;

PROCEDURE SET_DATE(S: STRING);
BEGIN
  DATE := S;
  ATTR := HILT; 
  XYGOTO(60,1); 
  WRITE([ADDR(PUT_CHR)],DATE);
  ATTR := NORMAL;
END;

PROCEDURE SWITCH(CH: CHAR);
VAR
  C: BYTE;
BEGIN
  C := (C & $FF00) ! ORD(CH);
  (*----           ^ this is a bit-wise OR ----*)
  (*----  ^ this is a bit-wise AND ----*)
END;

{$E-}
{$E+}

MODEND.
