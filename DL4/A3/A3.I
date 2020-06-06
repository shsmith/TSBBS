
state 0
   $accept : \batchs $end 
   batchs : \    (8)

   FUNCTION  shift 14
   PACKAGE  shift 8
   PRAGMA  shift 10
   PROCEDURE  shift 13
   USE  shift 12
   WITH  shift 11
   .  reduce 8

   procedure_banner  goto 9
   batchs  goto 1
   pragma  goto 5
   batch  goto 2
   package_declaration  goto 3
   procedure_declaration  goto 4
   with  goto 6
   use  goto 7

state 1
   $accept :  batchs\$end 

   $end  accept
   .  error


state 2
   batchs :  batch\batchs 
   batchs : \    (8)

   FUNCTION  shift 14
   PACKAGE  shift 8
   PRAGMA  shift 10
   PROCEDURE  shift 13
   USE  shift 12
   WITH  shift 11
   .  reduce 8

   procedure_banner  goto 9
   batchs  goto 15
   pragma  goto 5
   batch  goto 2
   package_declaration  goto 3
   procedure_declaration  goto 4
   with  goto 6
   use  goto 7

state 3
   batch :  package_declaration\    (9)

   .  reduce 9


state 4
   batch :  procedure_declaration\    (10)

   .  reduce 10


state 5
   batch :  pragma\    (11)

   .  reduce 11


state 6
   batch :  with\    (12)

   .  reduce 12


state 7
   batch :  use\    (13)

   .  reduce 13


state 8
   package_declaration :  PACKAGE\UNDEF_IDENTIFIER IS declarations package_initialization END UNDEF_IDENTIFIER ; 

   UNDEF_IDENTIFIER  shift 16
   .  error


state 9
   procedure_declaration :  procedure_banner\; 
   procedure_declaration :  procedure_banner\IS declarations BEGIN statements END UNDEF_IDENTIFIER ; 

   IS  shift 18
   ;  shift 17
   .  error


state 10
   pragma :  PRAGMA\DEBUG on_off ; 
   pragma :  PRAGMA\LIST on_off ; 
   pragma :  PRAGMA\TRACE on_off ; 
   pragma :  PRAGMA\any_identifier on_off ; 

   DEBUG  shift 19
   LIST  shift 20
   TRACE  shift 21
   UNDEF_IDENTIFIER  shift 23
   UNIT_IDENTIFIER  shift 25
   VAR_IDENTIFIER  shift 24
   .  error

   any_identifier  goto 22

state 11
   with :  WITH\package_identifier more_package_identifiers ; 

   UNDEF_IDENTIFIER  shift 27
   UNIT_IDENTIFIER  shift 28
   .  error

   package_identifier  goto 26

state 12
   use :  USE\package_identifier more_package_identifiers ; 

   UNDEF_IDENTIFIER  shift 27
   UNIT_IDENTIFIER  shift 28
   .  error

   package_identifier  goto 29

state 13
   procedure_banner :  PROCEDURE\UNDEF_IDENTIFIER formal_param_list 

   UNDEF_IDENTIFIER  shift 30
   .  error


state 14
   procedure_banner :  FUNCTION\UNDEF_IDENTIFIER formal_param_list RETURN type_specification 

   UNDEF_IDENTIFIER  shift 31
   .  error


state 15
   batchs :  batch batchs\    (7)

   .  reduce 7


state 16
   package_declaration :  PACKAGE UNDEF_IDENTIFIER\IS declarations package_initialization END UNDEF_IDENTIFIER ; 

   IS  shift 32
   .  error


state 17
   procedure_declaration :  procedure_banner ;\    (40)

   .  reduce 40


state 18
   procedure_declaration :  procedure_banner IS\declarations BEGIN statements END UNDEF_IDENTIFIER ; 
   declarations : \    (24)

   error  shift 39
   FUNCTION  shift 14
   PRAGMA  shift 10
   PROCEDURE  shift 13
   SUBTYPE  shift 42
   TYPE  shift 41
   UNDEF_IDENTIFIER  shift 40
   USE  shift 12
   .  reduce 24

   procedure_banner  goto 9
   pragma  goto 38
   procedure_declaration  goto 35
   use  goto 37
   declarations  goto 33
   declaration  goto 34
   data_declaration  goto 36

