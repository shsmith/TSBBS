* THIS PROGRAM IS DESIGNED TO PRINT FILES TO YOUR CMS VIRTUAL PRINTER.  APR00010
* IT ASSUMES THAT THE FILE TO BE PRINTED IS IN STANDARD 7-BIT ASCII.    APR00020
* THIS PROGRAM CANNOT PRINT IBM PC GRAPHICS.                            APR00030
* THIS PROGRAM CANNOT INTERPRET ANY PRINTER CONTROL CHARACTERS OTHER    APR00040
* THAN CARRIAGE RETURN, LINE FEED AND FORM FEED. ALL OTHER CONTROL      APR00050
* CHARACTERS WILL BE REPLACED WITH A BLANK. IN PARTICULAR, THIS MEANS   APR00060
* THAT THE BACKSPACE CHARACTER CANNOT BE USED FOR EITHER UNDERLINING    APR00070
* OR OVERSTRIKING.                                                      APR00080
*                                                                       APR00090
* THIS PROGRAM IS COPYRIGHT (C) 1989 BY JOHN A. MCKOWN                  APR00100
* YOU MAY USE THIS PROGRAM AND ANY MODIFICATIONS THERETO FOR            APR00110
* ANY PURPOSE SO LONG AS YOU DO NOT CHARGE FOR THE CODE. YOU            APR00120
* MAY CHARGE A SMALL HANDLING FEE FOR MEDIA, POSTAGE, ETC. SAID         APR00130
* FEE MAY NOT BE GREATER THAN $5.00 MORE THAN THE COST OF MATERIALS.    APR00140
*                                                                       APR00150
* THIS PROGRAM WAS WRITTEN AND TESTED ON VM/HPO 4.2 USING ASSEMBLER H   APR00160
* IT MAY BE ASSEMBLED WITH EITHER THE HASM OR ASSEMBLE COMMAND          APR00170
*                                                                       APR00180
* SHOULD YOU DESIRE TO SAVE THE OUTPUT FROM THIS COMMAND TO A DISK      APR00190
* FILE, YOU CAN DO SO AS FOLLOWS:                                       APR00200
* 1. SP PRT * NOCONT   CLOSE                                            APR00210
* 2. APRINT FILENAME FILETYPE FILEMODE                                  APR00220
* 3. DEPRINT FILENAME FILETYPE                                          APR00230
*                                                                       APR00240
* E.G. YOU HAVE A FILE ON YOUR 'A' DISK WITH THE NAME 'TEMP FILE1 A'.   APR00250
* THIS FILE IS IN ASCII FORMAT. ISSUE THE FOLLOWING THREE COMMANDS      APR00260
* SP PRT * NOCONT CLOSE                                                 APR00270
* APRINT TEMP FILE1 A                                                   APR00280
* DEPRINT TEMP PRINT                                                    APR00290
*                                                                       APR00300
R0       EQU   0                                                        APR00310
R1       EQU   1                                                        APR00320
R2       EQU   2                                                        APR00330
R3       EQU   3                                                        APR00340
R4       EQU   4                                                        APR00350
R5       EQU   5                                                        APR00360
R6       EQU   6                                                        APR00370
R7       EQU   7                                                        APR00380
R8       EQU   8                                                        APR00390
R9       EQU   9                                                        APR00400
R10      EQU   10                                                       APR00410
R11      EQU   11                                                       APR00420
R12      EQU   12                                                       APR00430
R13      EQU   13                                                       APR00440
R14      EQU   14                                                       APR00450
R15      EQU   15                                                       APR00460
APRINT   CSECT                                                          APR00470
*                                                                       APR00480
APRINT   CSECT                                                          APR00490
         USING *,R11                                                    APR00500
         SAVE  (14,12),,APRINT                                          APR00510
         LR    R11,R15                                                  APR00520
         CNOP  0,4                                                      APR00530
         BAL   R1,*+76                                                  APR00540
         DC    18A(0)                                                   APR00550
         ST    R13,4(,R1)                                               APR00560
         ST    R1,8(,R13)                                               APR00570
         LR    R13,R1                                                   APR00580
         B     GO                                                       APR00590
GOBACK   DS    0H                                                       APR00600
         LINEDIT TEXT='SP PRT CLOSE',                                  XAPR00610
               DOT=NO,                                                 XAPR00620
               DISP=CPCOMM                                              APR00630
         L     R13,4(,R13)                                              APR00640
         XC    8(4,R13),8(R13)                                          APR00650
         RETURN (14,12),T,RC=0                                          APR00660
         LTORG *                                                        APR00670
GO       DS    0H                                                       APR00680
         L     R1,4(,R13)                                               APR00690
         L     R1,24(,R1)                                               APR00700
         CLI   8(R1),X'FF'        FENCE?                                APR00710
         BE    ERROR1             YES, NO NAME                          APR00720
         MVC   FNAME,8(R1)        MOVE IN FILE NAME                     APR00730
         CLI   16(R1),X'FF'       FENCE?                                APR00740
         BE    OK1                YES, OK DEFAULT FILETYPE TO ASCII     APR00750
         MVC   FTYPE,16(R1)       MOVE IN FILE TYPE                     APR00760
         CLI   24(R1),X'FF'       FENCE?                                APR00770
         BE    OK1                YES, USE DEFAULT FILE MODE OF *       APR00780
         CLI   26(R1),C' '                                              APR00790
         BNE   ERROR2                                                   APR00800
