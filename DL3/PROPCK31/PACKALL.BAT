rem PackAll.BAT generated by ProSM
echo off
echo. >>PACKALL.LOG
tm "Packall Started" >>PACKALL.LOG
goto F%1
:F

:F0
td propack U:\PCB\MAIN\MSGS 800 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L0 goto exit

:F1
td propack U:\PCB\TOOLS\TOOLS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L1 goto exit

:F2
td propack U:\PCB\SUPPORT\SUPPORT 800 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L2 goto exit

:F3
td propack U:\PCB\AI\AI 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L3 goto exit

:F4
td propack U:\PCB\ST\ST 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L4 goto exit

:F5
td propack U:\PCB\IBM\IBM 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L5 goto exit

:F6
td propack U:\PCB\PHOTO\PHOTO 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L6 goto exit

:F7
td propack U:\PCB\SN-SYSOP\SN-SYSOP 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L7 goto exit

:F8
td propack U:\PCB\SN-ADMIN\SN-ADMIN 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L8 goto exit

:F9
td propack U:\PCB\IL-ADMIN\IL-ADMIN 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L9 goto exit

:F10
td propack U:\PCB\TELIX\TELIX 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L10 goto exit

:F11
td propack U:\PCB\QMODEM\QMODEM 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L11 goto exit

:F12
td propack U:\PCB\ADA\ADA 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L12 goto exit

:F13
td propack U:\PCB\PASCAL\PASCAL 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L13 goto exit

:F14
td propack U:\PCB\C-LANG\C-LANG 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L14 goto exit

:F15
td propack U:\PCB\BASIC\BASIC 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L15 goto exit

:F16
td propack U:\PCB\CD-ROM\CD-ROM 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L16 goto exit

:F17
td propack U:\PCB\ASM\ASM 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L17 goto exit

:F18
td propack U:\PCB\HARDDISK\HARDDISK 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L18 goto exit

:F19
td propack U:\PCB\PKWARE\PKWARE 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L19 goto exit

:F20
td propack U:\PCB\OS2\OS2 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L20 goto exit

:F21
td propack U:\PCB\HAYES\HAYES 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L21 goto exit

:F22
td propack U:\PCB\MODEMING\MODEMING 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L22 goto exit

:F23
td propack U:\PCB\HST\HST 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L23 goto exit

:F24
td propack U:\PCB\UNIX\UNIX 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L24 goto exit

:F25
td propack U:\PCB\DESKTOP\DESKTOP 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L25 goto exit

:F26
td propack U:\PCB\CONSULT\CONSULT 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L26 goto exit

:F27
td propack U:\PCB\DSZ-OMEN\DSZ-OMEN 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L27 goto exit

:F28
td propack U:\PCB\WRITERS\WRITERS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L28 goto exit

:F29
td propack U:\PCB\WORDPROC\WORDPROC 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L29 goto exit

:F30
td propack U:\PCB\INVESTOR\INVESTOR 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L30 goto exit

:F31
td propack U:\PCB\SPACE\SPACE 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L31 goto exit

:F32
td propack U:\PCB\PCBDOORS\PCBDOORS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L32 goto exit

:F33
td propack U:\PCB\SN-DOORS\SN-DOORS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L33 goto exit

:F34
td propack U:\PCB\OPINION\OPINION 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L34 goto exit

:F35
td propack U:\PCB\DESQVIEW\DESQVIEW 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L35 goto exit

:F36
td propack U:\PCB\SHARWARE\SHARWARE 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L36 goto exit

:F37
td propack U:\PCB\VENDORS\VENDORS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L37 goto exit

:F38
td propack U:\PCB\VIRUS\VIRUS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L38 goto exit

:F39
td propack U:\PCB\PATENTS\PATENTS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L39 goto exit

:F40
td propack U:\PCB\RLYCOMMO\RLYCOMMO 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L40 goto exit

:F41
td propack U:\PCB\NETUSERS\NETUSERS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L41 goto exit

:F42
td propack U:\PCB\HARDWARE\HARDWARE 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L42 goto exit

:F43
td propack U:\PCB\TPTC\TPTC 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L43 goto exit

:F44
td propack U:\PCB\QMAIL\QMAIL 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L44 goto exit

:F45
td propack U:\PCB\EZREADER\EZREADER 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L45 goto exit

:F46
td propack U:\PCB\HAMRADIO\HAMRADIO 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L46 goto exit

:F47
td propack U:\PCB\DISABLED\DISABLED 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L47 goto exit

:F48
td propack U:\PCB\COMEDY\COMEDY 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L48 goto exit

:F49
td propack U:\PCB\FORSALE\FORSALE 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L49 goto exit

:F50
td propack U:\PCB\WORKHOME\WORKHOME 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L50 goto exit

:F51
td propack U:\PCB\CP-M\CP-M 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L51 goto exit

:F52
td propack U:\PCB\POLITICS\POLITICS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L52 goto exit

:F53
td propack U:\PCB\RELIGION\RELIGION 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L53 goto exit

:F54
td propack U:\PCB\PHILSPHY\PHILSPHY 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L54 goto exit

:F55
td propack U:\PCB\TRANSATL\TRANSATL 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L55 goto exit

:F56
td propack U:\PCB\BBS-ADS\BBS-ADS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L56 goto exit

:F57
td propack U:\PCB\IL-SYSOP\IL-SYSOP 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L57 goto exit

:F58
td propack U:\PCB\PHOENIX\PHOENIX 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L58 goto exit

:F59
td propack U:\PCB\NETMAIL\NETMAIL 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L59 goto exit

:F60
td propack U:\PCB\BOOSTERS\BOOSTERS 800 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L60 goto exit

:F61
td propack U:\PCB\HM-LANG\HM-LANG 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L61 goto exit

:F62
td propack U:\PCB\HM-SYSOP\HM-SYSOP 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L62 goto exit

:F63
td propack U:\PCB\FORTH\FORTH 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L63 goto exit

:F64
td propack U:\PCB\4DOS\4DOS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L64 goto exit

:F65
td propack U:\PCB\QEDIT\QEDIT 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L65 goto exit

:F66
td propack U:\PCB\SCIENCE\SCIENCE 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L66 goto exit

:F67
td propack U:\PCB\DSP\DSP 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L67 goto exit

:F68
td propack U:\PCB\OOPS\OOPS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L68 goto exit

:F69
td propack U:\PCB\DRWHO\DRWHO 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L69 goto exit

:F70
td propack U:\PCB\SOM-MAIN\SOM-MAIN 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L70 goto exit

:F71
td propack U:\PCB\BRIEF\BRIEF 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L71 goto exit

:F72
td propack U:\PCB\LANTASTI\LANTASTI 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L72 goto exit

:F73
td propack U:\PCB\AMIGA\AMIGA 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L73 goto exit

:F74
td propack U:\PCB\MACINTOS\MACINTOS 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L74 goto exit

:F75
td propack U:\PCB\-UNDEF-\-UNDEF- 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L75 goto exit

:F76
td propack U:\PCB\-UNDEF-\-UNDEF- 200 /eltn360kw >>PACKALL.LOG
if errorlevel 1 goto exit
if L%2 == L76 goto exit

:exit
echo. >>PACKALL.LOG
tm "Packall Ended" >>PACKALL.LOG
echo ---------- >>PACKALL.LOG
