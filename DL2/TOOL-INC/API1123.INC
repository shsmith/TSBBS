(* ------------------------------------------------------------ *)
(*
 * api1123 - calculation for api standard 12.2.3
 *           water calibration of volumetric provers, aug 1984
 *           as defined in 11.2.3.5
 *
 * returns water density in gm/cc for a given 'f temperature.
 *)
function api1123 (t: real): real;
var
   t2,t3,t4,t5: real;
   rho:         real;

begin

(********
   if (t < 32.0) or (t > 105.0) then
   begin
      api1123 := 99;
      exit;
   end;
*********)

   t := (t-32.0) / 1.8;  {F to C}
   t2 := t*t;
   t3 := t2*t;
   t4 := t3*t;
   t5 := t4*t;
   rho := 999.839563900000000000
          + 0.067982999890000000 * t
          - 0.009106025564000000 * t2
          + 0.000100527299900000 * t3
          - 0.000001126713526000 * t4
          + 0.000000006591795606 * t5;

   api1123 := rho / 1000.0;
end;