OK1      DS    0H                                                       APR00810
         FSSTATE FSCB=MYFSCB,FORM=E,ERROR=ERROR3                        APR00820
         ST    R1,MYFST                                                 APR00830
         MVC   FMODE(2),24(R1)                                          APR00840
         L     R2,32(,R1)         GET LRECL                             APR00850
         LA    R2,7(,R2)                                                APR00860
         SRL   R2,3               GET CLOSE MULT OF 8 >= LRECL          APR00870
         ST    R2,BUFSIZE                                               APR00880
         LR    R0,R2                                                    APR00890
         DMSFREE DWORDS=(0),ERR=ERROR5                                  APR00900
         ST    R1,BUFFER@                                               APR00910
         ST    R1,CBUFF@                                                APR00920
         LR    R3,R1                                                    APR00930
         FSOPEN FSCB=MYFSCB,FORM=E,ERROR=ERROR4,BUFFER=(3)              APR00940
         LA    R4,LINEBUF+1                                             APR00950
         ST    R4,LINEBUF@                                              APR00960
         LINEDIT TEXT='SP PRT CLOSE',                                  XAPR00970
               DOT=NO,                                                 XAPR00980
               DISP=CPCOMM                                              APR00990
DOREAD   DS    0H                                                       APR01000
         FSREAD FSCB=MYFSCB,FORM=E,ERROR=EOF                            APR01010
         ST    R0,NUMBYTES                                              APR01020
         LR    R2,R0                                                    APR01030
         L     R3,BUFFER@                                               APR01040
XLATE    DS    0H                                                       APR01050
         NI    0(R3),X'7F'        KILL HIGH BIT                         APR01060
         CLI   0(R3),X'20'        TEST FOR CNTL CHAR                    APR01070
         BL    CTLCHAR                                                  APR01080
