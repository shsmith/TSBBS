
Program test;

{test source for tptc's translation of declarations}

  Type
    CompDataRec = Record
                    Opr : Byte; { Operator }
                    Case T : Integer Of
                      0 : (Dat1, Dat2 : Integer);
                      1 : (Str1, Str2 : Byte);
                      2 : (Byt1, Byt2 : Byte);
                      3 : (Int1, Int2 : Integer);
                      4 : (Real1, Real2 : Real);
                      5, 6 : (Bool1, Bool2 : Boolean);
                  End;

    DateRec = Record
                Year : Integer;
                Month : Integer;
                Day : Integer;
              End;

    BuffTyp = Record
                Status : Integer;
                Name1 : Integer;
                name2 : Integer;
                name3 : Boolean;
                name4 : Integer;
                name5 : Real;
                name6 : Real;
                name7 : Array[1..3] Of Integer;
                Birth : DateRec;
                LastIn : DateRec;
                Recall : DateRec;
              End;


    DateArray = array[1..12] of DateRec;
    History = array[1..30] of DateArray;
        
  Procedure ClearBuff(Var Buff : BuffTyp;
                      RecN : Integer);
    Const
      BlankBuf : BuffTyp =
      (Status : 0;
      Name1 : 0;
      name2 : 0;
      name3 : False;
      name4 : 0;
      name5 : 0.0;
      name6 : 0.0;
      name7 : (1, 0, 0);
      Birth : (Year : 0; Month : 0; Day : 0);
      LastIn : (Year : 0; Month : 0; Day : 0);
      Recall : (Year : 0; Month : 0; Day : 0));
    Begin
      {body of clearbuff}
      Buff := BlankBuf;
    End;

  Begin
    {main block}
  End.

