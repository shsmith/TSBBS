�
Resident Critical Error Handler v1.4 04/22/90
Copyright 1989, 1990 Samuel H. Smith; ALL RIGHTS RESERVED

$Error: $� Access denied!$� Disk write-protected!$� Unknown unit!$� Drive not ready!$� Unknown command!$� Data error (CRC)!$� Seek error!$� Unknwon media type (non-DOS disk)!$� Sector not found!$� Printer out of paper!$� Write fault!$� Read fault!$� General failure!$� Sharing violation!$� Lock violation!$� Disk change invalid!$� FCB unavailable!$� Cannot complete file operation!$� Remote computer not listening!$� Network name not found!$� Network busy!$� Network device no longer exists!$� Network adapter hardware error!$� Network name not found!$� Network write fault!$  Undefined!$drive $� A:$� B:$� C:$� D:$� E:$� F:$� G:$� H:$� I:$� J:$� K:$� L:$� M:$� N:$� O:$� P:$� Q:$� R:$� S:$� T:$� U:$� V:$� W:$� X:$� Y:$� Z:$  ?:$Area:  $Reading from $Writing to $ $� DOS reserved area.$� File allocation table.$� Directory area.$� Data area.$  Undefined.$device DEV.$    Class: $� Out of space or I/O channels$� File or record lock$� Denied access$� Internal error$� Hardware failure$� System failure$� Program error$� Not found$� Bad format$� Resource locked$� Media error$� Item already exists$  Undefined$ in $� Unknown.$� Block(disk) device.$� Network.$� Character device.$� System memory.$  Undefined.$Suggested action: $� Retry the operation.$� Delay and then retry.$� Re-enter input.$� Abort after cleanup.$� Immediately abort.$� Ignore the error.$� Retry after correcting the error.$  Undefined.$?RRRRAIR          Action: (A)bort, (R)etry, (I)gnore, (F)ail? < >                  $  ������������������������͵ CRITICAL ERROR! �������������������������ͻ  
                                                                       �    �  $
  ��������������������������������������������������������������������ͼ  
$�   HSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHS                      PSQRVWU�6��.��n��q � ��]_^ZY[X.���P�6���6K��6S��t�6a��Āt.�6���
�>�����6��� �XPPA���6��X����6m�� X�P�6T� 3۴Y�!�6r���� X���6�� ��6��� ��6�� �6�� 2�����-��6)� Í6��n �6��g �W �) � ��It����Rt����At����Ft	�6R�> �آ���B  �B;@}��t� �<t	$_����p�&-ô�t� ����PSQ�<$t#<t<t<
t<t2��p� �	��p����Y[X�V���^�Ā�<$u��< t:�u��F���PSQRVWU3۴��l�>D3�� �ƀ�u�3�3Ҵ�]_^ZY[X�2�R3۴����Z��Lu�Í6D3�� �ƀ�u��l3۴��2�R3۴���ܹ �	�Z��Lu��.�B� .�.r� .�.zPSQRVWU3���&�>� ����;�v.�6~�d ���3���&�� �&�� ]_^ZY[X�This program can be freely distributed so long as it is not modified
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

Usage:  FATAL/I     ;install in memory.
        FATAL/U     ;un-install.
        FATAL/C     ;display critical error count.
        FATAL/Z     ;zero critical error count.
$DOS 3.0 or later required!
$FATAL v1.4 installed.
$FATAL unInstalled.
$Error tables zeroed.
$Other programs loaded after FATAL -- cannot unInstall.
$Already loaded!
$Fatal is not resident.  Use FATAL/I first.
$
FATAL v1.4 status:
$Critical errors.
$Automatic retries.$Drive: $Locus:$�6� �<t.</t<-t��$�<Zu���1<Cu��(<Uu� �<Iu��� �� < ��u��� � L�!��u �0�!�{<~O�N �tF�5�!�r�t�!5�!�z�|�$5�!�~�����%�!���!%�!���  ���'딸$5�!��<$t&:uC����	�!�����'uB�Ì�+Í�=� }3&�z�!%�!&�r�%�!&�~�$%�!&�, �I�!�I�!��������'ue�T�n� �k�p� �~���n=  t<�6r���; �6����2 �6����' �6���� �6m�K� �6)��� �o�7��R�o�.�Z�*��<$u���� u�P��2�o� ����X< u��00000 $VP���X�m� � .�C��� �
 3�����0K.�=  t��m���^����'u;3��n�p�n�6r�+ �6��$ �6�� �6�� �6m� �6)� ����ì<$u���D� < u��