� 
Disk Error Monitor v1.0 04/30/90
Copyright 1990 Samuel H. Smith; ALL RIGHTS RESERVED

$                                                                                                                                                                                                                                                                                                                                                                                                                         .�>_ u��t��t��t��
t��t
��t.�.`.�_S.�d�.��f.���.��..Ǉ�  [�.�`s%.��S.�d�.���.�dC��2|3�.�d[.�_ � This program can be freely distributed so long as it is not modified
or sold for profit.  If you find that this program is valuable, you
can send me a donation for what you think it is worth.  I suggest
about 10 dollars.

Send your registrations to:        The Tool Shop BBS
   Samuel H. Smith                 (602) 264-3969 (2400) - Free node
   5119 N. 11th Ave., #332         (602) 279-2673 (HST 9600)
   Phoenix AZ 85013                (602) 279-0230 (HAYES 9600)

IN NO EVENT WILL I BE LIABLE TO YOU FOR ANY DAMAGES, INCLUDING ANY
LOST PROFITS,  LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL
DAMAGES ARISING OUT OF YOUR USE OR INABILITY TO USE THE PROGRAM, OR
FOR ANY CLAIM BY ANY OTHER PARTY.

Usage:  DERMON/I     ;install in memory.
        DERMON/U     ;un-install.
        DERMON/C     ;display disk error counters.
        DERMON/Z     ;zero error counters.
$DERMON installed.
$DERMON unInstalled.
$Other programs loaded after DERMON -- cannot unInstall.
$Already loaded!
$DERMON is not resident.  Use DERMON/I first.
$��6� �<t.</t<-t��$�<Zu�i�1<Cu��(<Uu� �<Iu�$��z �� < �Mu�~�h .�
� L�!��V �3 �_t+�5�!�`�b���%�!�, �I�!���( �~�'뵌�H����<$t&:uC���H��u�@�S�	�![�RS�д�![Z�R=  t
P� ���XH��Z����qu#�Ì�+Í%=Y }&�`�%�!�I�!����
Disk Error Monitor Status:$disk errors.
$
Function  Drive  Head  Cylinder  Sector  Count    Error Description
--------  -----  ----  --------  ------  -----  ---------------------------
$����quE��������O���>� t+�������3ۃ�� t�F �} ���\��CC��d|����� Read   $ Write  $ Verify $ Seek   $ Unknown$��f��	��t)��
t$��	��t��t��	��t��	��t��	�/�ø �>���.��<r$A� ��:��� � ���.2���� �����2���������h� ������2��$?2��S� �����f2��D�Bad command$Address mark not found$Write attempted on write-protected disk$Sector not found$Reset failed$Diskette changed$Parameter act. failed$DMA overrun$	DMA across 64K boundary$
Bad sector detected$Bad track detected$Unsupported track$Invalid number of sectors on format$Control data address mark detected$DMA arbitration error$Bad CRC/ECC$Data ECC corrected$ Controller failure$@Seek failed$�Time out$�Drive not ready$�Undefined error$�Write fault$�Status register error$�Sense operation failed$ Unknown error$� ����6�
���.8$t.�< t
F.�<$u�F���B���00000 $VSQR��� � .�C��� �
 3�����0K.�=  t����N�ZY[^�Error tables zeroed.
$���qu3����d��Ǉ�  CC��d|��	��