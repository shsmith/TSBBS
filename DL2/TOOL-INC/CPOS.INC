   function cpos(c: char; var s): integer;
   begin
      cpos := 0;
      Inline(
        $C4/$7E/<s/            {   les di,[bp+<s]}
        $8A/$46/<c/            {   mov al,[bp+<c]}
        $30/$ED/               {   xor ch,ch}
        $26/$8A/$0D/           {   es: mov cl,[di]}
        $89/$CB/               {   mov bx,cx}
        $47/                   {   inc di}
        $FC/                   {   cld}
        $F2/$AE/               {   repnz scasb}
        $75/$05/               {   jnz notfound}
        $29/$CB/               {   sub bx,cx}
        $89/$5E/<cpos);        {   mov [bp+<cpos],bx}
                               {notfound:}
   end;