STORCHAR DS    0H                                                       APR01090
         SLR   R9,R9                                                    APR01100
         IC    R9,0(,R3)                                                APR01110
         IC    R9,XLATETAB(R9)                                          APR01120
         STC   R9,0(,R4)                                                APR01130
         LA    R4,1(,R4)                                                APR01140
         CL    R4,=A(LINEBUF+L'LINEBUF)                                 APR01150
         BNL   SEGMENT                                                  APR01160
         ST    R4,LINEBUF@                                              APR01170
         MVI   SEENCR,0                                                 APR01180
XLATEC   DS    0H                                                       APR01190
         BCT   R2,XLATE                                                 APR01200
         B     DOREAD                                                   APR01210
CTLCHAR  DS    0H                                                       APR01220
         CLI   0(R3),X'0A'        LINEFEED?                             APR01230
         BE    LF                                                       APR01240
         CLI   0(R3),X'0D'        CARRIAGE RETURN?                      APR01250
         BE    CR                                                       APR01260
         CLI   0(R3),X'0C'        FORM FEED?                            APR01270
         BE    FF                                                       APR01280
         MVI   0(R3),X'20'                                              APR01290
         B     STORCHAR                                                 APR01300
LF       DS    0H                                                       APR01310
         CLI   SEENCR,1                                                 APR01320
         MVI   SEENCR,0                                                 APR01330
         BE    XLATEC                                                   APR01340
PUTL     DS    0H                                                       APR01350
         SL    R4,=A(LINEBUF)                                           APR01360
         PRINTL LINEBUF,(4)                                             APR01370
         MVI   LINEBUF,C' '                                             APR01380
         MVC   LINEBUF+1(L'LINEBUF-1),LINEBUF                           APR01390
         LA    R4,LINEBUF+1                                             APR01400
         ST    R4,LINEBUF@                                              APR01410
         B     XLATEC                                                   APR01420
CR       DS    0H                                                       APR01430
         MVI   SEENCR,1                                                 APR01440
         B     PUTL                                                     APR01450
FF       DS    0H                                                       APR01460
         MVI   SEENCR,0                                                 APR01470
         SL    R4,=A(LINEBUF)                                           APR01480
         PRINTL LINEBUF,(4)                                             APR01490
         MVI   LINEBUF,C' '                                             APR01500
         MVC   LINEBUF+1(L'LINEBUF-1),LINEBUF                           APR01510
         LA    R4,LINEBUF+1                                             APR01520
         ST    R4,LINEBUF@                                              APR01530
         MVI   LINEBUF+0,C'1'                                           APR01540
         B     XLATEC                                                   APR01550
SEGMENT  DS    0H                                                       APR01560
         LINEDIT TEXT='NOTICE - LINE EXCEEDED 133 CHARACTERS.'          APR01570
         LINEDIT TEXT='LINE SEGMENTED INTO MULTIPLE LINES.'             APR01580
         B     PUTL                                                     APR01590
ERROR1   DS    0H                                                       APR01600
         LINEDIT TEXT='NO FILE NAME SPECIFIED.'                         APR01610
         B     GOBACK                                                   APR01620
ERROR2   DS    0H                                                       APR01630
         LINEDIT TEXT='INVALID FILE MODE SPECIFIED.'                    APR01640
         B     GOBACK                                                   APR01650
ERROR3   DS    0H                                                       APR01660
         C     R15,=F'20'                                               APR01670
         BE    ERROR3A                                                  APR01680
         C     R15,=F'24'                                               APR01690
         BE    ERROR2                                                   APR01700
         C     R15,=F'28'                                               APR01710
         BE    ERROR3B                                                  APR01720
         C     R15,=F'36'                                               APR01730
         BE    ERROR3C                                                  APR01740
         LR    R10,R15                                                  APR01750
         LINEDIT TEXT='INVALID RETURN CODE FROM FSSTATE=...',          XAPR01760
               SUB=(DEC,(10))                                           APR01770
         B     GOBACK                                                   APR01780
ERROR3A  DS    0H                                                       APR01790
         LINEDIT TEXT='INVALID CHARACTER IN FILEID'                     APR01800
         B     GOBACK                                                   APR01810
ERROR3B  DS    0H                                                       APR01820
         LINEDIT TEXT='FILE NOT FOUND'                                  APR01830
         B     GOBACK                                                   APR01840
ERROR3C  DS    0H                                                       APR01850
         LINEDIT TEXT='DISK NOT ACCESSED'                               APR01860
         B     GOBACK                                                   APR01870
         SPACE                                                          APR01880
ERROR4   DS    0H                                                       APR01890
         LR    R10,R15                                                  APR01900
         LINEDIT TEXT='FSOPEN RC=...',SUB=(DEC,(10))                    APR01910
         B     GOBACK                                                   APR01920
ERROR5   DS    0H                                                       APR01930
         LR    R10,R15                                                  APR01940
         LINEDIT TEXT='DMSFREE RC=...',SUB=(DEC,(10))                   APR01950
         B     GOBACK                                                   APR01960
EOF      DS    0H                                                       APR01970
         C     R15,=F'12'                                               APR01980
         BE    GOBACK                                                   APR01990
         LR    R10,R15                                                  APR02000
         LINEDIT TEXT='FSREAD RC=...',SUB=(DEC,(10))                    APR02010
         B     GOBACK                                                   APR02020
LINEBUF@ DC    A(0)                                                     APR02030
BUFSIZE  DC    F'0'                                                     APR02040
BUFFER@  DC    A(0)                                                     APR02050
CBUFF@   DC    A(0)                                                     APR02060
NUMBYTES DC    F'0'                                                     APR02070
MYFST    DC    A(0)                                                     APR02080
MYFSCB   FSCB  'X ASCII *',FORM=E                                       APR02090
FNAME    EQU   MYFSCB+8,8,C'C'                                          APR02100
FTYPE    EQU   MYFSCB+16,8,C'C'                                         APR02110
FMODE    EQU   MYFSCB+24,2,C'C'                                         APR02120
LINEBUF  DC    CL133'1'                                                 APR02130
SEENCR   DC    X'00'                                                    APR02140
         LTORG                                                          APR02150
XLATETAB EQU   *                                                        APR02160
*                 0 1 2 3 4 5 6 7 8 9 A B C D E F                       APR02170
         DC    X'00010203372D2E2F1605250B0C0D0E0F' 0                    APR02180
         DC    X'101112133C3D322618193F271C1D1E1F' 1                    APR02190
         DC    X'405A7F7B5B6C507D4D5D5C4E6B604B61' 2             A29569 APR02200
         DC    X'F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F' 3                    APR02210
         DC    X'7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6' 4                    APR02220
         DC    X'D7D8D9E2E3E4E5E6E7E8E9ADE0BD5F6D' 5             A29569 APR02230
         DC    X'79818283848586878889919293949596' 6             A29569 APR02240
         DC    X'979899A2A3A4A5A6A7A8A98B4F9BA107' 7             A29569 APR02250
         DC    X'00010203372D2E2F1605250B0C0D0E0F' 8                    APR02260
         DC    X'101112133C3D322618193F271C1D1E1F' 9                    APR02270
         DC    X'405A7F7B5B6C507D4D5D5C4E6B604B61' A             A29569 APR02280
         DC    X'F0F1F2F3F4F5F6F7F8F97A5E4C7E6E6F' B                    APR02290
         DC    X'7CC1C2C3C4C5C6C7C8C9D1D2D3D4D5D6' C                    APR02300
         DC    X'D7D8D9E2E3E4E5E6E7E8E9ADE0BD5F6D' D             A29569 APR02310
         DC    X'79818283848586878889919293949596' E             A29569 APR02320
         DC    X'979899A2A3A4A5A6A7A8A98B4F9BA107' F             A29569 APR02330
         END   APRINT                                                   APR02340
