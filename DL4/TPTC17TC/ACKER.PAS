
(*
 *   Ackerman function
 *)

program Acker;

Var
  R : Integer;

  function A(M, N : Integer) : Integer;
  begin
    if M = 0 then
      A := N+1
    else
      if N = 0 then
        A := A(M-1, 1)
      else
        A := A(M-1, A(M, N-1));
  end;

begin
  WriteLn('Ackerman function...');
  R := A(3, 6);
  WriteLn('finished, R=',R);
end.