state 19
   pragma :  PRAGMA DEBUG\on_off ; 

   (  shift 44
   .  error

   on_off  goto 43

state 20
   pragma :  PRAGMA LIST\on_off ; 

   (  shift 44
   .  error

   on_off  goto 45

state 21
   pragma :  PRAGMA TRACE\on_off ; 

   (  shift 44
   .  error

   on_off  goto 46

state 22
   pragma :  PRAGMA any_identifier\on_off ; 

   (  shift 44
   .  error

   on_off  goto 47

state 23
   any_identifier :  UNDEF_IDENTIFIER\    (96)

   .  reduce 96


state 24
   any_identifier :  VAR_IDENTIFIER\    (97)

   .  reduce 97


state 25
   any_identifier :  UNIT_IDENTIFIER\    (98)

   .  reduce 98


state 26
   with :  WITH package_identifier\more_package_identifiers ; 
   more_package_identifiers : \    (22)

   ,  shift 49
   .  reduce 22

   more_package_identifiers  goto 48

state 27
   package_identifier :  UNDEF_IDENTIFIER\    (19)

   .  reduce 19


state 28
   package_identifier :  UNIT_IDENTIFIER\    (20)

   .  reduce 20


state 29
   use :  USE package_identifier\more_package_identifiers ; 
   more_package_identifiers : \    (22)

   ,  shift 49
   .  reduce 22

   more_package_identifiers  goto 50

state 30
   procedure_banner :  PROCEDURE UNDEF_IDENTIFIER\formal_param_list 
   formal_param_list : \    (45)

   (  shift 52
   .  reduce 45

   formal_param_list  goto 51

state 31
   procedure_banner :  FUNCTION UNDEF_IDENTIFIER\formal_param_list RETURN type_specification 
   formal_param_list : \    (45)

   (  shift 52
   .  reduce 45

   formal_param_list  goto 53

state 32
   package_declaration :  PACKAGE UNDEF_IDENTIFIER IS\declarations package_initialization END UNDEF_IDENTIFIER ; 
   declarations : \    (24)

   error  shift 39
   FUNCTION  shift 14
   PRAGMA  shift 10
   PROCEDURE  shift 13
   SUBTYPE  shift 42
   TYPE  shift 41
   UNDEF_IDENTIFIER  shift 40
   USE  shift 12
   .  reduce 24

   procedure_banner  goto 9
   pragma  goto 38
   procedure_declaration  goto 35
   use  goto 37
   declarations  goto 54
   declaration  goto 34
   data_declaration  goto 36

state 33
   procedure_declaration :  procedure_banner IS declarations\BEGIN statements END UNDEF_IDENTIFIER ; 

   BEGIN  shift 55
   .  error


state 34
   declarations :  declaration\declarations 
   declarations : \    (24)

   error  shift 39
   FUNCTION  shift 14
   PRAGMA  shift 10
   PROCEDURE  shift 13
   SUBTYPE  shift 42
   TYPE  shift 41
   UNDEF_IDENTIFIER  shift 40
   USE  shift 12
   .  reduce 24

   procedure_banner  goto 9
   pragma  goto 38
   procedure_declaration  goto 35
   use  goto 37
   declarations  goto 56
   declaration  goto 34
   data_declaration  goto 36

state 35
   declaration :  procedure_declaration\    (25)

   .  reduce 25


state 36
   declaration :  data_declaration\    (26)

   .  reduce 26


state 37
   declaration :  use\    (27)

   .  reduce 27


state 38
   declaration :  pragma\    (28)

   .  reduce 28


state 39
   declaration :  error\; 

   ;  shift 57
   .  error


state 40
   data_declaration :  UNDEF_IDENTIFIER\: type_specification ; 

   :  shift 58
   .  error


state 41
   data_declaration :  TYPE\UNDEF_IDENTIFIER IS type_specification ; 

   UNDEF_IDENTIFIER  shift 59
   .  error


state 42
   data_declaration :  SUBTYPE\UNDEF_IDENTIFIER IS type_specification ; 

   UNDEF_IDENTIFIER  shift 60
   .  error


state 43
   pragma :  PRAGMA DEBUG on_off\; 

   ;  shift 61
   .  error


state 44
   on_off :  (\ON ) 
   on_off :  (\OFF ) 

   OFF  shift 63
   ON  shift 62
   .  error


state 45
   pragma :  PRAGMA LIST on_off\; 

   ;  shift 64
   .  error


state 46
   pragma :  PRAGMA TRACE on_off\; 

   ;  shift 65
   .  error


state 47
   pragma :  PRAGMA any_identifier on_off\; 

   ;  shift 66
   .  error


state 48
   with :  WITH package_identifier more_package_identifiers\; 

   ;  shift 67
   .  error


state 49
   more_package_identifiers :  ,\package_identifier more_package_identifiers 

   UNDEF_IDENTIFIER  shift 27
   UNIT_IDENTIFIER  shift 28
   .  error

   package_identifier  goto 68

state 50
   use :  USE package_identifier more_package_identifiers\; 

   ;  shift 69
   .  error


state 51
   procedure_banner :  PROCEDURE UNDEF_IDENTIFIER formal_param_list\    (42)

   .  reduce 42


state 52
   formal_param_list :  (\formal_param more_formal_params ) 

   UNDEF_IDENTIFIER  shift 72
   .  error

   formal_param  goto 70
   formal_param_identifier  goto 71

state 53
   procedure_banner :  FUNCTION UNDEF_IDENTIFIER formal_param_list\RETURN type_specification 

   RETURN  shift 73
   .  error


state 54
   package_declaration :  PACKAGE UNDEF_IDENTIFIER IS declarations\package_initialization END UNDEF_IDENTIFIER ; 
   package_initialization : \    (16)

   BEGIN  shift 75
   .  reduce 16

   package_initialization  goto 74

state 55
   procedure_declaration :  procedure_banner IS declarations BEGIN\statements END UNDEF_IDENTIFIER ; 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 76
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 56
   declarations :  declaration declarations\    (23)

   .  reduce 23


state 57
   declaration :  error ;\    (29)

   .  reduce 29


state 58
   data_declaration :  UNDEF_IDENTIFIER :\type_specification ; 

   BOOLEAN  shift 104
   BYTE  shift 107
   CHARACTER  shift 103
   FALSE  shift 119
   FLOAT  shift 106
   INTEGER  shift 102
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   STRING  shift 105
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   type_specification  goto 101
   discrete_range  goto 108
   lvalue  goto 121
   expression  goto 109
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 59
   data_declaration :  TYPE UNDEF_IDENTIFIER\IS type_specification ; 

   IS  shift 122
   .  error


state 60
   data_declaration :  SUBTYPE UNDEF_IDENTIFIER\IS type_specification ; 

   IS  shift 123
   .  error


state 61
   pragma :  PRAGMA DEBUG on_off ;\    (1)

   .  reduce 1


state 62
   on_off :  ( ON\) 

   )  shift 124
   .  error


state 63
   on_off :  ( OFF\) 

   )  shift 125
   .  error


state 64
   pragma :  PRAGMA LIST on_off ;\    (2)

   .  reduce 2


state 65
   pragma :  PRAGMA TRACE on_off ;\    (3)

   .  reduce 3


state 66
   pragma :  PRAGMA any_identifier on_off ;\    (4)

   .  reduce 4


state 67
   with :  WITH package_identifier more_package_identifiers ;\    (17)

   .  reduce 17


state 68
   more_package_identifiers :  , package_identifier\more_package_identifiers 
   more_package_identifiers : \    (22)

   ,  shift 49
   .  reduce 22

   more_package_identifiers  goto 126

state 69
   use :  USE package_identifier more_package_identifiers ;\    (18)

   .  reduce 18


state 70
   formal_param_list :  ( formal_param\more_formal_params ) 
   more_formal_params : \    (51)

   ;  shift 128
   .  reduce 51

   more_formal_params  goto 127

state 71
   formal_param :  formal_param_identifier\more_formal_param_identifiers : in_out type_specification 
   more_formal_param_identifiers : \    (49)

   ,  shift 130
   .  reduce 49

   more_formal_param_identifiers  goto 129

state 72
   formal_param_identifier :  UNDEF_IDENTIFIER\    (47)

   .  reduce 47


state 73
   procedure_banner :  FUNCTION UNDEF_IDENTIFIER formal_param_list RETURN\type_specification 

   BOOLEAN  shift 104
   BYTE  shift 107
   CHARACTER  shift 103
   FALSE  shift 119
   FLOAT  shift 106
   INTEGER  shift 102
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   STRING  shift 105
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   type_specification  goto 131
   discrete_range  goto 108
   lvalue  goto 121
   expression  goto 109
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 74
   package_declaration :  PACKAGE UNDEF_IDENTIFIER IS declarations package_initialization\END UNDEF_IDENTIFIER ; 

   END  shift 132
   .  error


state 75
   package_initialization :  BEGIN\statements 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 133
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 76
   procedure_declaration :  procedure_banner IS declarations BEGIN statements\END UNDEF_IDENTIFIER ; 

   END  shift 134
   .  error


state 77
   statements :  statement\statements 
   statements :  statement\    (57)

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  reduce 57

   pragma  goto 88
   statements  goto 135
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 78
   statement :  if_then\    (58)

   .  reduce 58


state 79
   statement :  assignment\    (59)

   .  reduce 59


state 80
   statement :  call\    (60)

   .  reduce 60


state 81
   statement :  return\    (61)

   .  reduce 61


state 82
   statement :  while_loop\    (62)

   .  reduce 62


state 83
   statement :  for_loop\    (63)

   .  reduce 63


state 84
   statement :  loop\    (64)

   .  reduce 64


state 85
   statement :  case\    (65)

   .  reduce 65


state 86
   statement :  exit\    (66)

   .  reduce 66


state 87
   statement :  null\    (67)

   .  reduce 67


state 88
   statement :  pragma\    (68)

   .  reduce 68


state 89
   statement :  error\; 

   ;  shift 136
   .  error


state 90
   if_then :  IF\condition THEN statements elsif ELSE statements END IF ; 
   if_then :  IF\condition THEN statements elsif END IF ; 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   condition  goto 137
   lvalue  goto 121
   expression  goto 138
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 91
   assignment :  lvalue\BECOMES expression ; 

   BECOMES  shift 139
   .  error


state 92
   call :  UNIT_IDENTIFIER\param_list ; 
   param_list : \    (93)

   (  shift 141
   .  reduce 93

   param_list  goto 140

state 93
   return :  RETURN\expression ; 
   return :  RETURN\; 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   ;  shift 143
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 142
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 94
   while_loop :  WHILE\condition LOOP statements END LOOP ; 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   condition  goto 144
   lvalue  goto 121
   expression  goto 138
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 95
   for_loop :  FOR\lvalue IN discrete_range LOOP statements END LOOP ; 
   for_loop :  FOR\lvalue IN REVERSE discrete_range LOOP statements END LOOP ; 

   VAR_IDENTIFIER  shift 100
   .  error

   lvalue  goto 145

state 96
   loop :  LOOP\statements END LOOP ; 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 146
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 97
   case :  CASE\expression IS whens END CASE ; 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 147
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 98
   exit :  EXIT\WHEN condition ; 
   exit :  EXIT\; 

   WHEN  shift 148
   ;  shift 149
   .  error


state 99
   null :  NULL\; 

   ;  shift 150
   .  error


state 100
   lvalue :  VAR_IDENTIFIER\param_list 
   param_list : \    (93)

   (  shift 141
   .  reduce 93

   param_list  goto 151

state 101
   data_declaration :  UNDEF_IDENTIFIER : type_specification\; 

   ;  shift 152
   .  error


state 102
   type_specification :  INTEGER\    (33)

   .  reduce 33


state 103
   type_specification :  CHARACTER\    (34)

   .  reduce 34


state 104
   type_specification :  BOOLEAN\    (35)

   .  reduce 35


state 105
   type_specification :  STRING\    (36)

   .  reduce 36


state 106
   type_specification :  FLOAT\    (37)

   .  reduce 37


state 107
   type_specification :  BYTE\    (38)

   .  reduce 38


state 108
   type_specification :  discrete_range\    (39)

   .  reduce 39


state 109
   discrete_range :  expression\DOTDOT expression 
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   AND  shift 154
   DOTDOT  shift 153
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  error


state 110
   expression :  NOT\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 167
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 111
   expression :  -\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 168
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 112
   expression :  (\expression ) 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 169
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 113
   expression :  literal\    (117)

   .  reduce 117


state 114
   expression :  function_call\    (118)

   .  reduce 118


state 115
   expression :  variable_deref\    (119)

   .  reduce 119


state 116
   literal :  LIT_NUMBER\    (120)

   .  reduce 120


state 117
   literal :  LIT_STRING\    (121)

   .  reduce 121


state 118
   literal :  TRUE\    (122)

   .  reduce 122


state 119
   literal :  FALSE\    (123)

   .  reduce 123


state 120
   function_call :  UNIT_IDENTIFIER\param_list 
   param_list : \    (93)

   (  shift 141
   .  reduce 93

   param_list  goto 170

state 121
   variable_deref :  lvalue\    (124)

   .  reduce 124


state 122
   data_declaration :  TYPE UNDEF_IDENTIFIER IS\type_specification ; 

   BOOLEAN  shift 104
   BYTE  shift 107
   CHARACTER  shift 103
   FALSE  shift 119
   FLOAT  shift 106
   INTEGER  shift 102
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   STRING  shift 105
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   type_specification  goto 171
   discrete_range  goto 108
   lvalue  goto 121
   expression  goto 109
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 123
   data_declaration :  SUBTYPE UNDEF_IDENTIFIER IS\type_specification ; 

   BOOLEAN  shift 104
   BYTE  shift 107
   CHARACTER  shift 103
   FALSE  shift 119
   FLOAT  shift 106
   INTEGER  shift 102
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   STRING  shift 105
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   type_specification  goto 172
   discrete_range  goto 108
   lvalue  goto 121
   expression  goto 109
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 124
   on_off :  ( ON )\    (5)

   .  reduce 5


state 125
   on_off :  ( OFF )\    (6)

   .  reduce 6


state 126
   more_package_identifiers :  , package_identifier more_package_identifiers\    (21)

   .  reduce 21


state 127
   formal_param_list :  ( formal_param more_formal_params\) 

   )  shift 173
   .  error


state 128
   more_formal_params :  ;\formal_param 

   UNDEF_IDENTIFIER  shift 72
   .  error

   formal_param  goto 174
   formal_param_identifier  goto 71

state 129
   formal_param :  formal_param_identifier more_formal_param_identifiers\: in_out type_specification 

   :  shift 175
   .  error


state 130
   more_formal_param_identifiers :  ,\formal_param_identifier more_formal_param_identifiers 

   UNDEF_IDENTIFIER  shift 72
   .  error

   formal_param_identifier  goto 176

state 131
   procedure_banner :  FUNCTION UNDEF_IDENTIFIER formal_param_list RETURN type_specification\    (43)

   .  reduce 43


state 132
   package_declaration :  PACKAGE UNDEF_IDENTIFIER IS declarations package_initialization END\UNDEF_IDENTIFIER ; 

   UNDEF_IDENTIFIER  shift 177
   .  error


state 133
   package_initialization :  BEGIN statements\    (15)

   .  reduce 15


state 134
   procedure_declaration :  procedure_banner IS declarations BEGIN statements END\UNDEF_IDENTIFIER ; 

   UNDEF_IDENTIFIER  shift 178
   .  error


state 135
   statements :  statement statements\    (56)

   .  reduce 56


state 136
   statement :  error ;\    (69)

   .  reduce 69


state 137
   if_then :  IF condition\THEN statements elsif ELSE statements END IF ; 
   if_then :  IF condition\THEN statements elsif END IF ; 

   THEN  shift 179
   .  error


state 138
   condition :  expression\    (100)
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   AND  shift 154
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 100


state 139
   assignment :  lvalue BECOMES\expression ; 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 180
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 140
   call :  UNIT_IDENTIFIER param_list\; 

   ;  shift 181
   .  error


state 141
   param_list :  (\expression param_list_tail ) 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 182
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 142
   return :  RETURN expression\; 
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   AND  shift 154
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   ;  shift 183
   .  error


state 143
   return :  RETURN ;\    (77)

   .  reduce 77


state 144
   while_loop :  WHILE condition\LOOP statements END LOOP ; 

   LOOP  shift 184
   .  error


state 145
   for_loop :  FOR lvalue\IN discrete_range LOOP statements END LOOP ; 
   for_loop :  FOR lvalue\IN REVERSE discrete_range LOOP statements END LOOP ; 

   IN  shift 185
   .  error


state 146
   loop :  LOOP statements\END LOOP ; 

   END  shift 186
   .  error


state 147
   case :  CASE expression\IS whens END CASE ; 
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   AND  shift 154
   GE  shift 159
   IS  shift 187
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  error


state 148
   exit :  EXIT WHEN\condition ; 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   condition  goto 188
   lvalue  goto 121
   expression  goto 138
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 149
   exit :  EXIT ;\    (88)

   .  reduce 88


state 150
   null :  NULL ;\    (89)

   .  reduce 89


state 151
   lvalue :  VAR_IDENTIFIER param_list\    (90)

   .  reduce 90


state 152
   data_declaration :  UNDEF_IDENTIFIER : type_specification ;\    (30)

   .  reduce 30


state 153
   discrete_range :  expression DOTDOT\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 189
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 154
   expression :  expression AND\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 190
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 155
   expression :  expression OR\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 191
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 156
   expression :  expression =\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 192
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 157
   expression :  expression NE\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 193
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 158
   expression :  expression >\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 194
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 159
   expression :  expression GE\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 195
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 160
   expression :  expression <\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 196
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 161
   expression :  expression LE\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 197
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 162
   expression :  expression +\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 198
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 163
   expression :  expression -\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 199
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 164
   expression :  expression *\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 200
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 165
   expression :  expression /\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 201
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 166
   expression :  expression &\expression 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 202
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 167
   expression :  NOT expression\    (101)
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 101


state 168
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 
   expression :  - expression\    (115)

   .  reduce 115


state 169
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 
   expression :  ( expression\) 

   AND  shift 154
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   )  shift 203
   .  error


state 170
   function_call :  UNIT_IDENTIFIER param_list\    (125)

   .  reduce 125


state 171
   data_declaration :  TYPE UNDEF_IDENTIFIER IS type_specification\; 

   ;  shift 204
   .  error


state 172
   data_declaration :  SUBTYPE UNDEF_IDENTIFIER IS type_specification\; 

   ;  shift 205
   .  error


state 173
   formal_param_list :  ( formal_param more_formal_params )\    (44)

   .  reduce 44


state 174
   more_formal_params :  ; formal_param\    (50)

   .  reduce 50


state 175
   formal_param :  formal_param_identifier more_formal_param_identifiers :\in_out type_specification 
   in_out : \    (55)

   IN  shift 207
   OUT  shift 208
   .  reduce 55

   in_out  goto 206

state 176
   more_formal_param_identifiers :  , formal_param_identifier\more_formal_param_identifiers 
   more_formal_param_identifiers : \    (49)

   ,  shift 130
   .  reduce 49

   more_formal_param_identifiers  goto 209

state 177
   package_declaration :  PACKAGE UNDEF_IDENTIFIER IS declarations package_initialization END UNDEF_IDENTIFIER\; 

   ;  shift 210
   .  error


state 178
   procedure_declaration :  procedure_banner IS declarations BEGIN statements END UNDEF_IDENTIFIER\; 

   ;  shift 211
   .  error


state 179
   if_then :  IF condition THEN\statements elsif ELSE statements END IF ; 
   if_then :  IF condition THEN\statements elsif END IF ; 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 212
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 180
   assignment :  lvalue BECOMES expression\; 
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   AND  shift 154
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   ;  shift 213
   .  error


state 181
   call :  UNIT_IDENTIFIER param_list ;\    (75)

   .  reduce 75


state 182
   param_list :  ( expression\param_list_tail ) 
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 
   param_list_tail : \    (95)

   AND  shift 154
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   ,  shift 215
   .  reduce 95

   param_list_tail  goto 214

state 183
   return :  RETURN expression ;\    (76)

   .  reduce 76


state 184
   while_loop :  WHILE condition LOOP\statements END LOOP ; 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 216
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 185
   for_loop :  FOR lvalue IN\discrete_range LOOP statements END LOOP ; 
   for_loop :  FOR lvalue IN\REVERSE discrete_range LOOP statements END LOOP ; 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   REVERSE  shift 218
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   discrete_range  goto 217
   lvalue  goto 121
   expression  goto 109
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 186
   loop :  LOOP statements END\LOOP ; 

   LOOP  shift 219
   .  error


state 187
   case :  CASE expression IS\whens END CASE ; 
   whens : \    (84)

   WHEN  shift 222
   .  reduce 84

   whens  goto 220
   when  goto 221

state 188
   exit :  EXIT WHEN condition\; 

   ;  shift 223
   .  error


state 189
   discrete_range :  expression DOTDOT expression\    (91)
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   AND  shift 154
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 91


state 190
   expression :  expression\AND expression 
   expression :  expression AND expression\    (102)
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 102


state 191
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression OR expression\    (103)
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 103


state 192
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression = expression\    (104)
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 104


state 193
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression NE expression\    (105)
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 105


state 194
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression > expression\    (106)
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 106


state 195
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression GE expression\    (107)
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 107


state 196
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression < expression\    (108)
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 108


state 197
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression LE expression\    (109)
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 109


state 198
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression + expression\    (110)
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   *  shift 164
   /  shift 165
   .  reduce 110


state 199
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression - expression\    (111)
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   *  shift 164
   /  shift 165
   .  reduce 111


state 200
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression * expression\    (112)
   expression :  expression\/ expression 
   expression :  expression\& expression 

   .  reduce 112


state 201
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression / expression\    (113)
   expression :  expression\& expression 

   .  reduce 113


state 202
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 
   expression :  expression & expression\    (114)

   *  shift 164
   /  shift 165
   .  reduce 114


state 203
   expression :  ( expression )\    (116)

   .  reduce 116


state 204
   data_declaration :  TYPE UNDEF_IDENTIFIER IS type_specification ;\    (31)

   .  reduce 31


state 205
   data_declaration :  SUBTYPE UNDEF_IDENTIFIER IS type_specification ;\    (32)

   .  reduce 32


state 206
   formal_param :  formal_param_identifier more_formal_param_identifiers : in_out\type_specification 

   BOOLEAN  shift 104
   BYTE  shift 107
   CHARACTER  shift 103
   FALSE  shift 119
   FLOAT  shift 106
   INTEGER  shift 102
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   STRING  shift 105
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   type_specification  goto 224
   discrete_range  goto 108
   lvalue  goto 121
   expression  goto 109
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 207
   in_out :  IN\OUT 
   in_out :  IN\    (53)

   OUT  shift 225
   .  reduce 53


state 208
   in_out :  OUT\    (54)

   .  reduce 54


state 209
   more_formal_param_identifiers :  , formal_param_identifier more_formal_param_identifiers\    (48)

   .  reduce 48


state 210
   package_declaration :  PACKAGE UNDEF_IDENTIFIER IS declarations package_initialization END UNDEF_IDENTIFIER ;\    (14)

   .  reduce 14


state 211
   procedure_declaration :  procedure_banner IS declarations BEGIN statements END UNDEF_IDENTIFIER ;\    (41)

   .  reduce 41


state 212
   if_then :  IF condition THEN statements\elsif ELSE statements END IF ; 
   if_then :  IF condition THEN statements\elsif END IF ; 
   elsif : \    (73)

   ELSIF  shift 227
   .  reduce 73

   elsif  goto 226

state 213
   assignment :  lvalue BECOMES expression ;\    (74)

   .  reduce 74


state 214
   param_list :  ( expression param_list_tail\) 

   )  shift 228
   .  error


state 215
   param_list_tail :  ,\expression param_list_tail 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 229
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 216
   while_loop :  WHILE condition LOOP statements\END LOOP ; 

   END  shift 230
   .  error


state 217
   for_loop :  FOR lvalue IN discrete_range\LOOP statements END LOOP ; 

   LOOP  shift 231
   .  error


state 218
   for_loop :  FOR lvalue IN REVERSE\discrete_range LOOP statements END LOOP ; 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   discrete_range  goto 232
   lvalue  goto 121
   expression  goto 109
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 219
   loop :  LOOP statements END LOOP\; 

   ;  shift 233
   .  error


state 220
   case :  CASE expression IS whens\END CASE ; 

   END  shift 234
   .  error


state 221
   whens :  when\whens 
   whens : \    (84)

   WHEN  shift 222
   .  reduce 84

   whens  goto 235
   when  goto 221

state 222
   when :  WHEN\static_expression ASSOC statements 
   when :  WHEN\OTHERS ASSOC statements 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   OTHERS  shift 237
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   lvalue  goto 121
   expression  goto 238
   static_expression  goto 236
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 223
   exit :  EXIT WHEN condition ;\    (87)

   .  reduce 87


state 224
   formal_param :  formal_param_identifier more_formal_param_identifiers : in_out type_specification\    (46)

   .  reduce 46


state 225
   in_out :  IN OUT\    (52)

   .  reduce 52


state 226
   if_then :  IF condition THEN statements elsif\ELSE statements END IF ; 
   if_then :  IF condition THEN statements elsif\END IF ; 

   ELSE  shift 239
   END  shift 240
   .  error


state 227
   elsif :  ELSIF\condition THEN statements elsif 

   FALSE  shift 119
   LIT_NUMBER  shift 116
   LIT_STRING  shift 117
   NOT  shift 110
   TRUE  shift 118
   UNIT_IDENTIFIER  shift 120
   VAR_IDENTIFIER  shift 100
   -  shift 111
   (  shift 112
   .  error

   condition  goto 241
   lvalue  goto 121
   expression  goto 138
   literal  goto 113
   function_call  goto 114
   variable_deref  goto 115

state 228
   param_list :  ( expression param_list_tail )\    (92)

   .  reduce 92


state 229
   param_list_tail :  , expression\param_list_tail 
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 
   param_list_tail : \    (95)

   AND  shift 154
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   ,  shift 215
   .  reduce 95

   param_list_tail  goto 242

state 230
   while_loop :  WHILE condition LOOP statements END\LOOP ; 

   LOOP  shift 243
   .  error


state 231
   for_loop :  FOR lvalue IN discrete_range LOOP\statements END LOOP ; 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 244
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 232
   for_loop :  FOR lvalue IN REVERSE discrete_range\LOOP statements END LOOP ; 

   LOOP  shift 245
   .  error


state 233
   loop :  LOOP statements END LOOP ;\    (81)

   .  reduce 81


state 234
   case :  CASE expression IS whens END\CASE ; 

   CASE  shift 246
   .  error


state 235
   whens :  when whens\    (83)

   .  reduce 83


state 236
   when :  WHEN static_expression\ASSOC statements 

   ASSOC  shift 247
   .  error


state 237
   when :  WHEN OTHERS\ASSOC statements 

   ASSOC  shift 248
   .  error


state 238
   static_expression :  expression\    (99)
   expression :  expression\AND expression 
   expression :  expression\OR expression 
   expression :  expression\= expression 
   expression :  expression\NE expression 
   expression :  expression\> expression 
   expression :  expression\GE expression 
   expression :  expression\< expression 
   expression :  expression\LE expression 
   expression :  expression\+ expression 
   expression :  expression\- expression 
   expression :  expression\* expression 
   expression :  expression\/ expression 
   expression :  expression\& expression 

   AND  shift 154
   GE  shift 159
   LE  shift 161
   NE  shift 157
   OR  shift 155
   =  shift 156
   >  shift 158
   <  shift 160
   +  shift 162
   -  shift 163
   &  shift 166
   *  shift 164
   /  shift 165
   .  reduce 99


state 239
   if_then :  IF condition THEN statements elsif ELSE\statements END IF ; 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 249
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 240
   if_then :  IF condition THEN statements elsif END\IF ; 

   IF  shift 250
   .  error


state 241
   elsif :  ELSIF condition\THEN statements elsif 

   THEN  shift 251
   .  error


state 242
   param_list_tail :  , expression param_list_tail\    (94)

   .  reduce 94


state 243
   while_loop :  WHILE condition LOOP statements END LOOP\; 

   ;  shift 252
   .  error


state 244
   for_loop :  FOR lvalue IN discrete_range LOOP statements\END LOOP ; 

   END  shift 253
   .  error


state 245
   for_loop :  FOR lvalue IN REVERSE discrete_range LOOP\statements END LOOP ; 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 254
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 246
   case :  CASE expression IS whens END CASE\; 

   ;  shift 255
   .  error


state 247
   when :  WHEN static_expression ASSOC\statements 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 256
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 248
   when :  WHEN OTHERS ASSOC\statements 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 257
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 249
   if_then :  IF condition THEN statements elsif ELSE statements\END IF ; 

   END  shift 258
   .  error


state 250
   if_then :  IF condition THEN statements elsif END IF\; 

   ;  shift 259
   .  error


state 251
   elsif :  ELSIF condition THEN\statements elsif 

   error  shift 89
   CASE  shift 97
   EXIT  shift 98
   FOR  shift 95
   IF  shift 90
   LOOP  shift 96
   NULL  shift 99
   PRAGMA  shift 10
   RETURN  shift 93
   UNIT_IDENTIFIER  shift 92
   VAR_IDENTIFIER  shift 100
   WHILE  shift 94
   .  error

   pragma  goto 88
   statements  goto 260
   statement  goto 77
   if_then  goto 78
   assignment  goto 79
   call  goto 80
   return  goto 81
   while_loop  goto 82
   for_loop  goto 83
   loop  goto 84
   case  goto 85
   exit  goto 86
   null  goto 87
   lvalue  goto 91

state 252
   while_loop :  WHILE condition LOOP statements END LOOP ;\    (78)

   .  reduce 78


state 253
   for_loop :  FOR lvalue IN discrete_range LOOP statements END\LOOP ; 

   LOOP  shift 261
   .  error


state 254
   for_loop :  FOR lvalue IN REVERSE discrete_range LOOP statements\END LOOP ; 

   END  shift 262
   .  error


state 255
   case :  CASE expression IS whens END CASE ;\    (82)

   .  reduce 82


state 256
   when :  WHEN static_expression ASSOC statements\    (85)

   .  reduce 85


state 257
   when :  WHEN OTHERS ASSOC statements\    (86)

   .  reduce 86


state 258
   if_then :  IF condition THEN statements elsif ELSE statements END\IF ; 

   IF  shift 263
   .  error


state 259
   if_then :  IF condition THEN statements elsif END IF ;\    (71)

   .  reduce 71


state 260
   elsif :  ELSIF condition THEN statements\elsif 
   elsif : \    (73)

   ELSIF  shift 227
   .  reduce 73

   elsif  goto 264

state 261
   for_loop :  FOR lvalue IN discrete_range LOOP statements END LOOP\; 

   ;  shift 265
   .  error


state 262
   for_loop :  FOR lvalue IN REVERSE discrete_range LOOP statements END\LOOP ; 

   LOOP  shift 266
   .  error


state 263
   if_then :  IF condition THEN statements elsif ELSE statements END IF\; 

   ;  shift 267
   .  error


state 264
   elsif :  ELSIF condition THEN statements elsif\    (72)

   .  reduce 72


state 265
   for_loop :  FOR lvalue IN discrete_range LOOP statements END LOOP ;\    (79)

   .  reduce 79


state 266
   for_loop :  FOR lvalue IN REVERSE discrete_range LOOP statements END LOOP\; 

   ;  shift 268
   .  error


state 267
   if_then :  IF condition THEN statements elsif ELSE statements END IF ;\    (70)

   .  reduce 70


state 268
   for_loop :  FOR lvalue IN REVERSE discrete_range LOOP statements END LOOP ;\    (80)

   .  reduce 80


Summary:
  73/127 terminals, 48/200 nonterminals
  126/400 grammar rules, 269/600 states
  0 shift/reduce, 0 reduce/reduce conflicts reported
  48/250 working sets used
  memory: states,etc. 1784/5200, parser 584/4000
  98/450 distinct lookahead sets
  246 extra closures
  819 shift entries, 1 exceptions
  136 goto entries
  291 entries saved by goto default

Optimizer space used:
  input 1864/5200, output 593/4000
  593 table entries, 178 zero
  maximum spread: 313, maximum offset: 311
