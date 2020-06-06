
(*
 * Non-recursive quick sort
 *)

program QuickSort;

const
  N = 15000;
  StackSize = 60;
  InsertParam = 20;
type
  Index = 0..N;
var
  L, R, I, J, M : Index;
  V, T : Integer;
  S : 0..StackSize;
  Stack : array[1..StackSize] of record
                                  L, R : Index;
                                end;
  A : array[Index] of Integer;

begin                         { qsort}
  WriteLn('Non-recursive QuickSort...');
  for I := 1 to N do
    A[I] := I mod 500;
  A[0] := -MaxInt;
  S := 1;
  Stack[1].L := 1;
  Stack[1].R := N;
  repeat
    L := Stack[S].L;
    R := Stack[S].R;
    S := S-1;
    while R-L > InsertParam do
      begin
        M := (L+R) div 2;
        T := A[M];
        A[M] := A[L+1];
        A[L+1] := T;
        if A[L+1] > A[R] then
          begin
            T := A[L+1];
            A[L+1] := A[R];
            A[R] := T;
          end;
        if A[L] > A[R] then
          begin
            T := A[L];
            A[L] := A[R];
            A[R] := T;
          end;
        if A[L+1] > A[L] then
          begin
            T := A[L+1];
            A[L+1] := A[L];
            A[L] := T;
          end;
        I := L+1;
        J := R;
        V := A[L];
        repeat
          repeat
            I := I+1;
          until A[I] >= V;
          repeat
            J := J-1;
          until A[J] <= V;
          if I < J
          then begin
            T := A[I];
            A[I] := A[J];
            A[J] := T;
          end;
        until I > J;
        A[L] := A[J];
        A[J] := V;
        S := S+1;
        if I-L < R-I then
          begin
            Stack[S].L := I;
            Stack[S].R := R;
            R := J-1;
          end
        else
          begin
            Stack[S].L := L;
            Stack[S].R := J-1;
            L := I;
          end;
      end;
  until S = 0;

  for L := 1 to N-1 do
    begin
      if A[L] > A[L+1] then
        begin
          V := A[L+1];
          I := L;
          repeat
            A[I+1] := A[I];
            I := I-1;
          until A[I] <= V;
          A[I+1] := V;
        end;
    end;

  WriteLn('finished');
end.
