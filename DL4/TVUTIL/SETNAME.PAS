
{$K-,D-,C-,U-,V-,I-}
{$G64,P1000}

{ This program sets the 'name' of the specified partition }

{$I TVFUNCS.INC}
{$I TASKVIEW.INC}

var
  PHndl    : IntPtrGlb;
  Name     : TVFuncStr;
  Part     : integer;
  i        : integer;

begin
  if TvVersion < $104 then
  begin
     writeln('Need TaskView 1.4');
     halt;
  end;

  if paramcount < 2 then
  begin
     writeln('Usage:  setname PARTITION Partition Name');
     halt;
  end;

  val(paramstr(1),Part,i);
  PHndl := TvGetPHndl( Part );
  if PHndl = nil then
  begin
     writeln('No such partition: ',Part);
     halt;
  end;

  Name := paramstr(2);
  for i := 3 to paramcount do
     Name := Name + ' ' + paramstr(i);

  if TvSetName( PHndl, Name ) = false then
     writeln('Could net set process name to: ',Name);
end.
