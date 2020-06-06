{$F+} procedure choupper(len: integer; var st); {$F-}
begin

   Inline(
     $8B/$4E/<len/          {   mov cx,[bp+<len]}
     $C4/$7E/<st/           {   les di,[bp+<st]     ;es:di -> st[0]}
                            {next:}
     $47/                   {   inc di}
     $FE/$C9/               {   dec cl}
     $74/$12/               {   jz ends}
     $26/                   {   es:}
     $8A/$05/               {   mov al,[di]}
     $3C/$61/               {   cmp al,'a'}
     $72/$F4/               {   jb next}
     $3C/$7A/               {   cmp al,'z'}
     $77/$F0/               {   ja next}
     $2C/$20/               {   sub al,' '}
     $26/                   {   es:}
     $88/$05/               {   mov [di],al}
     $EB/$E9);              {   jmp next}
                            {ends:}
end;


