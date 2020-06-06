{************************************************************************}
{ USERSYS.PAS Access To PCBoard 14.5 USERS.SYS File. Coded 1990 B Walter }
{************************************************************************}
{                                                                        }
{ All I ask if you use this code is that I am included in the credits!   }
{ Hope the code helps and if you have any questions I can be reached on  }
{ Salt Air Developers Conference, the SmartNet Pascal Conference or on   }
{ my own system 530 Hudson Street.                                       }
{                                                                        }
{ Hudson Street Public Access (201) 891-3721.  Ask about Visiting SysOp  }
{ privileges...                                                          }
{                                                                        }
{ This unit is obviously not heavily commented,  but is fairly simple to }
{ follow.  The calls are issued as follows:                              }
{                                                                        }
{************************************************************************}
{                                                                        }
{ PROCEDURE GetUserSysInfo ( SysPath : String; VAR Result : Integer );   }
{                                                                        }
{ This function loads all USERS.SYS data into the supplied variables     }
{                                                                        }
{ Parameters:                                                            }
{   SysPath - Complete Path To USERS.SYS                                 }
{   Result  - Returns 0 for successful or a DOS error code for any error }
{                                                                        }
{ Sample usage:                                                          }
{   GetUserSysInfo ('C:\PCB\USERS.SYS',Result);                          }
{   IF Result <> 0 THEN                                                  }
{     BEGIN                                                              }
{       Writeln ('Error ',Result,' reading USERS.SYS!');                 }
{       Halt;                                                            }
{     END;                                                               }
{                                                                        }
{************************************************************************}
{                                                                        }
{ PROCEDURE PutUserSysInfo ( SysPath : String; VAR Result : Integer );   }
{                                                                        }
{ This function saves all variables into an updated USERS.SYS.  It is    }
{ the programmers responsibilty to set the UPDATED flag if the record    }
{ has been modified. (IMPORTANT!)                                        }
{                                                                        }
{ Parameters:                                                            }
{   SysPath - Complete Path To USERS.SYS                                 }
{   Result  - Returns 0 for successful or a DOS error code for any error }
{                                                                        }
{ Sample usage:                                                          }
{   PutUserSysInfo ('C:\PCB\USERS.SYS',Result);                          }
{   IF Result <> 0 THEN                                                  }
{     BEGIN                                                              }
{       Writeln ('Error ',Result,' writing USERS.SYS!');                 }
{       Halt;                                                            }
{     END;                                                               }
{                                                                        }
{************************************************************************}
{                                                                        }
{ FUNCTION GetFlag ( MapNo : Byte; ConfNo : Word ) : Boolean;            }
{                                                                        }
{ This function returns the value of a specified conference bit          }
{                                                                        }
{ Parameters:                                                            }
{   MapNo  - This is the map you wish to inquire about.  Map names are   }
{            preset to existing known values (ie: Map_MailWaiting = 1)   }
{            as specified by CDC.                                        }
{   ConfNo - This is the conference that you wish to check the bit value }
{            of.  Any calls for conferences above the number specified   }
{            as active in PCBSetup will be ignored!                      }
{                                                                        }
{ Sample usage:                                                          }
{   IF GetFlag (Map_MailWaiting,0) THEN                                  }
{     Writeln ('You have mail waiting in the main board!');              }
{                                                                        }
{************************************************************************}
{                                                                        }
{ PROCEDURE PutFlag ( MapNo : Byte; ConfNo : Word; Flag : Boolean );     }
{                                                                        }
{ This function sets the value of a specified conference bit             }
{                                                                        }
{ Parameters:                                                            }
{   MapNo  - This is the map you wish to set.  Map names are preset to   }
{            existing known values (ie: Map_MailWaiting = 1) as          }
{            specified by CDC.                                           }
{   ConfNo - This is the conference that you wish to set the bit value   }
{            of.  Any calls for conferences above the number specified   }
{            as active in PCBSetup will be ignored!                      }
{   Flag   - This is the value you want the conference bit set to        }
{                                                                        }
{ Sample usage:                                                          }
{   PutFlag (Map_ConfSysop,44,TRUE);                                     }
{   Writeln ('You now have conference sysop status in conference #44!'); }
{                                                                        }
{************************************************************************}

