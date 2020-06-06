
RBBS.NAME$          = "RBBS NAME"                     ' CPC15-1C
SYSOP.FIRST.NAME$   = "SYSOP-FIRST"                   ' CPC15-1C
SYSOP.LAST.NAME$    = "SYSOP-LAST"                    ' CPC15-1C
COM.PORT$           = "COM1:"                         ' CPC15-1C
BAUD.PARITY$        = "PARITY"                        ' CPC15-1C
NETWORK.TYPE        = 999                             ' CPC15-1C
FIRST.NAME$         = "FIRST NAME"                    ' CPC15-1C
LAST.NAME$          = "LAST NAME"                     ' CPC15-1C
CITY.STATE$         = "CITY STATE"                    ' CPC15-1C
GR                  = 333                             ' CPC15-1C
USER.SECURITY.LEVEL = 111                             ' CPC15-1C
TIME.REMAINING      = 120                             ' CPC15-1C

OPEN "O",2,"DORINFO" + "1" + ".DEF"                            ' CPC15-1C
PRINT #2,RBBS.NAME$                                            ' CPC15-1C
PRINT #2,SYSOP.FIRST.NAME$                                     ' CPC15-1C
PRINT #2,SYSOP.LAST.NAME$                                      ' CPC15-1C
PRINT #2,COM.PORT$                                             ' CPC15-1C
PRINT #2,BAUD.PARITY$                                          ' CPC15-1C
PRINT #2,NETWORK.TYPE                                          ' CPC15-1C
PRINT #2,FIRST.NAME$                                           ' CPC15-1C
PRINT #2,LAST.NAME$                                            ' CPC15-1C
PRINT #2,CITY.STATE$                                           ' CPC15-1C
PRINT #2,GR                                                    ' CPC15-1C
PRINT #2,USER.SECURITY.LEVEL                                   ' CPC15-1C
PRINT #2,TIME.REMAINING                                        ' CPC15-1C
PRINT #2,"POSSIBLY 2 OTHER THINGS"
CLOSE #2


