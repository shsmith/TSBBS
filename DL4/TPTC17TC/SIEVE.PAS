
(*
 * Sieve of Eratosthenes
 *)

program Sieve;

const
  Size = 8190;
var
  Flags : array[0..Size] of Boolean;
  Prime, K, Count : Integer;
  Inter, I : Integer;

begin
  WriteLn('Sieve of Eratosthenes...');
  Write('50 iterations');
  WriteLn;
  for Inter := 1 to 50 do
    begin
      Count := 0;
      for I := 0 to Size do
        Flags[I] := True;
      for I := 0 to Size do
        begin
          if (Flags[I]) then
            begin
              Prime := I+I+3;
              K := I+Prime;
              while (K <= Size) do
                begin
                  Flags[K] := False;
                  K := K+Prime;
                end;
              Count := Count+1;
            end;
        end;
    end;
  WriteLn(Count, ' primes');
end.
