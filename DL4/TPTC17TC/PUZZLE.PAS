
(*
 * Example of multi-dimensional array manipulation
 *)
 
program Puzzle;

const
  XSize = 511;                { d*d*d-1}
  ClassMax = 3;
  TypeMax = 12;
  D = 8;

type
  PieceClass = 0..ClassMax;
  PieceType = 0..TypeMax;
  Position = 0..XSize;

var
  PieceCount : array[PieceClass] of 0..13;
  Class : array[PieceType] of PieceClass;
  PieceMax : array[PieceType] of Position;
  Puzzle : array[Position] of Boolean;
  P : array[PieceType] of array[Position] of Boolean;
  P2 : array[PieceType,Position] of Boolean; {alternate form}
  M, N : Position;
  I, J, K : 0..13;
  Kount : Integer;

  function Fit(I : PieceType; J : Position) : Boolean;
  label 1;
  var
    K : Position;
  begin
    Fit := False;
    for K := 0 to PieceMax[I] do
      if P[I, K] then
        if Puzzle[J+K] then
          goto 1;
    Fit := True;
1:
  end;

  function Place(I : PieceType; J : Position) : Position;
  label
    1;
  var
    K : Position;
  begin
    for K := 0 to PieceMax[I] do
      if P[I, K] then
        Puzzle[J+K] := True;
    PieceCount[Class[I]] := PieceCount[Class[I]]-1;
    for K := J to XSize do
      if not Puzzle[K] then
        begin
          Place := K;
          goto 1;
        end;
    WriteLn('Puzzle filled');
    Place := 0;
1:
  end;

  procedure Remove(I : PieceType; J : Position);
  var
    K : Position;
  begin
    for K := 0 to PieceMax[I] do
      if P[I, K] then
        Puzzle[J+K] := False;
    PieceCount[Class[I]] := PieceCount[Class[I]]+1;
  end;

  function Trial(J : Position) : Boolean;
  var
    I : PieceType;
    K : Position;
  begin
    for I := 0 to TypeMax do
      if PieceCount[Class[I]] <> 0 then
        if Fit(I, J) then
          begin
            K := Place(I, J);
            if Trial(K) or (K = 0) then
              begin
                {writeln( 'Piece', i + 1, ' at', k + 1);}
                Trial := True;
                exit;
              end
            else
              Remove(I, J);
          end;
    Trial := False;
    Kount := Kount+1;
  end;

begin
  WriteLn('Solving puzzle...');
  for M := 0 to XSize do
    Puzzle[M] := True;
  for I := 1 to 5 do
    for J := 1 to 5 do
      for K := 1 to 5 do
        Puzzle[I+D*(J+D*K)] := False;

  for I := 0 to TypeMax do
    for M := 0 to XSize do
      P[I, M] := False;

  for I := 0 to 3 do
    for J := 0 to 1 do
      for K := 0 to 0 do
        P[0, I+D*(J+D*K)] := True;

  Class[0] := 0;
  PieceMax[0] := 3+D*1+D*D*0;
  for I := 0 to 1 do
    for J := 0 to 0 do
      for K := 0 to 3 do
        P[1, I+D*(J+D*K)] := True;

  Class[1] := 0;
  PieceMax[1] := 1+D*0+D*D*3;
  for I := 0 to 0 do
    for J := 0 to 3 do
      for K := 0 to 1 do
        P[2, I+D*(J+D*K)] := True;

  Class[2] := 0;
  PieceMax[2] := 0+D*3+D*D*1;
  for I := 0 to 1 do
    for J := 0 to 3 do
      for K := 0 to 0 do
        P[3, I+D*(J+D*K)] := True;

  Class[3] := 0;
  PieceMax[3] := 1+D*3+D*D*0;
  for I := 0 to 3 do
    for J := 0 to 0 do
      for K := 0 to 1 do
        P[4, I+D*(J+D*K)] := True;

  Class[4] := 0;
  PieceMax[4] := 3+D*0+D*D*1;
  for I := 0 to 0 do
    for J := 0 to 1 do
      for K := 0 to 3 do
        P[5, I+D*(J+D*K)] := True;

  Class[5] := 0;
  PieceMax[5] := 0+D*1+D*D*3;
  for I := 0 to 2 do
    for J := 0 to 0 do
      for K := 0 to 0 do
        P[6, I+D*(J+D*K)] := True;

  Class[6] := 1;
  PieceMax[6] := 2+D*0+D*D*0;
  for I := 0 to 0 do
    for J := 0 to 2 do
      for K := 0 to 0 do
        P[7, I+D*(J+D*K)] := True;

  Class[7] := 1;
  PieceMax[7] := 0+D*2+D*D*0;
  for I := 0 to 0 do
    for J := 0 to 0 do
      for K := 0 to 2 do
        P[8, I+D*(J+D*K)] := True;

  Class[8] := 1;
  PieceMax[8] := 0+D*0+D*D*2;
  for I := 0 to 1 do
    for J := 0 to 1 do
      for K := 0 to 0 do
        P[9, I+D*(J+D*K)] := True;

  Class[9] := 2;
  PieceMax[9] := 1+D*1+D*D*0;
  for I := 0 to 1 do
    for J := 0 to 0 do
      for K := 0 to 1 do
        P[10, I+D*(J+D*K)] := True;

  Class[10] := 2;
  PieceMax[10] := 1+D*0+D*D*1;
  for I := 0 to 0 do
    for J := 0 to 1 do
      for K := 0 to 1 do
        P[11, I+D*(J+D*K)] := True;

  Class[11] := 2;
  PieceMax[11] := 0+D*1+D*D*1;
  for I := 0 to 1 do
    for J := 0 to 1 do
      for K := 0 to 1 do
        P[12, I+D*(J+D*K)] := True;

  Class[12] := 3;
  PieceMax[12] := 1+D*1+D*D*1;
  PieceCount[0] := 13;
  PieceCount[1] := 3;
  PieceCount[2] := 1;
  PieceCount[3] := 1;
  M := 1+D*(1+D*1);
  Kount := 0;

  if Fit(0, M) then
    N := Place(0, M)
  else
    WriteLn(' error 1');

  if Trial(N) then
    WriteLn(' success in ', Kount, ' trials')
  else
    WriteLn(' failure');
end.
