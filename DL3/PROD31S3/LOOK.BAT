echo off
if .%2 == . goto one
if .%3 == . goto two
if .%4 == . goto three
if .%5 == . goto four

:one
grep -in "%1" *.pas *.in? *.dcl >t
goto edit

:two
grep -in "%1 %2" *.pas *.in? *.dcl >t
goto edit

:three
grep -in "%1 %2 %3" *.pas *.in? *.dcl >t
goto edit

:four
grep -in "%1 %2 %3 %4" *.pas *.in? *.dcl >t
goto edit

:edit
q t
