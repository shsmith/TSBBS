rem Benchmark DOS File Accelerator with LOGItech Modula-2/86 Compiler.
rem On a 20meg hdisk, this normally runs in 97 seconds.
rem With DFA11 enabled it takes only 60 seconds!

m2 comp examp1
m2 link examp1
m2 comp modex1
m2 link modex1

