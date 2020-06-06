
(*************************************************************************
An Inline() implementation Boyer-Moore Algorithm for use with Turbo Pascal.
by Don Strenczewilk, CIS 72617,132
 
I am not attempting to describe the Boyer-Moore algorithm
here, just implement it in Inline().  If you want to know
more about it, get Van Hall's BOYER.PAS in the BORPRO
MS/PCDOS Data library which has an excellent description.
It's usefullnes is to quickly search for strings in buffers.

(Mods for Turbo Pascal 5.0, S.H.Smith 7-Jun-89)
*************************************************************************)

 
  {-------- Make table of increments for the Boyer-Moore algorithm -----------}
  PROCEDURE MakeTable(VAR SrchSt : string;
                      VAR cray : BTable);
    { makes table of increments for the Boyer-Moore algorithm }
  BEGIN
    INLINE($1E/$C5/$76/< SrchSt/$89/$F3/$8A/$04/$88/$C4/$B9/
      $80/$00/$C4/$7E/< cray/$89/$FA/$FC/$F2/$AB/$89/$DE/$89/$D7/
      $46/$98/$3C/$01/$7E/$13/$48/$88/$E1/$88/$E7/$8A/$1C/$89/
      $C2/$29/$CA/$88/$11/$46/$41/$39/$C1/$75/$F2/$1F);
  END;
 
  {---------- Case Insensitive version of Boyer-Moore algorithm --------------}
  FUNCTION BMsearch(VAR buffr;
              bsize : Integer;
              VAR table;
              VAR SrchSt : string) : Integer;
    { Case Insensitive version of Boyer-Moore algorithm }
    { SrchStr must be uppercased }
  BEGIN
    INLINE($1E/$31/$C0/$89/$C2/$C5/$76/< SrchSt/$8A/$14/$84/
      $D2/$74/$63/$01/$D6/$FE/$CA/$C4/$7E/< buffr/$89/$F9/$03/
      $8E/> bsize/$49/$01/$D7/$8A/$34/$C5/$5E/< table/$EB/$03/
      $D7/$01/$C7/$39/$F9/$72/$45/$26/$8A/$05/$3C/$61/$72/$06/
      $3C/$7A/$77/$02/$24/$DF/$38/$C6/$75/$E8/$56/$57/$51/$88/
      $D1/$88/$E5/$81/$F9/$00/$00/$74/$13/$4E/$4F/$26/$8A/$05/
      $3C/$61/$72/$06/$3C/$7A/$77/$02/$24/$DF/$3A/$04/$E1/$ED/
      $88/$F0/$59/$5F/$5E/$75/$C1/$C4/$46/< buffr/$97/$30/$F6/
      $29/$F8/$29/$D0/$40/$EB/$02/$30/$C0/$89/$46/$FE/$1F);
  END;
 