{$I-}
UNIT UserSys;

INTERFACE

TYPE
  Char6     = Array[1..6]  OF Char;    { These types can be moved into a }
  Char13    = Array[1..13] OF Char;    { central unit for global usage   }
  Char14    = Array[1..14] OF Char;
  Char15    = Array[1..15] OF Char;
  Char25    = Array[1..25] OF Char;
  Char26    = Array[1..26] OF Char;
  Char31    = Array[1..31] OF Char;

  BitMapPtr = ^BitMap;                 { Bitmap,  Message and TPA info   }
  BitMap    = Array[0..0]  OF Byte;    { is stored on the heap due to    }
                                       { it's dynamic nature             }
  MsgPtrPtr = ^MsgPtr;
  MsgPtr    = Array[0..0]  OF LongInt;

  TPARecPtr = ^TpaRec;
  TPARec    = Array[0..0]  OF Char;

  SysHeader =                          { Documentation for SysHeader and }
    RECORD                             { and SysRecord fields can be     }
      Version         : Word;          { found in the DEVELOP.ZIP file   }
      RecNo           : LongInt;
      RecSize         : Word;
      NumConfs        : Word;
      NumBitMaps      : Word;
      BitMapSize      : Word;
      AppName         : Char15;
      AppVersion      : Word;
      AppStaticSize   : Word;
      AppDynamicSize  : Word;
      AppDataOffset   : LongInt;
      Updated         : Boolean;
    END;

  SysRecord =
    RECORD
      UserName        : Char26;
      City            : Char25;
      Password        : Char13;
      BusinessPhone   : Char14;
      VoicePhone      : Char14;
      LastDateOn      : Word;
      LastTimeOn      : Char6;
      Expert          : Boolean;
      Protocol        : Char;
      UserFlags       : Byte;
      LastDirScan     : Word;
      Security        : Integer;
      TimesOn         : Word;
      PageLength      : Byte;
      FilesUploaded   : Word;
      FilesDownloaded : Word;
      DailyDLBytes    : LongInt;
      UserComment     : Char31;
      SysopComment    : Char31;
      ElapsedTimeOn   : Integer;
      ExpirationDate  : Word;
      ExpiredSecurity : Integer;
      LastConference  : Word;
      BytesDownloaded : LongInt;
      BytesUploaded   : LongInt;
      Delete          : Boolean;
      INFRecNo        : LongInt;
      CurConfH        : Byte;       (* PRODOOR *)
      ExtUserRecNo    : Word;       (* PRODOOR *)
      ProdoorFlags    : Byte;       (* PRODOOR *)
      MailConf        : Byte;       (* PRODOOR *)
      ScratchNum      : Byte;       (* PRODOOR *)
      ProdoorUsed     : Byte;       (* PRODOOR *)
      EarnedDLBytes   : Word;       (* PRODOOR *)
      MessagesRead    : LongInt;
      MessagesLeft    : LongInt;
    END;

CONST
  Map_Registered   = 1;
  Map_Expired      = 2;
  Map_Scan         = 3;
  Map_ConfSysop    = 4;
  Map_MailWaiting  = 5;
  Map_JoinedToday  = 6;
  Map_ScannedToday = 7;

VAR
  SysHead : SysHeader;  { These variables provide access to the USERS.SYS  }
  SysUser : SysRecord;  { info.  BitArea is manipulated through GetFlag    }
  BitArea : BitMapPtr;  { and PutFlag and should NOT be directly accessed! }
  HighMsg : MsgPtrPtr;  { HighMsg^[x] is the LongInt Hi Message Number for }
  TPAInfo : TPARecPtr;  { conf x.  TPAInfo^[x] contains the current TPA    }
                        { record for the online user and is up to YOU to   }
                        { handle since you are writing the door!  <GRIN>   }

PROCEDURE GetUserSysInfo ( SysPath : String; VAR Result : Word );
PROCEDURE PutUserSysInfo ( SysPath : String; VAR Result : Word );
FUNCTION  GetFlag        ( MapNo : Byte; ConfNo : Word ) : Boolean;
PROCEDURE PutFlag        ( MapNo : Byte; ConfNo : Word; Flag : Boolean );

IMPLEMENTATION

PROCEDURE GetUserSysInfo ( SysPath : String; VAR Result : Word );
  VAR
    SysF : File;
    NumR : Word;
    Size : LongInt;
  BEGIN
    Assign (SysF,SysPath);
    Reset  (SysF,1);
    Result := IoResult;
    IF Result <> 0 THEN
      Exit;
    BlockRead (SysF,SysHead,SizeOf (SysHead),NumR);
    Result := IoResult;
    IF Result = 0 THEN
      BEGIN
        BlockRead (SysF,SysUser,SysHead.RecSize,NumR);
        Result := IoResult;
        IF Result = 0 THEN
          BEGIN
            Size := SysHead.NumConfs * SizeOf (LongInt);
            GetMem (HighMsg,Size);
            BlockRead (SysF,HighMsg^,SysHead.NumConfs * SizeOf (LongInt),NumR);
            Result := IoResult;
            IF Result = 0 THEN
              BEGIN
                Size := SysHead.NumBitMaps * SysHead.BitMapSize;
                GetMem (BitArea,Size);
                BlockRead (SysF,BitArea^,Size,NumR);
                Result := IoResult;
                IF Result = 0 THEN
                  BEGIN
                    Size := SysHead.AppStaticSize + SysHead.AppDynamicSize;
                    GetMem (TPAInfo,Size);
                    BlockRead (SysF,TPAInfo^,Size,NumR);
                    Result := IoResult;
                  END;
              END;
          END;
      END;
    Close (SysF);
  END;

PROCEDURE PutUserSysInfo ( SysPath : String; VAR Result : Word );
  VAR
    SysF : File;
    NumW : Word;
    Size : LongInt;
  BEGIN
    Assign (SysF,SysPath);
    Rewrite (SysF,1);
    Result := IoResult;
    IF Result <> 0 THEN
      Exit;
    BlockWrite (SysF,SysHead,SizeOf (SysHead),NumW);
    Result := IoResult;
    IF Result = 0 THEN
      BEGIN
        BlockWrite (SysF,SysUser,SysHead.RecSize,NumW);
        Result := IoResult;
        IF Result = 0 THEN
          BEGIN
            Size := SysHead.NumConfs * SizeOf (LongInt);
            BlockWrite (SysF,HighMsg^,SysHead.NumConfs * SizeOf (LongInt),NumW);
            Result := IoResult;
            IF Result = 0 THEN
              BEGIN
                Size := SysHead.NumBitMaps * SysHead.BitMapSize;
                BlockWrite (SysF,BitArea^,Size,NumW);
                Result := IoResult;
                IF Result = 0 THEN
                  BEGIN
                    Size := SysHead.AppStaticSize + SysHead.AppDynamicSize;
                    BlockWrite (SysF,TPAInfo^,Size,NumW);
                    Result := IoResult;
                  END;
              END;
          END;
      END;
    Close (SysF);
  END;

FUNCTION  GetFlag ( MapNo : Byte; ConfNo : Word ) : Boolean;
  VAR
    Offset : Word;
    ByteNo : Word;
    BitNo  : Word;
    TBool  : Boolean;
  BEGIN
    TBool := FALSE;
    IF ConfNo < SysHead.NumConfs THEN
      BEGIN
        Offset  := (MapNo - 1) * SysHead.BitMapSize;
        ByteNo  := ConfNo SHR 3;
        BitNo   := ConfNo MOD 8;
        TBool   := Odd (BitArea^[Offset + ByteNo] SHR BitNo);
      END;
    GetFlag := TBool;
  END;

PROCEDURE PutFlag ( MapNo : Byte; ConfNo : Word; Flag : Boolean );
  VAR
    Offset : Word;
    ByteNo : Word;
    BitNo  : Word;
  BEGIN
    IF ConfNo >= SysHead.NumConfs THEN
      Exit;
    Offset  := (MapNo - 1) * SysHead.BitMapSize;
    ByteNo  := ConfNo SHR 3;
    BitNo   := ConfNo MOD 8;
    IF Flag THEN
      BitArea^[Offset + ByteNo] := BitArea^[Offset + ByteNo] OR (1 SHL BitNo)
    ELSE
      BitArea^[Offset + ByteNo] := BitArea^[Offset + ByteNo] AND (255 - (1 SHL BitNo));
  END;

BEGIN
END.
