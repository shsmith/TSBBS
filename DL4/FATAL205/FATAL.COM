�Q
Resident Critical Error Handler V2.05 12-May-1992
(C) 1989 Samuel H. Smith; ALL RIGHTS RESERVED
(C) 1992 James D. Traill (The Waszir) within 10 light years of Earth

$Error: $� Access denied!$� Disk write-protected!$� Unknown unit!$� Drive not ready!$� Unknown command!$� Data error (CRC)!$� Seek error!$� Unknown media type (non-DOS disk)!$� Sector not found!$� Printer out of paper!$� Write fault!$� Read fault!$� General failure!$� Sharing violation!$� Lock violation!$� Disk change invalid!$� FCB unavailable!$� Cannot complete file operation!$� Remote computer not listening!$� Network name not found!$� Network busy!$� Network device no longer exists!$� Network adapter hardware error!$� Network name not found!$� Network write fault!$  Undefined!$drive $� A:$� B:$� C:$� D:$� E:$� F:$� G:$� G:$� I:$� J:$� K:$� L:$� M:$� N:$� O:$� P:$� Q:$� R:$� S:$� T:$� U:$� V:$� W:$� X:$� Y:$� Z:$  ?:$Area:  $Reading from $Writing to $ $� DOS reserved area.$� File allocation table.$� Directory area.$� Data area.$  Undefined.$device DEV.$    Class: $� Out of space or I/O channels$� Temporary situation (file or record lock)$� Authorization (denied access)$� Internal error$� Hardware failure$� System failure$� Application program error$� Item not found$� Bad format$� Resource locked$� Media error$� Item already exists$� Unknown$� [E]$� [F]$  Undefined$ in $� Unknown.$� Block(disk) device.$� Network.$� Character device.$� System memory.$� [6]$� [7]$� [8]$  Undefined.$Suggested action: $� Retry the operation.$� Delay and then retry.$� Re-enter input.$� Abort after cleanup.$� Immediately abort.$� Ignore the error.$� Retry after correcting the error.$  Undefined.$?RRRRRRR?RRRRRRR?RRRRRRR?AAAAAIA?AAAAAAA?AAAAAAA?AAAAAAA?BBBBBBB ��    Action: (A)bort, (R)etry, (I)gnore, (F)ail? < >              $    �������������������͵ CRITICAL ERROR! ��������������������ͻ  
                                                             �    �  $
  ����������������������������������������������������������ͼ  
$[  [ [ [     HSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHSHS                                                                                                                                                                                                                                                  �&����kPSQRVWU�6�.����x ���]_^ZY[X���&���P�6_��6��
�6���t�6����Āt.�6��
�>����6���XPPA���6���X����6���X�P�6�RW3۴Y�!_Z�6�����X��P�6_���6���6Q��6_�xX��v��r��B� �>�Ru�R� �>�Iu�I� �>�Au�A� �>�Fu�F�x�2���u<s�S��2��㋟���[8.�u��t��t8�t���.���  ���6��6��>�v�>�v��<Bt,�����������
݊������6��� ø ���&�   �����&�   ��@��@�@ ��&�r 4���P3�Pˍ6��x �6��q �a �. � ��It#��Bt�����Rt����At����Ft	�6�C �Ӣ���  ���;�s��t� �<t$_��������&�ô�t� ����PSQ�<$t#<t<t<
t<t2��p� �	��p����Y[X�V���^�Ā�<$u��< t:�u��F���PSQRVWU3۴����>�3�� �ƀ�u�3�3Ҵ�]_^ZY[X�2�R3۴����Z��Bu�Í6�3�� �ƀ�u���3۴��2�R3۴���ܹ �	�Z��Bu��.��V.�6�.+6���"r.��  ^� .�.y� .�.��M��J��G�QVW3���&�>� �ƌ�;�v.�6��d ���3Ɏ�&�� �&�� _^Y�This program can be freely distributed so long as it is not modified
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

Masochated by "The Waszir" 1-MAY-1992 : For BBS and data recovery use.
(C) within 10 light years of Earth. Send Money and Erotic Women (preferred!)
Waszir => [Earth]<FAX: +61.3.723-7535 | BBS: +81.3.3813-1169 User #2>

Usage:  FATAL /I    ; Install.
        FATAL /U    ; Remove from operation.
        FATAL /C    ; Display critical error counters.
        FATAL /Z    ; Zero critical error counters.
        FATAL /?    ; Information.
 ------------------------------------------------------------------
        FATAL /IR   ; Always Retry & if not installed then install.
        FATAL /II   ; Always Ignore & if not installed then install.
        FATAL /IA   ; Always Abort & if not installed then install.
        FATAL /IF   ; Always Fail & if not installed then install.
 ------------------------------------------------------------------
                      Follow default settings until Time/Retry LIMIT.
        FATAL /IT   ; RETRY at limit & if not installed then install.
        FATAL /IK   ; IGNORE at limit & if not installed then install.
        FATAL /IC   ; ABORT at limit & if not installed then install.
        FATAL /IH   ; FAIL at limit & if not installed then install.
        FATAL /ID   ; RE-BOOT at limit & if not installed then install.
        FATAL /IxW  ; Install re-boot traps for Interrupts 0, 2 & 6.
                      Where "/Ix => x = other options, put "x" for default.
$DOS 3.0 or later required!
$FATAL TSR V2.05 Installed.
$FATAL 2.05 Removed.
$Error tables zeroed.
$Other programs loaded after FATAL -- cannot Remove TSR.
$TSR Already loaded!
$TSR already loaded - new parameters installed.
$TSR Memory could not be freed successfully -- ERROR!
FATAL TSR not resident.  Use FATAL/I first.
$FATAL TSR Settings Altered.
$
FATAL V2.05 status:
$Critical errors.
$Automatic retries.$Drive: $Locus:$RIAFTKCHDB�6� �<t.</t<-t��$�<Zu���1<Cu���(<Uu�J�<Iu���2�� < ��t�)� � L�!V���0�!��^<w�� �$߻
 :�It
Ku���B���$�<Wu��� �4u&�>��t� �5�!�y�{�!5�!�����$5�!�������%�!���!%�!�tB� 5�!�m�o�5�!�q�s�5�!�u�w��� %�!���%�!���%�!���A �)���������� 1�!�>t��&���J����$5�!��<$t&:uC����	�!������t� ��.�, +úH��������;�wx&���!%�!&�y�%�!&���$%�!&�t&�m� %�!&�q�%�!&�u�%�!&���&��� � &�, �I�!�{r�I�!�{r���U���9���ue����� ���� �(�.���=  t<�6����; �6���2 �6Q�C�' �6��;� �6���� �6���� ������R�����Z����<$u���� u�P��2��� ����X< u��00000 $VP��X�� � .�C��� �
 3�����0K.�=  t���w�^��Z���u;3��������6��+ �6�$ �6Q� �6�� �6�� �6�� ���.�ì<$u���D� < u��