@echo off
rem ** Batch file to create a new up-to-date BARDFILE.ZIP master
rem ** file list for downloading by the user.
proecho %1 ~Please be patient, this takes awhile..
proecho %1 ~Deleting old BARDFILE.ZIP..
del h:\uploads\bardfile.zip
if exist h:\uploads\bardfile.zip goto error
proecho %1 ~Copying Main Board Directories to TEMP directory..
pcbcopy F:\BBS\DIRS\4DOS F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ASP F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\AUTHOR F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR1 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR3 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR4 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR5 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR6 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR7 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR8 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR9 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR10 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR11 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR12 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR13 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR15 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR16 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR17 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR18 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR19 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR20 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR21 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR23 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR24 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR25 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR26 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR31 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR32 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR33 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR34 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR35 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR36 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR37 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR38 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR39 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR40 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR41 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR42 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR43 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR46 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR47 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR48 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR49 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR50 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR51 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR60 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR61 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR62 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR64 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR66 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR70 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR72 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR73 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\DIR74 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\DIR80 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\PBASIC F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\QBASIC F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\UPLOADS F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\MUSIC04 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\MUSIC05 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\MUSIC06 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\MUSIC07 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\MUSIC08 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\MUSIC09 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\MUSIC010 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\MUSIC011 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\MUSIC012 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\MUSIC013 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\OFFLINE F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\SPEAK1 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\SPEAKUP F:\PRODOOR\TEMP
proecho %1 ~Copying Adult Directories to TEMP directory..
pcbcopy H:\BULLET\ADULT.FRM F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ADULT F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ADULT1 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ADULT2 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\ADULT3 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ADULT4 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ADULT5 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ADULT6 F:\PRODOOR\TEMP
proecho %1 .
pcbcopy F:\BBS\DIRS\ADULT7 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ADULT8 F:\PRODOOR\TEMP
pcbcopy F:\BBS\DIRS\ADULT9 F:\PRODOOR\TEMP
pcbcopy H:\BULLET\BLT6 F:\PRODOOR\TEMP\ORDER.FRM
proecho %1 .

cls
proecho %1 ~Creating BARDFILE.ZIP...
zip -! h:\uploads\bardfile f:\prodoor\temp\*.* -m
echo fl bardfile.zip > f:\prolon%pcbnode%\prodoor.cmd
proecho %1 ~~Done..  Please download BARDFILE.ZIP...~
goto end

:error
proecho %1 ~~Error!  BARDFILE.ZIP being downloaded on another node
proecho %1 ~Cannot delete, try again later..~~

:end
