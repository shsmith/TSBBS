
  type
     JumpRec = array[1..6] of byte;

  procedure SetJump(VAR Save : JumpRec);
    {save the machine state and the pc for a later jump, longjumps
     will return to where SetJmp was called}
  begin
    inline($8B/$5E/$04/ {mov bx,[bp+4]  ;get address of jump record}
      $89/$E8/          {mov ax,bp      ;current bp}
      $05/$08/$00/      {add ax,8       ;the sp when call was made}
      $89/$07/          {mov [bx],ax    ;store in spreg}
      $8B/$46/$00/      {mov ax,[bp]    ;caller'S BP}
      $89/$47/$02/      {mov [bx+2],ax  ;store in bpreg}
      $8B/$46/$02/      {mov ax,[bp+2]  ;the return address}
      $89/$47/$04);     {mov [bx+4],ax  ;store in jmpadr}
  end;

  procedure LongJump(Save : JumpRec);
    {restore the machine state and make the jump}
  begin
    inline($8B/$5E/$08/ {mov bx,[bp+8]   ;get jump adress}
      $8B/$66/$04/      {mov sp,[bp+4]   ;restore sp}
      $8B/$6E/$06/      {mov bp,[bp+6]   ;and also bp}
      $FF/$E3);         {jmp bx          ;make the long jump}
  end;

