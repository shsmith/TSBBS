
{$K-,D-,C-,U-,V-,I-}

{ This program forces a /T taskview partition into the virtual screen mode }

{$I TVFUNCS.INC}
{$I TASKVIEW.INC}


begin
  if TvVersion < $104 then
  begin
     writeln('Need TaskView 1.4');
     halt;
  end;

  TvSetUpdV;
  writeln('Virtual screen mode engaged.');
  flush(output);
end.
