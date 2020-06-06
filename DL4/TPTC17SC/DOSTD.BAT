rem translate standard unit specifications
:set tptc=-l -wj: -sc:\inc -i
tptc tptcsys -nu
tptc tp3
tptc dos 
tptc crt 
tptc \tp\errtrap errtrap
tptc \tp\minicrt minicrt
tptc \tp\bioscrt bioscrt
tptc \tp\system.doc system 
tptc \tp\printer.doc printer 
rem - note: you must edit graph.doc to properly comment the documentation
rem -       blocks that were added
tptc \tp\graph.doc graph 
