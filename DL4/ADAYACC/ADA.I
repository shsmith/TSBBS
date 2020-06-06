
0: shift/reduce conflict (shift 5, reduce 10) on PRAGMA
state 0
   $accept : !compilation $end 
   compilation : !   (reduce 372)
   r.pragma : !   (reduce 10)

   $end  reduce 372
   PRAGMA  shift 5
   .  reduce 10

   compilation  goto 1
   pragma  goto 4
   r.pragma  goto 3
   compilation_unit  goto 2


state 1
   $accept :  compilation!$end 

   $end  accept
   .  error



2: shift/reduce conflict (shift 5, reduce 10) on PRAGMA
state 2
   compilation :  compilation_unit!compilation 
   compilation : !   (reduce 372)
   r.pragma : !   (reduce 10)

   $end  reduce 372
   PRAGMA  shift 5
   .  reduce 10

   compilation  goto 6
   pragma  goto 4
   r.pragma  goto 3
   compilation_unit  goto 2


state 3
   compilation_unit :  r.pragma!context_clause r.pragma comp_unit 
   context_clause : !   (reduce 387)

   USE  shift 11
   WITH  shift 10
   .  reduce 387

   use_clause  goto 9
   context_clause  goto 7
   with_clause  goto 8


4: shift/reduce conflict (shift 5, reduce 10) on PRAGMA
state 4
   r.pragma :  pragma!r.pragma 
   r.pragma : !   (reduce 10)

   PRAGMA  shift 5
   .  reduce 10

   pragma  goto 4
   r.pragma  goto 12


state 5
   pragma :  PRAGMA!IDENTIFIER ; 
   pragma :  PRAGMA!IDENTIFIER ( argument_association r.argument_association ) ; 

   IDENTIFIER  shift 13
   .  error



state 6
   compilation :  compilation_unit compilation!   (reduce 371)

   .  reduce 371



state 7
   compilation_unit :  r.pragma context_clause!r.pragma comp_unit 
   r.pragma : !   (reduce 10)

   PRAGMA  shift 5
   .  reduce 10

   pragma  goto 4
   r.pragma  goto 14


state 8
   context_clause :  with_clause!context_clause 
   context_clause : !   (reduce 387)

   USE  shift 11
   WITH  shift 10
   .  reduce 387

   use_clause  goto 9
   context_clause  goto 15
   with_clause  goto 8


state 9
   context_clause :  use_clause!context_clause 
   context_clause : !   (reduce 387)

   USE  shift 11
   WITH  shift 10
   .  reduce 387

   use_clause  goto 9
   context_clause  goto 16
   with_clause  goto 8


state 10
   with_clause :  WITH!UNIT_name r.UNIT_name ; 

   UNIT_name  shift 17
   .  error



state 11
   use_clause :  USE!PACKAGE_name r.PACKAGE_name ; 

   PACKAGE_name  shift 18
   .  error



state 12
   r.pragma :  pragma r.pragma!   (reduce 9)

   .  reduce 9



state 13
   pragma :  PRAGMA IDENTIFIER!; 
   pragma :  PRAGMA IDENTIFIER!( argument_association r.argument_association ) ; 

   ;  shift 19
   (  shift 20
   .  error



state 14
   compilation_unit :  r.pragma context_clause r.pragma!comp_unit 

   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 34
   PROCEDURE  shift 35
   SEPARATE  shift 38
   .  error

   subprogram_declaration  goto 24
   package_declaration  goto 25
   generic_declaration  goto 26
   generic_instantiation  goto 27
   subprogram_body  goto 28
   package_body  goto 37
   subprogram_specification  goto 31
   package_specification  goto 32
   comp_unit  goto 21
   library_unit  goto 22
   secondary_unit  goto 23
   library_unit_body  goto 29
   subunit  goto 30
   generic_specification  goto 33
   generic_formal_part  goto 39


state 15
   context_clause :  with_clause context_clause!   (reduce 385)

   .  reduce 385



state 16
   context_clause :  use_clause context_clause!   (reduce 386)

   .  reduce 386



state 17
   with_clause :  WITH UNIT_name!r.UNIT_name ; 
   r.UNIT_name : !   (reduce 390)

   ,  shift 42
   .  reduce 390

   r.UNIT_name  goto 41


state 18
   use_clause :  USE PACKAGE_name!r.PACKAGE_name ; 
   r.PACKAGE_name : !   (reduce 324)

   ,  shift 44
   .  reduce 324

   r.PACKAGE_name  goto 43


state 19
   pragma :  PRAGMA IDENTIFIER ;!   (reduce 1)

   .  reduce 1



state 20
   pragma :  PRAGMA IDENTIFIER (!argument_association r.argument_association ) ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   ARGUMENT_identifier  shift 46
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   argument_association  goto 45
   name  goto 47
   expression  goto 48
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 21
   compilation_unit :  r.pragma context_clause r.pragma comp_unit!   (reduce 373)

   .  reduce 373



state 22
   comp_unit :  library_unit!   (reduce 374)

   .  reduce 374



state 23
   comp_unit :  secondary_unit!   (reduce 375)

   .  reduce 375



state 24
   library_unit :  subprogram_declaration!   (reduce 376)

   .  reduce 376



state 25
   library_unit :  package_declaration!   (reduce 377)

   .  reduce 377



state 26
   library_unit :  generic_declaration!   (reduce 378)

   .  reduce 378



state 27
   library_unit :  generic_instantiation!   (reduce 379)

   .  reduce 379



28: reduce/reduce conflict (reductions 380 and 383) on $end
28: reduce/reduce conflict (reductions 380 and 383) on FUNCTION
28: reduce/reduce conflict (reductions 380 and 383) on GENERIC
28: reduce/reduce conflict (reductions 380 and 383) on PACKAGE
28: reduce/reduce conflict (reductions 380 and 383) on PRAGMA
28: reduce/reduce conflict (reductions 380 and 383) on PROCEDURE
28: reduce/reduce conflict (reductions 380 and 383) on SEPARATE
28: reduce/reduce conflict (reductions 380 and 383) on USE
28: reduce/reduce conflict (reductions 380 and 383) on WITH
state 28
   library_unit :  subprogram_body!   (reduce 380)
   library_unit_body :  subprogram_body!   (reduce 383)

   .  reduce 380



state 29
   secondary_unit :  library_unit_body!   (reduce 381)

   .  reduce 381



state 30
   secondary_unit :  subunit!   (reduce 382)

   .  reduce 382



state 31
   subprogram_declaration :  subprogram_specification!   (reduce 277)
   subprogram_body :  subprogram_specification!IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END o.designator ; 

   IS  shift 83
   .  reduce 277



state 32
   package_declaration :  package_specification!; 

   ;  shift 84
   .  error



state 33
   generic_declaration :  generic_specification!; 

   ;  shift 85
   .  error



state 34
   package_specification :  PACKAGE!IDENTIFIER IS declarative_part o.private_part END PACKAGE_name 
   package_body :  PACKAGE!BODY PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 
   generic_instantiation :  PACKAGE!IDENTIFIER IS NEW GENERIC_PACKAGE_name o.generic_actual_part ; 

   BODY  shift 87
   IDENTIFIER  shift 86
   .  error



state 35
   subprogram_specification :  PROCEDURE!IDENTIFIER formal_part 
   subprogram_specification :  PROCEDURE!IDENTIFIER 
   generic_instantiation :  PROCEDURE!IDENTIFIER IS NEW GENERIC_PROCEDURE_name o.generic_actual_part ; 

   IDENTIFIER  shift 88
   .  error



state 36
   subprogram_specification :  FUNCTION!designator formal_part RETURN type_mark 
   subprogram_specification :  FUNCTION!designator RETURN type_mark 
   generic_instantiation :  FUNCTION!designator IS NEW GENERIC_FUNCTION_name o.generic_actual_part ; 

   IDENTIFIER  shift 90
   OPERATOR_STRING_LITERAL  shift 58
   .  error

   operator_symbol  goto 91
   designator  goto 89


state 37
   library_unit_body :  package_body!   (reduce 384)

   .  reduce 384



state 38
   subunit :  SEPARATE!( PARENT_UNIT_name ) proper_body 

   (  shift 92
   .  error



state 39
   generic_specification :  generic_formal_part!subprogram_specification 
   generic_specification :  generic_formal_part!package_specification 

   FUNCTION  shift 96
   PACKAGE  shift 97
   PROCEDURE  shift 95
   .  error

   subprogram_specification  goto 93
   package_specification  goto 94


state 40
   generic_formal_part :  GENERIC!r.generic_parameter_declaration 
   r.generic_parameter_declaration : !   (reduce 408)

   TYPE  shift 101
   WITH  shift 103
   IDENTIFIER  shift 104
   .  reduce 408

   identifier_list  goto 100
   private_type_declaration  goto 102
   r.generic_parameter_declaration  goto 98
   generic_parameter_declaration  goto 99


state 41
   with_clause :  WITH UNIT_name r.UNIT_name!; 

   ;  shift 105
   .  error



state 42
   r.UNIT_name :  ,!UNIT_name r.UNIT_name 

   UNIT_name  shift 106
   .  error



state 43
   use_clause :  USE PACKAGE_name r.PACKAGE_name!; 

   ;  shift 107
   .  error



state 44
   r.PACKAGE_name :  ,!PACKAGE_name r.PACKAGE_name 

   PACKAGE_name  shift 108
   .  error



state 45
   pragma :  PRAGMA IDENTIFIER ( argument_association!r.argument_association ) ; 
   r.argument_association : !   (reduce 4)

   ,  shift 110
   .  reduce 4

   r.argument_association  goto 109


state 46
   argument_association :  ARGUMENT_identifier!ASSOC name 
   argument_association :  ARGUMENT_identifier!ASSOC expression 

   ASSOC  shift 111
   .  error



47: reduce/reduce conflict (reductions 7 and 201) on )
47: reduce/reduce conflict (reductions 7 and 201) on ,
state 47
   argument_association :  name!   (reduce 7)
   prefix :  name!   (reduce 146)
   primary :  name!   (reduce 201)

   PRIME  reduce 146
   (  reduce 146
   )  reduce 7
   ,  reduce 7
   .  reduce 146
   .  reduce 201



state 48
   argument_association :  expression!   (reduce 8)

   .  reduce 8



state 49
   name :  simple_name!   (reduce 138)

   .  reduce 138



state 50
   name :  CHARACTER_LITERAL!   (reduce 139)

   .  reduce 139



state 51
   name :  operator_symbol!   (reduce 140)

   .  reduce 140



state 52
   name :  indexed_component!   (reduce 141)

   .  reduce 141



state 53
   name :  slice!   (reduce 142)

   .  reduce 142



state 54
   name :  selected_component!   (reduce 143)

   .  reduce 143



state 55
   name :  attribute!   (reduce 144)

   .  reduce 144



56: shift/reduce conflict (shift 112, reduce 172) on AND
56: shift/reduce conflict (shift 113, reduce 172) on OR
56: shift/reduce conflict (shift 114, reduce 172) on XOR
state 56
   expression :  relation!AND relation 
   expression :  relation!AND THEN relation 
   expression :  relation!OR relation 
   expression :  relation!OR ELSE relation 
   expression :  relation!XOR relation 
   expression :  relation!   (reduce 172)

   AND  shift 112
   OR  shift 113
   XOR  shift 114
   .  reduce 172



state 57
   simple_name :  IDENTIFIER!   (reduce 145)

   .  reduce 145



state 58
   operator_symbol :  OPERATOR_STRING_LITERAL!   (reduce 284)

   .  reduce 284



state 59
   indexed_component :  prefix!( expression r.expression ) 
   slice :  prefix!( discrete_range ) 
   selected_component :  prefix!. selector 
   attribute :  prefix!PRIME attribute_designator 

   PRIME  shift 117
   (  shift 115
   .  shift 116
   .  error



60: shift/reduce conflict (shift 125, reduce 183) on IN
60: shift/reduce conflict (shift 124, reduce 183) on NOT
60: shift/reduce conflict (shift 123, reduce 183) on GE
60: shift/reduce conflict (shift 121, reduce 183) on LE
60: shift/reduce conflict (shift 119, reduce 183) on NE
60: shift/reduce conflict (shift 118, reduce 183) on =
60: shift/reduce conflict (shift 120, reduce 183) on <
60: shift/reduce conflict (shift 122, reduce 183) on >
state 60
   relation :  simple_expression!= simple_expression 
   relation :  simple_expression!NE simple_expression 
   relation :  simple_expression!< simple_expression 
   relation :  simple_expression!LE simple_expression 
   relation :  simple_expression!> simple_expression 
   relation :  simple_expression!GE simple_expression 
   relation :  simple_expression!NOT IN range 
   relation :  simple_expression!NOT IN type_mark 
   relation :  simple_expression!IN range 
   relation :  simple_expression!IN type_mark 
   relation :  simple_expression!   (reduce 183)

   IN  shift 125
   NOT  shift 124
   GE  shift 123
   LE  shift 121
   NE  shift 119
   =  shift 118
   <  shift 120
   >  shift 122
   .  reduce 183



61: reduce/reduce conflict (reductions 147 and 203) on PRIME
61: reduce/reduce conflict (reductions 147 and 203) on (
61: reduce/reduce conflict (reductions 147 and 203) on .
state 61
   prefix :  function_call!   (reduce 147)
   primary :  function_call!   (reduce 203)

   PRIME  reduce 147
   (  reduce 147
   .  reduce 147
   .  reduce 203



62: shift/reduce conflict (shift 126, reduce 187) on +
62: shift/reduce conflict (shift 127, reduce 187) on -
62: shift/reduce conflict (shift 128, reduce 187) on &
state 62
   simple_expression :  s.term!+ simple_expression 
   simple_expression :  s.term!- simple_expression 
   simple_expression :  s.term!& simple_expression 
   simple_expression :  s.term!   (reduce 187)

   +  shift 126
   -  shift 127
   &  shift 128
   .  reduce 187



63: shift/reduce conflict (shift 69, reduce 299) on ABS
63: shift/reduce conflict (shift 79, reduce 299) on NEW
63: shift/reduce conflict (shift 70, reduce 299) on NOT
63: shift/reduce conflict (shift 78, reduce 299) on NULL
63: shift/reduce conflict (shift 50, reduce 299) on CHARACTER_LITERAL
63: shift/reduce conflict (shift 57, reduce 299) on IDENTIFIER
63: shift/reduce conflict (shift 76, reduce 299) on NUMERIC_LITERAL
63: shift/reduce conflict (shift 58, reduce 299) on OPERATOR_STRING_LITERAL
63: shift/reduce conflict (shift 77, reduce 299) on STRING_LITERAL
63: shift/reduce conflict (shift 64, reduce 299) on +
63: shift/reduce conflict (shift 65, reduce 299) on -
63: shift/reduce conflict (shift 63, reduce 299) on FUNCTION_name
63: shift/reduce conflict (shift 133, reduce 299) on PARAMETER_name
63: shift/reduce conflict (shift 82, reduce 299) on SUBTYPE_name
63: shift/reduce conflict (shift 81, reduce 299) on TYPE_name
63: shift/reduce conflict (shift 135, reduce 299) on VARIABLE_name
63: shift/reduce conflict (shift 75, reduce 299) on (
state 63
   function_call :  FUNCTION_name!actual_parameter_part 
   function_call :  FUNCTION_name!   (reduce 299)

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   PARAMETER_name  shift 133
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 135
   (  shift 75
   .  reduce 299

   name  goto 137
   expression  goto 134
   type_mark  goto 136
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   actual_parameter_part  goto 129
   parameter_association  goto 130
   formal_parameter  goto 131
   actual_parameter  goto 132


state 64
   s.term :  +!term 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   term  goto 138
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 65
   s.term :  -!term 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   term  goto 139
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 66
   s.term :  term!   (reduce 190)

   .  reduce 190



67: shift/reduce conflict (shift 142, reduce 195) on MOD
67: shift/reduce conflict (shift 143, reduce 195) on REM
67: shift/reduce conflict (shift 140, reduce 195) on *
67: shift/reduce conflict (shift 141, reduce 195) on /
state 67
   term :  factor!* term 
   term :  factor!/ term 
   term :  factor!MOD term 
   term :  factor!REM term 
   term :  factor!   (reduce 195)

   MOD  shift 142
   REM  shift 143
   *  shift 140
   /  shift 141
   .  reduce 195



68: shift/reduce conflict (shift 144, reduce 199) on STARSTAR
state 68
   factor :  primary!STARSTAR primary 
   factor :  primary!   (reduce 199)

   STARSTAR  shift 144
   .  reduce 199



state 69
   factor :  ABS!primary 

   NEW  shift 79
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   primary  goto 145
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 70
   factor :  NOT!primary 

   NEW  shift 79
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   primary  goto 146
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 71
   primary :  aggregate!   (reduce 200)

   .  reduce 200



state 72
   primary :  allocator!   (reduce 202)

   .  reduce 202



state 73
   primary :  type_conversion!   (reduce 204)

   .  reduce 204



state 74
   primary :  qualified_expression!   (reduce 205)

   .  reduce 205



state 75
   aggregate :  (!component_association r.component_association ) 
   primary :  (!expression ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   OTHERS  shift 152
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   COMPONENT_name  shift 153
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 148
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 150
   discrete_range  goto 151
   discrete_subtype_indication  goto 154
   choice  goto 149
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   component_association  goto 147
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 76
   primary :  NUMERIC_LITERAL!   (reduce 207)

   .  reduce 207



state 77
   primary :  STRING_LITERAL!   (reduce 208)

   .  reduce 208



state 78
   primary :  NULL!   (reduce 209)

   .  reduce 209



state 79
   allocator :  NEW!subtype_indication 
   allocator :  NEW!qualified_expression 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   subtype_indication  goto 160
   type_mark  goto 162
   qualified_expression  goto 161


state 80
   type_conversion :  type_mark!( expression ) 
   qualified_expression :  type_mark!PRIME ( expression ) 
   qualified_expression :  type_mark!PRIME aggregate 

   PRIME  shift 164
   (  shift 163
   .  error



state 81
   type_mark :  TYPE_name!   (reduce 52)

   .  reduce 52



state 82
   type_mark :  SUBTYPE_name!   (reduce 53)

   .  reduce 53



state 83
   subprogram_body :  subprogram_specification IS!declarative_part BEGIN sequence_of_statements o.EXCEPTION END o.designator ; 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 165
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 84
   package_declaration :  package_specification ;!   (reduce 309)

   .  reduce 309



state 85
   generic_declaration :  generic_specification ;!   (reduce 403)

   .  reduce 403



state 86
   package_specification :  PACKAGE IDENTIFIER!IS declarative_part o.private_part END PACKAGE_name 
   generic_instantiation :  PACKAGE IDENTIFIER!IS NEW GENERIC_PACKAGE_name o.generic_actual_part ; 

   IS  shift 204
   .  error



state 87
   package_body :  PACKAGE BODY!PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 

   PACKAGE_name  shift 205
   .  error



88: shift/reduce conflict (shift 207, reduce 279) on IS
state 88
   subprogram_specification :  PROCEDURE IDENTIFIER!formal_part 
   subprogram_specification :  PROCEDURE IDENTIFIER!   (reduce 279)
   generic_instantiation :  PROCEDURE IDENTIFIER!IS NEW GENERIC_PROCEDURE_name o.generic_actual_part ; 

   IS  shift 207
   (  shift 208
   .  reduce 279

   formal_part  goto 206


state 89
   subprogram_specification :  FUNCTION designator!formal_part RETURN type_mark 
   subprogram_specification :  FUNCTION designator!RETURN type_mark 
   generic_instantiation :  FUNCTION designator!IS NEW GENERIC_FUNCTION_name o.generic_actual_part ; 

   IS  shift 211
   RETURN  shift 210
   (  shift 208
   .  error

   formal_part  goto 209


state 90
   designator :  IDENTIFIER!   (reduce 282)

   .  reduce 282



state 91
   designator :  operator_symbol!   (reduce 283)

   .  reduce 283



state 92
   subunit :  SEPARATE (!PARENT_UNIT_name ) proper_body 

   PARENT_UNIT_name  shift 212
   .  error



state 93
   generic_specification :  generic_formal_part subprogram_specification!   (reduce 404)

   .  reduce 404



state 94
   generic_specification :  generic_formal_part package_specification!   (reduce 405)

   .  reduce 405



state 95
   subprogram_specification :  PROCEDURE!IDENTIFIER formal_part 
   subprogram_specification :  PROCEDURE!IDENTIFIER 

   IDENTIFIER  shift 213
   .  error



state 96
   subprogram_specification :  FUNCTION!designator formal_part RETURN type_mark 
   subprogram_specification :  FUNCTION!designator RETURN type_mark 

   IDENTIFIER  shift 90
   OPERATOR_STRING_LITERAL  shift 58
   .  error

   operator_symbol  goto 91
   designator  goto 214


state 97
   package_specification :  PACKAGE!IDENTIFIER IS declarative_part o.private_part END PACKAGE_name 

   IDENTIFIER  shift 215
   .  error



state 98
   generic_formal_part :  GENERIC r.generic_parameter_declaration!   (reduce 406)

   .  reduce 406



state 99
   r.generic_parameter_declaration :  generic_parameter_declaration!r.generic_parameter_declaration 
   r.generic_parameter_declaration : !   (reduce 408)

   TYPE  shift 101
   WITH  shift 103
   IDENTIFIER  shift 104
   .  reduce 408

   identifier_list  goto 100
   private_type_declaration  goto 102
   r.generic_parameter_declaration  goto 216
   generic_parameter_declaration  goto 99


state 100
   generic_parameter_declaration :  identifier_list!: mode type_mark o.expression ; 

   :  shift 217
   .  error



state 101
   private_type_declaration :  TYPE!IDENTIFIER o.discriminant_part IS o.LIMITED PRIVATE ; 
   generic_parameter_declaration :  TYPE!IDENTIFIER IS generic_type_definition ; 

   IDENTIFIER  shift 218
   .  error



state 102
   generic_parameter_declaration :  private_type_declaration!   (reduce 411)

   .  reduce 411



state 103
   generic_parameter_declaration :  WITH!subprogram_specification IS name ; 
   generic_parameter_declaration :  WITH!subprogram_specification IS BOX ; 
   generic_parameter_declaration :  WITH!subprogram_specification ; 

   FUNCTION  shift 96
   PROCEDURE  shift 95
   .  error

   subprogram_specification  goto 219


state 104
   identifier_list :  IDENTIFIER!r.identifier 
   r.identifier : !   (reduce 36)

   ,  shift 221
   .  reduce 36

   r.identifier  goto 220


state 105
   with_clause :  WITH UNIT_name r.UNIT_name ;!   (reduce 388)

   .  reduce 388



state 106
   r.UNIT_name :  , UNIT_name!r.UNIT_name 
   r.UNIT_name : !   (reduce 390)

   ,  shift 42
   .  reduce 390

   r.UNIT_name  goto 222


state 107
   use_clause :  USE PACKAGE_name r.PACKAGE_name ;!   (reduce 322)

   .  reduce 322



state 108
   r.PACKAGE_name :  , PACKAGE_name!r.PACKAGE_name 
   r.PACKAGE_name : !   (reduce 324)

   ,  shift 44
   .  reduce 324

   r.PACKAGE_name  goto 223


state 109
   pragma :  PRAGMA IDENTIFIER ( argument_association r.argument_association!) ; 

   )  shift 224
   .  error



state 110
   r.argument_association :  ,!argument_association r.argument_association 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   ARGUMENT_identifier  shift 46
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   argument_association  goto 225
   name  goto 47
   expression  goto 48
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 111
   argument_association :  ARGUMENT_identifier ASSOC!name 
   argument_association :  ARGUMENT_identifier ASSOC!expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 226
   expression  goto 227
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 112
   expression :  relation AND!relation 
   expression :  relation AND!THEN relation 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   THEN  shift 229
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 228
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 113
   expression :  relation OR!relation 
   expression :  relation OR!ELSE relation 

   ABS  shift 69
   ELSE  shift 231
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 230
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 114
   expression :  relation XOR!relation 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 232
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 115
   indexed_component :  prefix (!expression r.expression ) 
   slice :  prefix (!discrete_range ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 233
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 235
   discrete_range  goto 234
   discrete_subtype_indication  goto 154
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 116
   selected_component :  prefix .!selector 

   ALL  shift 240
   CHARACTER_LITERAL  shift 238
   IDENTIFIER  shift 57
   OPERATOR_STRING_LITERAL  shift 58
   .  error

   simple_name  goto 237
   operator_symbol  goto 239
   selector  goto 236


state 117
   attribute :  prefix PRIME!attribute_designator 

   IDENTIFIER  shift 57
   .  error

   simple_name  goto 242
   attribute_designator  goto 241


state 118
   relation :  simple_expression =!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 243
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 119
   relation :  simple_expression NE!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 244
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 120
   relation :  simple_expression <!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 245
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 121
   relation :  simple_expression LE!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 246
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 122
   relation :  simple_expression >!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 247
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 123
   relation :  simple_expression GE!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 248
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 124
   relation :  simple_expression NOT!IN range 
   relation :  simple_expression NOT!IN type_mark 

   IN  shift 249
   .  error



state 125
   relation :  simple_expression IN!range 
   relation :  simple_expression IN!type_mark 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 251
   range  goto 250
   RANGE_attribute  goto 157
   simple_expression  goto 252
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 126
   simple_expression :  s.term +!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 253
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 127
   simple_expression :  s.term -!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 254
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 128
   simple_expression :  s.term &!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 255
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 129
   function_call :  FUNCTION_name actual_parameter_part!   (reduce 298)

   .  reduce 298



130: shift/reduce conflict (shift 69, reduce 302) on ABS
130: shift/reduce conflict (shift 79, reduce 302) on NEW
130: shift/reduce conflict (shift 70, reduce 302) on NOT
130: shift/reduce conflict (shift 78, reduce 302) on NULL
130: shift/reduce conflict (shift 50, reduce 302) on CHARACTER_LITERAL
130: shift/reduce conflict (shift 57, reduce 302) on IDENTIFIER
130: shift/reduce conflict (shift 76, reduce 302) on NUMERIC_LITERAL
130: shift/reduce conflict (shift 58, reduce 302) on OPERATOR_STRING_LITERAL
130: shift/reduce conflict (shift 77, reduce 302) on STRING_LITERAL
130: shift/reduce conflict (shift 64, reduce 302) on +
130: shift/reduce conflict (shift 65, reduce 302) on -
130: shift/reduce conflict (shift 63, reduce 302) on FUNCTION_name
130: shift/reduce conflict (shift 133, reduce 302) on PARAMETER_name
130: shift/reduce conflict (shift 82, reduce 302) on SUBTYPE_name
130: shift/reduce conflict (shift 81, reduce 302) on TYPE_name
130: shift/reduce conflict (shift 135, reduce 302) on VARIABLE_name
130: shift/reduce conflict (shift 75, reduce 302) on (
state 130
   actual_parameter_part :  parameter_association!r.parameter_association 
   r.parameter_association : !   (reduce 302)

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   PARAMETER_name  shift 133
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 135
   (  shift 75
   .  reduce 302

   name  goto 137
   expression  goto 134
   type_mark  goto 136
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   parameter_association  goto 257
   r.parameter_association  goto 256
   formal_parameter  goto 131
   actual_parameter  goto 132


state 131
   parameter_association :  formal_parameter!ASSOC actual_parameter 

   ASSOC  shift 258
   .  error



state 132
   parameter_association :  actual_parameter!   (reduce 304)

   .  reduce 304



state 133
   formal_parameter :  PARAMETER_name!   (reduce 305)

   .  reduce 305



state 134
   actual_parameter :  expression!   (reduce 306)

   .  reduce 306



state 135
   actual_parameter :  VARIABLE_name!   (reduce 307)

   .  reduce 307



state 136
   type_conversion :  type_mark!( expression ) 
   qualified_expression :  type_mark!PRIME ( expression ) 
   qualified_expression :  type_mark!PRIME aggregate 
   actual_parameter :  type_mark!( VARIABLE_name ) 

   PRIME  shift 164
   (  shift 259
   .  error



137: reduce/reduce conflict (reductions 146 and 201) on PRIME
137: reduce/reduce conflict (reductions 146 and 201) on (
137: reduce/reduce conflict (reductions 146 and 201) on .
state 137
   prefix :  name!   (reduce 146)
   primary :  name!   (reduce 201)

   PRIME  reduce 146
   (  reduce 146
   .  reduce 146
   .  reduce 201



state 138
   s.term :  + term!   (reduce 188)

   .  reduce 188



state 139
   s.term :  - term!   (reduce 189)

   .  reduce 189



state 140
   term :  factor *!term 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   term  goto 260
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 141
   term :  factor /!term 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   term  goto 261
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 142
   term :  factor MOD!term 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   term  goto 262
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 143
   term :  factor REM!term 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   term  goto 263
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 144
   factor :  primary STARSTAR!primary 

   NEW  shift 79
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   primary  goto 264
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 145
   factor :  ABS primary!   (reduce 197)

   .  reduce 197



state 146
   factor :  NOT primary!   (reduce 198)

   .  reduce 198



state 147
   aggregate :  ( component_association!r.component_association ) 
   r.component_association : !   (reduce 163)

   ,  shift 266
   .  reduce 163

   r.component_association  goto 265


148: shift/reduce conflict (shift 267, reduce 165) on )
state 148
   component_association :  expression!   (reduce 165)
   primary :  ( expression!) 

   )  shift 267
   .  reduce 165



state 149
   component_association :  choice!r.choice ASSOC expression 
   r.choice : !   (reduce 118)

   |  shift 269
   .  reduce 118

   r.choice  goto 268


state 150
   range :  simple_expression!DOTDOT simple_expression 
   choice :  simple_expression!   (reduce 119)
   relation :  simple_expression!= simple_expression 
   relation :  simple_expression!NE simple_expression 
   relation :  simple_expression!< simple_expression 
   relation :  simple_expression!LE simple_expression 
   relation :  simple_expression!> simple_expression 
   relation :  simple_expression!GE simple_expression 
   relation :  simple_expression!NOT IN range 
   relation :  simple_expression!NOT IN type_mark 
   relation :  simple_expression!IN range 
   relation :  simple_expression!IN type_mark 
   relation :  simple_expression!   (reduce 183)

   ASSOC  reduce 119
   IN  shift 125
   NOT  shift 124
   DOTDOT  shift 270
   GE  shift 123
   LE  shift 121
   NE  shift 119
   =  shift 118
   <  shift 120
   >  shift 122
   |  reduce 119
   .  reduce 183



state 151
   choice :  discrete_range!   (reduce 120)

   .  reduce 120



state 152
   choice :  OTHERS!   (reduce 121)

   .  reduce 121



state 153
   choice :  COMPONENT_name!   (reduce 122)

   .  reduce 122



state 154
   discrete_range :  discrete_subtype_indication!   (reduce 90)

   .  reduce 90



state 155
   discrete_range :  range!   (reduce 91)

   .  reduce 91



state 156
   discrete_subtype_indication :  subtype_indication!   (reduce 92)

   .  reduce 92



state 157
   range :  RANGE_attribute!   (reduce 61)

   .  reduce 61



state 158
   subtype_indication :  type_mark!constraint 
   subtype_indication :  type_mark!   (reduce 51)
   type_conversion :  type_mark!( expression ) 
   qualified_expression :  type_mark!PRIME ( expression ) 
   qualified_expression :  type_mark!PRIME aggregate 

   DELTA  shift 282
   DIGITS  shift 281
   RANGE  shift 278
   PRIME  shift 164
   (  shift 272
   .  reduce 51

   constraint  goto 271
   range_constraint  goto 273
   floating_point_constraint  goto 274
   fixed_point_constraint  goto 275
   index_constraint  goto 276
   discriminant_constraint  goto 277
   floating_accuracy_definition  goto 279
   fixed_accuracy_definition  goto 280


159: reduce/reduce conflict (reductions 144 and 160) on AND
159: reduce/reduce conflict (reductions 144 and 160) on ASSOC
159: reduce/reduce conflict (reductions 144 and 160) on IN
159: reduce/reduce conflict (reductions 144 and 160) on MOD
159: reduce/reduce conflict (reductions 144 and 160) on NOT
159: reduce/reduce conflict (reductions 144 and 160) on OR
159: reduce/reduce conflict (reductions 144 and 160) on REM
159: reduce/reduce conflict (reductions 144 and 160) on XOR
159: reduce/reduce conflict (reductions 144 and 160) on DOTDOT
159: reduce/reduce conflict (reductions 144 and 160) on GE
159: reduce/reduce conflict (reductions 144 and 160) on LE
159: reduce/reduce conflict (reductions 144 and 160) on NE
159: reduce/reduce conflict (reductions 144 and 160) on PRIME
159: reduce/reduce conflict (reductions 144 and 160) on STARSTAR
159: reduce/reduce conflict (reductions 144 and 160) on =
159: reduce/reduce conflict (reductions 144 and 160) on <
159: reduce/reduce conflict (reductions 144 and 160) on >
159: reduce/reduce conflict (reductions 144 and 160) on +
159: reduce/reduce conflict (reductions 144 and 160) on -
159: reduce/reduce conflict (reductions 144 and 160) on &
159: reduce/reduce conflict (reductions 144 and 160) on *
159: reduce/reduce conflict (reductions 144 and 160) on /
159: reduce/reduce conflict (reductions 144 and 160) on (
159: reduce/reduce conflict (reductions 144 and 160) on )
159: reduce/reduce conflict (reductions 144 and 160) on ,
159: reduce/reduce conflict (reductions 144 and 160) on |
159: reduce/reduce conflict (reductions 144 and 160) on .
state 159
   name :  attribute!   (reduce 144)
   RANGE_attribute :  attribute!   (reduce 160)

   ABS  reduce 160
   IS  reduce 160
   LOOP  reduce 160
   NEW  reduce 160
   NULL  reduce 160
   RANGE  reduce 160
   RENAMES  reduce 160
   THEN  reduce 160
   BECOMES  reduce 160
   CHARACTER_LITERAL  reduce 160
   IDENTIFIER  reduce 160
   NUMERIC_LITERAL  reduce 160
   OPERATOR_STRING_LITERAL  reduce 160
   STRING_LITERAL  reduce 160
   FUNCTION_name  reduce 160
   PARAMETER_name  reduce 160
   SUBTYPE_name  reduce 160
   TYPE_name  reduce 160
   VARIABLE_name  reduce 160
   ;  reduce 160
   .  reduce 144



state 160
   allocator :  NEW subtype_indication!   (reduce 216)

   .  reduce 216



state 161
   allocator :  NEW qualified_expression!   (reduce 217)

   .  reduce 217



162: shift/reduce conflict (shift 278, reduce 51) on RANGE
162: shift/reduce conflict (shift 164, reduce 51) on PRIME
162: shift/reduce conflict (shift 283, reduce 51) on (
state 162
   subtype_indication :  type_mark!constraint 
   subtype_indication :  type_mark!   (reduce 51)
   qualified_expression :  type_mark!PRIME ( expression ) 
   qualified_expression :  type_mark!PRIME aggregate 

   DELTA  shift 282
   DIGITS  shift 281
   RANGE  shift 278
   PRIME  shift 164
   (  shift 283
   .  reduce 51

   constraint  goto 271
   range_constraint  goto 273
   floating_point_constraint  goto 274
   fixed_point_constraint  goto 275
   index_constraint  goto 276
   discriminant_constraint  goto 277
   floating_accuracy_definition  goto 279
   fixed_accuracy_definition  goto 280


state 163
   type_conversion :  type_mark (!expression ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 284
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 164
   qualified_expression :  type_mark PRIME!( expression ) 
   qualified_expression :  type_mark PRIME!aggregate 

   (  shift 285
   .  error

   aggregate  goto 286


state 165
   subprogram_body :  subprogram_specification IS declarative_part!BEGIN sequence_of_statements o.EXCEPTION END o.designator ; 

   BEGIN  shift 287
   .  error



state 166
   declarative_part :  r.declarative_part!declarative_part 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 288
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 167
   r.declarative_part :  pragma!   (reduce 128)

   .  reduce 128



state 168
   r.declarative_part :  basic_declaration!   (reduce 129)

   .  reduce 129



state 169
   r.declarative_part :  representation_clause!   (reduce 130)

   .  reduce 130



state 170
   r.declarative_part :  use_clause!   (reduce 131)

   .  reduce 131



state 171
   r.declarative_part :  body!   (reduce 132)

   .  reduce 132



state 172
   basic_declaration :  object_declaration!   (reduce 11)

   .  reduce 11



state 173
   basic_declaration :  number_declaration!   (reduce 12)

   .  reduce 12



state 174
   basic_declaration :  type_declaration!   (reduce 13)

   .  reduce 13



state 175
   basic_declaration :  subtype_declaration!   (reduce 14)

   .  reduce 14



state 176
   basic_declaration :  subprogram_declaration!   (reduce 15)

   .  reduce 15



state 177
   basic_declaration :  package_declaration!   (reduce 16)

   .  reduce 16



state 178
   basic_declaration :  task_declaration!   (reduce 17)

   .  reduce 17



state 179
   basic_declaration :  generic_declaration!   (reduce 18)

   .  reduce 18



state 180
   basic_declaration :  exception_declaration!   (reduce 19)

   .  reduce 19



state 181
   basic_declaration :  generic_instantiation!   (reduce 20)

   .  reduce 20



state 182
   basic_declaration :  deferred_constant_declaration!   (reduce 21)

   .  reduce 21



state 183
   representation_clause :  type_representation_clause!   (reduce 437)

   .  reduce 437



state 184
   representation_clause :  address_clause!   (reduce 438)

   .  reduce 438



state 185
   body :  proper_body!   (reduce 133)

   .  reduce 133



state 186
   body :  body_stub!   (reduce 134)

   .  reduce 134



state 187
   object_declaration :  identifier_list!: object_specification ; 
   number_declaration :  identifier_list!: CONSTANT BECOMES UNIVERSAL_STATIC_expression ; 
   deferred_constant_declaration :  identifier_list!: CONSTANT type_mark ; 
   exception_declaration :  identifier_list!: EXCEPTION ; 

   :  shift 289
   .  error



state 188
   object_declaration :  PACKAGE!IDENTIFIER RENAMES SUBPROGRAM_name ; 
   object_declaration :  PACKAGE!IDENTIFIER RENAMES ENTRY_name ; 
   package_specification :  PACKAGE!IDENTIFIER IS declarative_part o.private_part END PACKAGE_name 
   package_body :  PACKAGE!BODY PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 
   body_stub :  PACKAGE!BODY PACKAGE_name IS SEPARATE ; 
   generic_instantiation :  PACKAGE!IDENTIFIER IS NEW GENERIC_PACKAGE_name o.generic_actual_part ; 

   BODY  shift 291
   IDENTIFIER  shift 290
   .  error



state 189
   type_declaration :  full_type_declaration!   (reduce 37)

   .  reduce 37



state 190
   type_declaration :  incomplete_type_declaration!   (reduce 38)

   .  reduce 38



state 191
   type_declaration :  private_type_declaration!   (reduce 39)

   .  reduce 39



state 192
   subtype_declaration :  SUBTYPE!IDENTIFIER IS subtype_indication ; 

   IDENTIFIER  shift 292
   .  error



state 193
   subprogram_declaration :  subprogram_specification!   (reduce 277)
   subprogram_body :  subprogram_specification!IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END o.designator ; 
   body_stub :  subprogram_specification!IS SEPARATE ; 

   IS  shift 293
   .  reduce 277



state 194
   task_declaration :  task_specification!; 

   ;  shift 294
   .  error



state 195
   type_representation_clause :  length_clause!   (reduce 439)

   .  reduce 439



state 196
   type_representation_clause :  enumeration_representation_clause!   (reduce 440)

   .  reduce 440



state 197
   type_representation_clause :  record_representation_clause!   (reduce 441)

   .  reduce 441



state 198
   length_clause :  FOR!attribute USE simple_expression ; 
   enumeration_representation_clause :  FOR!TYPE_name USE aggregate ; 
   record_representation_clause :  FOR!TYPE_name USE RECORD o.alignment_clause o.component_clause END RECORD ; 
   address_clause :  FOR!simple_name USE AT simple_expression ; 

   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   OPERATOR_STRING_LITERAL  shift 58
   FUNCTION_name  shift 63
   TYPE_name  shift 296
   .  error

   name  goto 298
   simple_name  goto 297
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 295
   prefix  goto 59
   function_call  goto 299


state 199
   proper_body :  subprogram_body!   (reduce 135)

   .  reduce 135



state 200
   proper_body :  package_body!   (reduce 136)

   .  reduce 136



state 201
   proper_body :  task_body!   (reduce 137)

   .  reduce 137



state 202
   task_specification :  TASK!o.TYPE IDENTIFIER IS r.entry_declaration r.representation_clause END TASK_name 
   task_body :  TASK!BODY TASK_name IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 
   body_stub :  TASK!BODY TASK_name IS SEPARATE ; 
   o.TYPE : !   (reduce 328)

   BODY  shift 301
   TYPE  shift 302
   .  reduce 328

   o.TYPE  goto 300


state 203
   full_type_declaration :  TYPE!IDENTIFIER discriminant_part IS type_definition ; 
   full_type_declaration :  TYPE!IDENTIFIER IS type_definition ; 
   incomplete_type_declaration :  TYPE!IDENTIFIER discriminant_part ; 
   incomplete_type_declaration :  TYPE!IDENTIFIER ; 
   private_type_declaration :  TYPE!IDENTIFIER o.discriminant_part IS o.LIMITED PRIVATE ; 

   IDENTIFIER  shift 303
   .  error



state 204
   package_specification :  PACKAGE IDENTIFIER IS!declarative_part o.private_part END PACKAGE_name 
   generic_instantiation :  PACKAGE IDENTIFIER IS!NEW GENERIC_PACKAGE_name o.generic_actual_part ; 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   NEW  shift 305
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 304
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 205
   package_body :  PACKAGE BODY PACKAGE_name!IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 

   IS  shift 306
   .  error



state 206
   subprogram_specification :  PROCEDURE IDENTIFIER formal_part!   (reduce 278)

   .  reduce 278



state 207
   generic_instantiation :  PROCEDURE IDENTIFIER IS!NEW GENERIC_PROCEDURE_name o.generic_actual_part ; 

   NEW  shift 307
   .  error



state 208
   formal_part :  (!parameter_specification r.parameter_specification ) 

   IDENTIFIER  shift 104
   .  error

   identifier_list  goto 309
   parameter_specification  goto 308


state 209
   subprogram_specification :  FUNCTION designator formal_part!RETURN type_mark 

   RETURN  shift 310
   .  error



state 210
   subprogram_specification :  FUNCTION designator RETURN!type_mark 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   type_mark  goto 311


state 211
   generic_instantiation :  FUNCTION designator IS!NEW GENERIC_FUNCTION_name o.generic_actual_part ; 

   NEW  shift 312
   .  error



state 212
   subunit :  SEPARATE ( PARENT_UNIT_name!) proper_body 

   )  shift 313
   .  error



state 213
   subprogram_specification :  PROCEDURE IDENTIFIER!formal_part 
   subprogram_specification :  PROCEDURE IDENTIFIER!   (reduce 279)

   (  shift 208
   .  reduce 279

   formal_part  goto 206


state 214
   subprogram_specification :  FUNCTION designator!formal_part RETURN type_mark 
   subprogram_specification :  FUNCTION designator!RETURN type_mark 

   RETURN  shift 210
   (  shift 208
   .  error

   formal_part  goto 209


state 215
   package_specification :  PACKAGE IDENTIFIER!IS declarative_part o.private_part END PACKAGE_name 

   IS  shift 314
   .  error



state 216
   r.generic_parameter_declaration :  generic_parameter_declaration r.generic_parameter_declaration!   (reduce 407)

   .  reduce 407



state 217
   generic_parameter_declaration :  identifier_list :!mode type_mark o.expression ; 
   mode : !   (reduce 292)

   IN  shift 316
   OUT  shift 317
   .  reduce 292

   mode  goto 315


218: shift/reduce conflict (shift 319, reduce 318) on IS
state 218
   private_type_declaration :  TYPE IDENTIFIER!o.discriminant_part IS o.LIMITED PRIVATE ; 
   generic_parameter_declaration :  TYPE IDENTIFIER!IS generic_type_definition ; 
   o.discriminant_part : !   (reduce 318)

   IS  shift 319
   (  shift 321
   .  error

   discriminant_part  goto 320
   o.discriminant_part  goto 318


state 219
   generic_parameter_declaration :  WITH subprogram_specification!IS name ; 
   generic_parameter_declaration :  WITH subprogram_specification!IS BOX ; 
   generic_parameter_declaration :  WITH subprogram_specification!; 

   IS  shift 322
   ;  shift 323
   .  error



state 220
   identifier_list :  IDENTIFIER r.identifier!   (reduce 34)

   .  reduce 34



state 221
   r.identifier :  ,!IDENTIFIER r.identifier 

   IDENTIFIER  shift 324
   .  error



state 222
   r.UNIT_name :  , UNIT_name r.UNIT_name!   (reduce 389)

   .  reduce 389



state 223
   r.PACKAGE_name :  , PACKAGE_name r.PACKAGE_name!   (reduce 323)

   .  reduce 323



state 224
   pragma :  PRAGMA IDENTIFIER ( argument_association r.argument_association )!; 

   ;  shift 325
   .  error



state 225
   r.argument_association :  , argument_association!r.argument_association 
   r.argument_association : !   (reduce 4)

   ,  shift 110
   .  reduce 4

   r.argument_association  goto 326


226: reduce/reduce conflict (reductions 5 and 201) on )
226: reduce/reduce conflict (reductions 5 and 201) on ,
state 226
   argument_association :  ARGUMENT_identifier ASSOC name!   (reduce 5)
   prefix :  name!   (reduce 146)
   primary :  name!   (reduce 201)

   PRIME  reduce 146
   (  reduce 146
   )  reduce 5
   ,  reduce 5
   .  reduce 146
   .  reduce 201



state 227
   argument_association :  ARGUMENT_identifier ASSOC expression!   (reduce 6)

   .  reduce 6



state 228
   expression :  relation AND relation!   (reduce 167)

   .  reduce 167



state 229
   expression :  relation AND THEN!relation 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 327
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 230
   expression :  relation OR relation!   (reduce 169)

   .  reduce 169



state 231
   expression :  relation OR ELSE!relation 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 328
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 232
   expression :  relation XOR relation!   (reduce 171)

   .  reduce 171



state 233
   indexed_component :  prefix ( expression!r.expression ) 
   r.expression : !   (reduce 150)

   ,  shift 330
   .  reduce 150

   r.expression  goto 329


state 234
   slice :  prefix ( discrete_range!) 

   )  shift 331
   .  error



state 235
   range :  simple_expression!DOTDOT simple_expression 
   relation :  simple_expression!= simple_expression 
   relation :  simple_expression!NE simple_expression 
   relation :  simple_expression!< simple_expression 
   relation :  simple_expression!LE simple_expression 
   relation :  simple_expression!> simple_expression 
   relation :  simple_expression!GE simple_expression 
   relation :  simple_expression!NOT IN range 
   relation :  simple_expression!NOT IN type_mark 
   relation :  simple_expression!IN range 
   relation :  simple_expression!IN type_mark 
   relation :  simple_expression!   (reduce 183)

   IN  shift 125
   NOT  shift 124
   DOTDOT  shift 270
   GE  shift 123
   LE  shift 121
   NE  shift 119
   =  shift 118
   <  shift 120
   >  shift 122
   .  reduce 183



state 236
   selected_component :  prefix . selector!   (reduce 152)

   .  reduce 152



state 237
   selector :  simple_name!   (reduce 153)

   .  reduce 153



state 238
   selector :  CHARACTER_LITERAL!   (reduce 154)

   .  reduce 154



state 239
   selector :  operator_symbol!   (reduce 155)

   .  reduce 155



state 240
   selector :  ALL!   (reduce 156)

   .  reduce 156



state 241
   attribute :  prefix PRIME attribute_designator!   (reduce 157)

   .  reduce 157



242: shift/reduce conflict (shift 332, reduce 159) on (
state 242
   attribute_designator :  simple_name!( UNIVERSAL_STATIC_expression ) 
   attribute_designator :  simple_name!   (reduce 159)

   (  shift 332
   .  reduce 159



state 243
   relation :  simple_expression = simple_expression!   (reduce 173)

   .  reduce 173



state 244
   relation :  simple_expression NE simple_expression!   (reduce 174)

   .  reduce 174



state 245
   relation :  simple_expression < simple_expression!   (reduce 175)

   .  reduce 175



state 246
   relation :  simple_expression LE simple_expression!   (reduce 176)

   .  reduce 176



state 247
   relation :  simple_expression > simple_expression!   (reduce 177)

   .  reduce 177



state 248
   relation :  simple_expression GE simple_expression!   (reduce 178)

   .  reduce 178



state 249
   relation :  simple_expression NOT IN!range 
   relation :  simple_expression NOT IN!type_mark 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 334
   range  goto 333
   RANGE_attribute  goto 157
   simple_expression  goto 252
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 250
   relation :  simple_expression IN range!   (reduce 181)

   .  reduce 181



251: shift/reduce conflict (shift 164, reduce 182) on PRIME
251: shift/reduce conflict (shift 163, reduce 182) on (
state 251
   relation :  simple_expression IN type_mark!   (reduce 182)
   type_conversion :  type_mark!( expression ) 
   qualified_expression :  type_mark!PRIME ( expression ) 
   qualified_expression :  type_mark!PRIME aggregate 

   PRIME  shift 164
   (  shift 163
   .  reduce 182



state 252
   range :  simple_expression!DOTDOT simple_expression 

   DOTDOT  shift 270
   .  error



state 253
   simple_expression :  s.term + simple_expression!   (reduce 184)

   .  reduce 184



state 254
   simple_expression :  s.term - simple_expression!   (reduce 185)

   .  reduce 185



state 255
   simple_expression :  s.term & simple_expression!   (reduce 186)

   .  reduce 186



state 256
   actual_parameter_part :  parameter_association r.parameter_association!   (reduce 300)

   .  reduce 300



257: shift/reduce conflict (shift 69, reduce 302) on ABS
257: shift/reduce conflict (shift 79, reduce 302) on NEW
257: shift/reduce conflict (shift 70, reduce 302) on NOT
257: shift/reduce conflict (shift 78, reduce 302) on NULL
257: shift/reduce conflict (shift 50, reduce 302) on CHARACTER_LITERAL
257: shift/reduce conflict (shift 57, reduce 302) on IDENTIFIER
257: shift/reduce conflict (shift 76, reduce 302) on NUMERIC_LITERAL
257: shift/reduce conflict (shift 58, reduce 302) on OPERATOR_STRING_LITERAL
257: shift/reduce conflict (shift 77, reduce 302) on STRING_LITERAL
257: shift/reduce conflict (shift 64, reduce 302) on +
257: shift/reduce conflict (shift 65, reduce 302) on -
257: shift/reduce conflict (shift 63, reduce 302) on FUNCTION_name
257: shift/reduce conflict (shift 133, reduce 302) on PARAMETER_name
257: shift/reduce conflict (shift 82, reduce 302) on SUBTYPE_name
257: shift/reduce conflict (shift 81, reduce 302) on TYPE_name
257: shift/reduce conflict (shift 135, reduce 302) on VARIABLE_name
257: shift/reduce conflict (shift 75, reduce 302) on (
state 257
   r.parameter_association :  parameter_association!r.parameter_association 
   r.parameter_association : !   (reduce 302)

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   PARAMETER_name  shift 133
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 135
   (  shift 75
   .  reduce 302

   name  goto 137
   expression  goto 134
   type_mark  goto 136
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   parameter_association  goto 257
   r.parameter_association  goto 335
   formal_parameter  goto 131
   actual_parameter  goto 132


state 258
   parameter_association :  formal_parameter ASSOC!actual_parameter 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 135
   (  shift 75
   .  error

   name  goto 137
   expression  goto 134
   type_mark  goto 136
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   actual_parameter  goto 336


state 259
   type_conversion :  type_mark (!expression ) 
   actual_parameter :  type_mark (!VARIABLE_name ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 337
   (  shift 75
   .  error

   name  goto 137
   expression  goto 284
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 260
   term :  factor * term!   (reduce 191)

   .  reduce 191



state 261
   term :  factor / term!   (reduce 192)

   .  reduce 192



state 262
   term :  factor MOD term!   (reduce 193)

   .  reduce 193



state 263
   term :  factor REM term!   (reduce 194)

   .  reduce 194



state 264
   factor :  primary STARSTAR primary!   (reduce 196)

   .  reduce 196



state 265
   aggregate :  ( component_association r.component_association!) 

   )  shift 338
   .  error



state 266
   r.component_association :  ,!component_association r.component_association 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   OTHERS  shift 152
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   COMPONENT_name  shift 153
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 340
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 150
   discrete_range  goto 151
   discrete_subtype_indication  goto 154
   choice  goto 149
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   component_association  goto 339
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 267
   primary :  ( expression )!   (reduce 206)

   .  reduce 206



state 268
   component_association :  choice r.choice!ASSOC expression 

   ASSOC  shift 341
   .  error



state 269
   r.choice :  |!choice r.choice 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   OTHERS  shift 152
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   COMPONENT_name  shift 153
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 343
   discrete_range  goto 151
   discrete_subtype_indication  goto 154
   choice  goto 342
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 270
   range :  simple_expression DOTDOT!simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 344
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 271
   subtype_indication :  type_mark constraint!   (reduce 50)

   .  reduce 50



272: shift/reduce conflict (shift 69, reduce 110) on ABS
272: shift/reduce conflict (shift 79, reduce 110) on NEW
272: shift/reduce conflict (shift 70, reduce 110) on NOT
272: shift/reduce conflict (shift 78, reduce 110) on NULL
272: shift/reduce conflict (shift 50, reduce 110) on CHARACTER_LITERAL
272: shift/reduce conflict (shift 57, reduce 110) on IDENTIFIER
272: shift/reduce conflict (shift 76, reduce 110) on NUMERIC_LITERAL
272: shift/reduce conflict (shift 58, reduce 110) on OPERATOR_STRING_LITERAL
272: shift/reduce conflict (shift 77, reduce 110) on STRING_LITERAL
272: shift/reduce conflict (shift 64, reduce 110) on +
272: shift/reduce conflict (shift 65, reduce 110) on -
272: shift/reduce conflict (shift 63, reduce 110) on FUNCTION_name
272: shift/reduce conflict (shift 82, reduce 110) on SUBTYPE_name
272: shift/reduce conflict (shift 81, reduce 110) on TYPE_name
272: shift/reduce conflict (shift 75, reduce 110) on (
state 272
   index_constraint :  (!discrete_range r.discrete_range ) 
   discriminant_constraint :  (!discriminant_association r.discriminant_association ) 
   type_conversion :  type_mark (!expression ) 
   o.DISCRIMINANT_name : !   (reduce 110)

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   DISCRIMINANT_name  shift 348
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 284
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 235
   discrete_range  goto 345
   discrete_subtype_indication  goto 154
   discriminant_association  goto 346
   o.DISCRIMINANT_name  goto 347
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 273
   constraint :  range_constraint!   (reduce 54)

   .  reduce 54



state 274
   constraint :  floating_point_constraint!   (reduce 55)

   .  reduce 55



state 275
   constraint :  fixed_point_constraint!   (reduce 56)

   .  reduce 56



state 276
   constraint :  index_constraint!   (reduce 57)

   .  reduce 57



state 277
   constraint :  discriminant_constraint!   (reduce 58)

   .  reduce 58



state 278
   range_constraint :  RANGE!range 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   range  goto 349
   RANGE_attribute  goto 157
   simple_expression  goto 252
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


279: shift/reduce conflict (shift 278, reduce 74) on RANGE
state 279
   floating_point_constraint :  floating_accuracy_definition!range_constraint 
   floating_point_constraint :  floating_accuracy_definition!   (reduce 74)

   RANGE  shift 278
   .  reduce 74

   range_constraint  goto 350


280: shift/reduce conflict (shift 278, reduce 77) on RANGE
state 280
   fixed_point_constraint :  fixed_accuracy_definition!range_constraint 
   fixed_point_constraint :  fixed_accuracy_definition!   (reduce 77)

   RANGE  shift 278
   .  reduce 77

   range_constraint  goto 351


state 281
   floating_accuracy_definition :  DIGITS!STATIC_simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 353
   STATIC_simple_expression  goto 352
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 282
   fixed_accuracy_definition :  DELTA!STATIC_simple_expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 353
   STATIC_simple_expression  goto 354
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


283: shift/reduce conflict (shift 69, reduce 110) on ABS
283: shift/reduce conflict (shift 79, reduce 110) on NEW
283: shift/reduce conflict (shift 70, reduce 110) on NOT
283: shift/reduce conflict (shift 78, reduce 110) on NULL
283: shift/reduce conflict (shift 50, reduce 110) on CHARACTER_LITERAL
283: shift/reduce conflict (shift 57, reduce 110) on IDENTIFIER
283: shift/reduce conflict (shift 76, reduce 110) on NUMERIC_LITERAL
283: shift/reduce conflict (shift 58, reduce 110) on OPERATOR_STRING_LITERAL
283: shift/reduce conflict (shift 77, reduce 110) on STRING_LITERAL
283: shift/reduce conflict (shift 64, reduce 110) on +
283: shift/reduce conflict (shift 65, reduce 110) on -
283: shift/reduce conflict (shift 63, reduce 110) on FUNCTION_name
283: shift/reduce conflict (shift 82, reduce 110) on SUBTYPE_name
283: shift/reduce conflict (shift 81, reduce 110) on TYPE_name
283: shift/reduce conflict (shift 75, reduce 110) on (
state 283
   index_constraint :  (!discrete_range r.discrete_range ) 
   discriminant_constraint :  (!discriminant_association r.discriminant_association ) 
   o.DISCRIMINANT_name : !   (reduce 110)

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   DISCRIMINANT_name  shift 348
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 252
   discrete_range  goto 345
   discrete_subtype_indication  goto 154
   discriminant_association  goto 346
   o.DISCRIMINANT_name  goto 347
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 284
   type_conversion :  type_mark ( expression!) 

   )  shift 355
   .  error



state 285
   aggregate :  (!component_association r.component_association ) 
   qualified_expression :  type_mark PRIME (!expression ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   OTHERS  shift 152
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   COMPONENT_name  shift 153
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 356
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 150
   discrete_range  goto 151
   discrete_subtype_indication  goto 154
   choice  goto 149
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   component_association  goto 147
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 286
   qualified_expression :  type_mark PRIME aggregate!   (reduce 215)

   .  reduce 215



state 287
   subprogram_body :  subprogram_specification IS declarative_part BEGIN!sequence_of_statements o.EXCEPTION END o.designator ; 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 357
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 288
   declarative_part :  r.declarative_part declarative_part!   (reduce 126)

   .  reduce 126



state 289
   object_declaration :  identifier_list :!object_specification ; 
   number_declaration :  identifier_list :!CONSTANT BECOMES UNIVERSAL_STATIC_expression ; 
   deferred_constant_declaration :  identifier_list :!CONSTANT type_mark ; 
   exception_declaration :  identifier_list :!EXCEPTION ; 

   ARRAY  shift 412
   CONSTANT  shift 407
   EXCEPTION  shift 408
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   object_specification  goto 406
   subtype_indication  goto 409
   constrained_array_definition  goto 410
   type_mark  goto 411


state 290
   object_declaration :  PACKAGE IDENTIFIER!RENAMES SUBPROGRAM_name ; 
   object_declaration :  PACKAGE IDENTIFIER!RENAMES ENTRY_name ; 
   package_specification :  PACKAGE IDENTIFIER!IS declarative_part o.private_part END PACKAGE_name 
   generic_instantiation :  PACKAGE IDENTIFIER!IS NEW GENERIC_PACKAGE_name o.generic_actual_part ; 

   IS  shift 204
   RENAMES  shift 413
   .  error



state 291
   package_body :  PACKAGE BODY!PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 
   body_stub :  PACKAGE BODY!PACKAGE_name IS SEPARATE ; 

   PACKAGE_name  shift 414
   .  error



state 292
   subtype_declaration :  SUBTYPE IDENTIFIER!IS subtype_indication ; 

   IS  shift 415
   .  error



state 293
   subprogram_body :  subprogram_specification IS!declarative_part BEGIN sequence_of_statements o.EXCEPTION END o.designator ; 
   body_stub :  subprogram_specification IS!SEPARATE ; 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SEPARATE  shift 416
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 165
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 294
   task_declaration :  task_specification ;!   (reduce 325)

   .  reduce 325



state 295
   name :  attribute!   (reduce 144)
   length_clause :  FOR attribute!USE simple_expression ; 

   USE  shift 417
   .  reduce 144



state 296
   enumeration_representation_clause :  FOR TYPE_name!USE aggregate ; 
   record_representation_clause :  FOR TYPE_name!USE RECORD o.alignment_clause o.component_clause END RECORD ; 

   USE  shift 418
   .  error



state 297
   name :  simple_name!   (reduce 138)
   address_clause :  FOR simple_name!USE AT simple_expression ; 

   USE  shift 419
   .  reduce 138



state 298
   prefix :  name!   (reduce 146)

   .  reduce 146



state 299
   prefix :  function_call!   (reduce 147)

   .  reduce 147



state 300
   task_specification :  TASK o.TYPE!IDENTIFIER IS r.entry_declaration r.representation_clause END TASK_name 

   IDENTIFIER  shift 420
   .  error



state 301
   task_body :  TASK BODY!TASK_name IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 
   body_stub :  TASK BODY!TASK_name IS SEPARATE ; 

   TASK_name  shift 421
   .  error



state 302
   o.TYPE :  TYPE!   (reduce 327)

   .  reduce 327



303: shift/reduce conflict (shift 423, reduce 318) on IS
state 303
   full_type_declaration :  TYPE IDENTIFIER!discriminant_part IS type_definition ; 
   full_type_declaration :  TYPE IDENTIFIER!IS type_definition ; 
   incomplete_type_declaration :  TYPE IDENTIFIER!discriminant_part ; 
   incomplete_type_declaration :  TYPE IDENTIFIER!; 
   private_type_declaration :  TYPE IDENTIFIER!o.discriminant_part IS o.LIMITED PRIVATE ; 
   o.discriminant_part : !   (reduce 318)

   IS  shift 423
   ;  shift 424
   (  shift 321
   .  error

   discriminant_part  goto 422
   o.discriminant_part  goto 318


state 304
   package_specification :  PACKAGE IDENTIFIER IS declarative_part!o.private_part END PACKAGE_name 
   o.private_part : !   (reduce 312)

   PRIVATE  shift 426
   .  reduce 312

   o.private_part  goto 425


state 305
   generic_instantiation :  PACKAGE IDENTIFIER IS NEW!GENERIC_PACKAGE_name o.generic_actual_part ; 

   GENERIC_PACKAGE_name  shift 427
   .  error



state 306
   package_body :  PACKAGE BODY PACKAGE_name IS!declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 428
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 307
   generic_instantiation :  PROCEDURE IDENTIFIER IS NEW!GENERIC_PROCEDURE_name o.generic_actual_part ; 

   GENERIC_PROCEDURE_name  shift 429
   .  error



state 308
   formal_part :  ( parameter_specification!r.parameter_specification ) 
   r.parameter_specification : !   (reduce 287)

   ;  shift 431
   .  reduce 287

   r.parameter_specification  goto 430


state 309
   parameter_specification :  identifier_list!: mode type_mark o.expression 

   :  shift 432
   .  error



state 310
   subprogram_specification :  FUNCTION designator formal_part RETURN!type_mark 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   type_mark  goto 433


state 311
   subprogram_specification :  FUNCTION designator RETURN type_mark!   (reduce 281)

   .  reduce 281



state 312
   generic_instantiation :  FUNCTION designator IS NEW!GENERIC_FUNCTION_name o.generic_actual_part ; 

   GENERIC_FUNCTION_name  shift 434
   .  error



state 313
   subunit :  SEPARATE ( PARENT_UNIT_name )!proper_body 

   FUNCTION  shift 96
   PACKAGE  shift 437
   PROCEDURE  shift 95
   TASK  shift 438
   .  error

   proper_body  goto 435
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 436


state 314
   package_specification :  PACKAGE IDENTIFIER IS!declarative_part o.private_part END PACKAGE_name 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 304
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 315
   generic_parameter_declaration :  identifier_list : mode!type_mark o.expression ; 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   type_mark  goto 439


state 316
   mode :  IN!OUT 
   mode :  IN!   (reduce 290)

   OUT  shift 440
   .  reduce 290



state 317
   mode :  OUT!   (reduce 291)

   .  reduce 291



state 318
   private_type_declaration :  TYPE IDENTIFIER o.discriminant_part!IS o.LIMITED PRIVATE ; 

   IS  shift 441
   .  error



state 319
   generic_parameter_declaration :  TYPE IDENTIFIER IS!generic_type_definition ; 

   ACCESS  shift 451
   ARRAY  shift 452
   DELTA  shift 446
   DIGITS  shift 445
   RANGE  shift 444
   (  shift 443
   .  error

   constrained_array_definition  goto 450
   array_type_definition  goto 447
   access_type_definition  goto 448
   unconstrained_array_definition  goto 449
   generic_type_definition  goto 442


state 320
   o.discriminant_part :  discriminant_part!   (reduce 317)

   .  reduce 317



state 321
   discriminant_part :  (!discriminant_specification r.discriminant_specification ) 

   IDENTIFIER  shift 104
   .  error

   identifier_list  goto 454
   discriminant_specification  goto 453


state 322
   generic_parameter_declaration :  WITH subprogram_specification IS!name ; 
   generic_parameter_declaration :  WITH subprogram_specification IS!BOX ; 

   BOX  shift 456
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   OPERATOR_STRING_LITERAL  shift 58
   FUNCTION_name  shift 63
   .  error

   name  goto 455
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 299


state 323
   generic_parameter_declaration :  WITH subprogram_specification ;!   (reduce 414)

   .  reduce 414



state 324
   r.identifier :  , IDENTIFIER!r.identifier 
   r.identifier : !   (reduce 36)

   ,  shift 221
   .  reduce 36

   r.identifier  goto 457


state 325
   pragma :  PRAGMA IDENTIFIER ( argument_association r.argument_association ) ;!   (reduce 2)

   .  reduce 2



state 326
   r.argument_association :  , argument_association r.argument_association!   (reduce 3)

   .  reduce 3



state 327
   expression :  relation AND THEN relation!   (reduce 168)

   .  reduce 168



state 328
   expression :  relation OR ELSE relation!   (reduce 170)

   .  reduce 170



state 329
   indexed_component :  prefix ( expression r.expression!) 

   )  shift 458
   .  error



state 330
   r.expression :  ,!expression r.expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 459
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 331
   slice :  prefix ( discrete_range )!   (reduce 151)

   .  reduce 151



state 332
   attribute_designator :  simple_name (!UNIVERSAL_STATIC_expression ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 461
   UNIVERSAL_STATIC_expression  goto 460
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 333
   relation :  simple_expression NOT IN range!   (reduce 179)

   .  reduce 179



334: shift/reduce conflict (shift 164, reduce 180) on PRIME
334: shift/reduce conflict (shift 163, reduce 180) on (
state 334
   relation :  simple_expression NOT IN type_mark!   (reduce 180)
   type_conversion :  type_mark!( expression ) 
   qualified_expression :  type_mark!PRIME ( expression ) 
   qualified_expression :  type_mark!PRIME aggregate 

   PRIME  shift 164
   (  shift 163
   .  reduce 180



state 335
   r.parameter_association :  parameter_association r.parameter_association!   (reduce 301)

   .  reduce 301



state 336
   parameter_association :  formal_parameter ASSOC actual_parameter!   (reduce 303)

   .  reduce 303



state 337
   actual_parameter :  type_mark ( VARIABLE_name!) 

   )  shift 462
   .  error



state 338
   aggregate :  ( component_association r.component_association )!   (reduce 161)

   .  reduce 161



state 339
   r.component_association :  , component_association!r.component_association 
   r.component_association : !   (reduce 163)

   ,  shift 266
   .  reduce 163

   r.component_association  goto 463


state 340
   component_association :  expression!   (reduce 165)

   .  reduce 165



state 341
   component_association :  choice r.choice ASSOC!expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 464
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 342
   r.choice :  | choice!r.choice 
   r.choice : !   (reduce 118)

   |  shift 269
   .  reduce 118

   r.choice  goto 465


state 343
   range :  simple_expression!DOTDOT simple_expression 
   choice :  simple_expression!   (reduce 119)

   DOTDOT  shift 270
   .  reduce 119



state 344
   range :  simple_expression DOTDOT simple_expression!   (reduce 62)

   .  reduce 62



state 345
   index_constraint :  ( discrete_range!r.discrete_range ) 
   r.discrete_range : !   (reduce 89)

   ,  shift 467
   .  reduce 89

   r.discrete_range  goto 466


state 346
   discriminant_constraint :  ( discriminant_association!r.discriminant_association ) 
   r.discriminant_association : !   (reduce 107)

   ,  shift 469
   .  reduce 107

   r.discriminant_association  goto 468


state 347
   discriminant_association :  o.DISCRIMINANT_name!expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 470
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 348
   o.DISCRIMINANT_name :  DISCRIMINANT_name!r.DISCRIMINANT_name 
   r.DISCRIMINANT_name : !   (reduce 112)

   |  shift 472
   .  reduce 112

   r.DISCRIMINANT_name  goto 471


state 349
   range_constraint :  RANGE range!   (reduce 60)

   .  reduce 60



state 350
   floating_point_constraint :  floating_accuracy_definition range_constraint!   (reduce 73)

   .  reduce 73



state 351
   fixed_point_constraint :  fixed_accuracy_definition range_constraint!   (reduce 76)

   .  reduce 76



state 352
   floating_accuracy_definition :  DIGITS STATIC_simple_expression!   (reduce 75)

   .  reduce 75



state 353
   STATIC_simple_expression :  simple_expression!   (reduce 210)

   .  reduce 210



state 354
   fixed_accuracy_definition :  DELTA STATIC_simple_expression!   (reduce 78)

   .  reduce 78



state 355
   type_conversion :  type_mark ( expression )!   (reduce 213)

   .  reduce 213



356: shift/reduce conflict (shift 473, reduce 165) on )
state 356
   component_association :  expression!   (reduce 165)
   qualified_expression :  type_mark PRIME ( expression!) 

   )  shift 473
   .  reduce 165



state 357
   subprogram_body :  subprogram_specification IS declarative_part BEGIN sequence_of_statements!o.EXCEPTION END o.designator ; 

   EXCEPTION  shift 475
   .  error

   o.EXCEPTION  goto 474


state 358
   sequence_of_statements :  statement!r.statement 
   r.statement : !   (reduce 220)
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   BEGIN  reduce 266
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 220

   pragma  goto 364
   type_mark  goto 391
   statement  goto 477
   r.statement  goto 476
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 359
   statement :  label!simple_statement 
   statement :  label!compound_statement 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   simple_statement  goto 478
   compound_statement  goto 479
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 360
   statement :  simple_statement!   (reduce 223)

   .  reduce 223



state 361
   statement :  compound_statement!   (reduce 224)

   .  reduce 224



state 362
   label :  <!< LABEL_name > > 

   <  shift 480
   .  error



state 363
   simple_statement :  null_statement!   (reduce 225)

   .  reduce 225



state 364
   simple_statement :  pragma!   (reduce 226)

   .  reduce 226



state 365
   simple_statement :  assignment_statement!   (reduce 227)

   .  reduce 227



state 366
   simple_statement :  procedure_call_statement!   (reduce 228)

   .  reduce 228



state 367
   simple_statement :  exit_statement!   (reduce 229)

   .  reduce 229



state 368
   simple_statement :  return_statement!   (reduce 230)

   .  reduce 230



state 369
   simple_statement :  goto_statement!   (reduce 231)

   .  reduce 231



state 370
   simple_statement :  entry_call_statement!   (reduce 232)

   .  reduce 232



state 371
   simple_statement :  delay_statement!   (reduce 233)

   .  reduce 233



state 372
   simple_statement :  abort_statement!   (reduce 234)

   .  reduce 234



state 373
   simple_statement :  raise_statement!   (reduce 235)

   .  reduce 235



state 374
   simple_statement :  code_statement!   (reduce 236)

   .  reduce 236



state 375
   compound_statement :  if_statement!   (reduce 237)

   .  reduce 237



state 376
   compound_statement :  case_statement!   (reduce 238)

   .  reduce 238



state 377
   compound_statement :  loop_statement!   (reduce 239)

   .  reduce 239



state 378
   compound_statement :  block_statement!   (reduce 240)

   .  reduce 240



state 379
   compound_statement :  accept_statement!   (reduce 241)

   .  reduce 241



state 380
   compound_statement :  select_statement!   (reduce 242)

   .  reduce 242



state 381
   null_statement :  NULL!; 

   ;  shift 481
   .  error



state 382
   assignment_statement :  VARIABLE_name!BECOMES expression ; 

   BECOMES  shift 482
   .  error



state 383
   procedure_call_statement :  PROCEDURE_name!actual_parameter_part ; 
   procedure_call_statement :  PROCEDURE_name!; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   PARAMETER_name  shift 133
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 135
   ;  shift 484
   (  shift 75
   .  error

   name  goto 137
   expression  goto 134
   type_mark  goto 136
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   actual_parameter_part  goto 483
   parameter_association  goto 130
   formal_parameter  goto 131
   actual_parameter  goto 132


state 384
   exit_statement :  EXIT!LOOP_name WHEN condition ; 
   exit_statement :  EXIT!LOOP_name ; 
   exit_statement :  EXIT!WHEN condition ; 
   exit_statement :  EXIT!; 

   WHEN  shift 486
   LOOP_name  shift 485
   ;  shift 487
   .  error



state 385
   return_statement :  RETURN!expression ; 
   return_statement :  RETURN!; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   ;  shift 489
   (  shift 75
   .  error

   name  goto 137
   expression  goto 488
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 386
   goto_statement :  GOTO!LABEL_name ; 

   LABEL_name  shift 490
   .  error



state 387
   entry_call_statement :  ENTRY_name!actual_parameter_part ; 
   entry_call_statement :  ENTRY_name!; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   PARAMETER_name  shift 133
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 135
   ;  shift 492
   (  shift 75
   .  error

   name  goto 137
   expression  goto 134
   type_mark  goto 136
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   actual_parameter_part  goto 491
   parameter_association  goto 130
   formal_parameter  goto 131
   actual_parameter  goto 132


state 388
   delay_statement :  DELAY!simple_expression ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 493
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 389
   abort_statement :  ABORT!TASK_name r.TASK_name ; 

   TASK_name  shift 494
   .  error



state 390
   raise_statement :  RAISE!EXCEPTION_name ; 
   raise_statement :  RAISE!; 

   EXCEPTION_name  shift 495
   ;  shift 496
   .  error



state 391
   code_statement :  type_mark!PRIME record_aggregate ; 

   PRIME  shift 497
   .  error



state 392
   if_statement :  IF!condition THEN sequence_of_statements r.elsif.condition o.else END IF ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 500
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   BOOLEAN_expression  goto 499
   condition  goto 498


state 393
   case_statement :  CASE!expression IS case_statement_alternative r.case_statement_alternative END CASE ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 501
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 394
   loop_statement :  LOOP_name!: iteration_scheme LOOP sequence_of_statements END LOOP LOOP_name ; 

   :  shift 502
   .  error



state 395
   loop_statement :  iteration_scheme!LOOP sequence_of_statements END LOOP ; 

   LOOP  shift 503
   .  error



state 396
   block_statement :  BLOCK_name!: o.DECLARE BEGIN sequence_of_statements o.EXCEPTION END BLOCK_name ; 

   :  shift 504
   .  error



state 397
   block_statement :  o.DECLARE!BEGIN sequence_of_statements o.EXCEPTION END ; 

   BEGIN  shift 505
   .  error



state 398
   accept_statement :  ACCEPT!ENTRY_name ( entry_index ) o.formal_part o.DO ; 
   accept_statement :  ACCEPT!ENTRY_name o.formal_part o.DO ; 

   ENTRY_name  shift 506
   .  error



state 399
   select_statement :  selective_wait!   (reduce 346)

   .  reduce 346



state 400
   select_statement :  conditional_entry_call!   (reduce 347)

   .  reduce 347



state 401
   select_statement :  timed_entry_call!   (reduce 348)

   .  reduce 348



state 402
   iteration_scheme :  WHILE!condition 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 500
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   BOOLEAN_expression  goto 499
   condition  goto 507


state 403
   iteration_scheme :  FOR!loop_parameter_specification 

   IDENTIFIER  shift 509
   .  error

   loop_parameter_specification  goto 508


state 404
   o.DECLARE :  DECLARE!declarative_part 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 510
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 405
   selective_wait :  SELECT!select_alternative o.OR.select_alternative o.ELSE.sequence_of_statements END SELECT ; 
   conditional_entry_call :  SELECT!entry_call_statement o.sequence_of_statements ELSE sequence_of_statements END SELECT ; 
   timed_entry_call :  SELECT!entry_call_statement o.sequence_of_statements OR delay_alternative END SELECT ; 

   ACCEPT  shift 398
   DELAY  shift 388
   TERMINATE  shift 520
   WHEN  shift 513
   ENTRY_name  shift 387
   .  error

   entry_call_statement  goto 512
   delay_statement  goto 519
   accept_statement  goto 518
   select_alternative  goto 511
   selective_wait_alternative  goto 514
   accept_alternative  goto 515
   delay_alternative  goto 516
   terminate_alternative  goto 517


state 406
   object_declaration :  identifier_list : object_specification!; 

   ;  shift 521
   .  error



state 407
   object_specification :  CONSTANT!subtype_indication o.expression 
   object_specification :  CONSTANT!constrained_array_definition o.expression 
   number_declaration :  identifier_list : CONSTANT!BECOMES UNIVERSAL_STATIC_expression ; 
   deferred_constant_declaration :  identifier_list : CONSTANT!type_mark ; 

   ARRAY  shift 412
   BECOMES  shift 524
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   subtype_indication  goto 522
   constrained_array_definition  goto 523
   type_mark  goto 525


state 408
   object_specification :  EXCEPTION!RENAMES EXCEPTION_name 
   exception_declaration :  identifier_list : EXCEPTION!; 

   RENAMES  shift 526
   ;  shift 527
   .  error



state 409
   object_specification :  subtype_indication!o.expression 
   object_specification :  subtype_indication!RENAMES OBJECT_name 
   o.expression : !   (reduce 26)

   RENAMES  shift 529
   BECOMES  shift 530
   .  reduce 26

   o.expression  goto 528


state 410
   object_specification :  constrained_array_definition!o.expression 
   o.expression : !   (reduce 26)

   BECOMES  shift 530
   .  reduce 26

   o.expression  goto 531


state 411
   subtype_indication :  type_mark!constraint 
   subtype_indication :  type_mark!   (reduce 51)

   DELTA  shift 282
   DIGITS  shift 281
   RANGE  shift 278
   (  shift 283
   .  reduce 51

   constraint  goto 271
   range_constraint  goto 273
   floating_point_constraint  goto 274
   fixed_point_constraint  goto 275
   index_constraint  goto 276
   discriminant_constraint  goto 277
   floating_accuracy_definition  goto 279
   fixed_accuracy_definition  goto 280


state 412
   constrained_array_definition :  ARRAY!index_constraint OF component_subtype_indication 

   (  shift 533
   .  error

   index_constraint  goto 532


state 413
   object_declaration :  PACKAGE IDENTIFIER RENAMES!SUBPROGRAM_name ; 
   object_declaration :  PACKAGE IDENTIFIER RENAMES!ENTRY_name ; 

   ENTRY_name  shift 535
   SUBPROGRAM_name  shift 534
   .  error



state 414
   package_body :  PACKAGE BODY PACKAGE_name!IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 
   body_stub :  PACKAGE BODY PACKAGE_name!IS SEPARATE ; 

   IS  shift 536
   .  error



state 415
   subtype_declaration :  SUBTYPE IDENTIFIER IS!subtype_indication ; 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   subtype_indication  goto 537
   type_mark  goto 411


state 416
   body_stub :  subprogram_specification IS SEPARATE!; 

   ;  shift 538
   .  error



state 417
   length_clause :  FOR attribute USE!simple_expression ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 539
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 418
   enumeration_representation_clause :  FOR TYPE_name USE!aggregate ; 
   record_representation_clause :  FOR TYPE_name USE!RECORD o.alignment_clause o.component_clause END RECORD ; 

   RECORD  shift 541
   (  shift 542
   .  error

   aggregate  goto 540


state 419
   address_clause :  FOR simple_name USE!AT simple_expression ; 

   AT  shift 543
   .  error



state 420
   task_specification :  TASK o.TYPE IDENTIFIER!IS r.entry_declaration r.representation_clause END TASK_name 

   IS  shift 544
   .  error



state 421
   task_body :  TASK BODY TASK_name!IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 
   body_stub :  TASK BODY TASK_name!IS SEPARATE ; 

   IS  shift 545
   .  error



422: shift/reduce conflict (shift 546, reduce 317) on IS
state 422
   full_type_declaration :  TYPE IDENTIFIER discriminant_part!IS type_definition ; 
   incomplete_type_declaration :  TYPE IDENTIFIER discriminant_part!; 
   o.discriminant_part :  discriminant_part!   (reduce 317)

   IS  shift 546
   ;  shift 547
   .  error



state 423
   full_type_declaration :  TYPE IDENTIFIER IS!type_definition ; 

   ACCESS  shift 451
   ARRAY  shift 452
   DELTA  shift 282
   DIGITS  shift 281
   NEW  shift 561
   RANGE  shift 278
   RECORD  shift 560
   (  shift 556
   .  error

   constrained_array_definition  goto 450
   type_definition  goto 548
   enumeration_type_definition  goto 549
   integer_type_definition  goto 550
   real_type_definition  goto 551
   array_type_definition  goto 552
   record_type_definition  goto 553
   access_type_definition  goto 554
   derived_type_definition  goto 555
   range_constraint  goto 557
   floating_point_constraint  goto 558
   fixed_point_constraint  goto 559
   floating_accuracy_definition  goto 279
   fixed_accuracy_definition  goto 280
   unconstrained_array_definition  goto 449


state 424
   incomplete_type_declaration :  TYPE IDENTIFIER ;!   (reduce 125)

   .  reduce 125



state 425
   package_specification :  PACKAGE IDENTIFIER IS declarative_part o.private_part!END PACKAGE_name 

   END  shift 562
   .  error



state 426
   o.private_part :  PRIVATE!declarative_part 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 563
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 427
   generic_instantiation :  PACKAGE IDENTIFIER IS NEW GENERIC_PACKAGE_name!o.generic_actual_part ; 
   o.generic_actual_part : !   (reduce 425)

   (  shift 565
   .  reduce 425

   o.generic_actual_part  goto 564


state 428
   package_body :  PACKAGE BODY PACKAGE_name IS declarative_part!o.BEGIN o.EXCEPTION END PACKAGE_name ; 
   o.BEGIN : !   (reduce 315)

   BEGIN  shift 567
   .  reduce 315

   o.BEGIN  goto 566


state 429
   generic_instantiation :  PROCEDURE IDENTIFIER IS NEW GENERIC_PROCEDURE_name!o.generic_actual_part ; 
   o.generic_actual_part : !   (reduce 425)

   (  shift 565
   .  reduce 425

   o.generic_actual_part  goto 568


state 430
   formal_part :  ( parameter_specification r.parameter_specification!) 

   )  shift 569
   .  error



state 431
   r.parameter_specification :  ;!parameter_specification r.parameter_specification 

   IDENTIFIER  shift 104
   .  error

   identifier_list  goto 309
   parameter_specification  goto 570


state 432
   parameter_specification :  identifier_list :!mode type_mark o.expression 
   mode : !   (reduce 292)

   IN  shift 316
   OUT  shift 317
   .  reduce 292

   mode  goto 571


state 433
   subprogram_specification :  FUNCTION designator formal_part RETURN type_mark!   (reduce 280)

   .  reduce 280



state 434
   generic_instantiation :  FUNCTION designator IS NEW GENERIC_FUNCTION_name!o.generic_actual_part ; 
   o.generic_actual_part : !   (reduce 425)

   (  shift 565
   .  reduce 425

   o.generic_actual_part  goto 572


state 435
   subunit :  SEPARATE ( PARENT_UNIT_name ) proper_body!   (reduce 394)

   .  reduce 394



state 436
   subprogram_body :  subprogram_specification!IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END o.designator ; 

   IS  shift 83
   .  error



state 437
   package_body :  PACKAGE!BODY PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 

   BODY  shift 87
   .  error



state 438
   task_body :  TASK!BODY TASK_name IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 

   BODY  shift 573
   .  error



state 439
   generic_parameter_declaration :  identifier_list : mode type_mark!o.expression ; 
   o.expression : !   (reduce 26)

   BECOMES  shift 530
   .  reduce 26

   o.expression  goto 574


state 440
   mode :  IN OUT!   (reduce 289)

   .  reduce 289



state 441
   private_type_declaration :  TYPE IDENTIFIER o.discriminant_part IS!o.LIMITED PRIVATE ; 
   o.LIMITED : !   (reduce 320)

   LIMITED  shift 576
   .  reduce 320

   o.LIMITED  goto 575


state 442
   generic_parameter_declaration :  TYPE IDENTIFIER IS generic_type_definition!; 

   ;  shift 577
   .  error



state 443
   generic_type_definition :  (!BOX ) 

   BOX  shift 578
   .  error



state 444
   generic_type_definition :  RANGE!BOX 

   BOX  shift 579
   .  error



state 445
   generic_type_definition :  DIGITS!BOX 

   BOX  shift 580
   .  error



state 446
   generic_type_definition :  DELTA!BOX 

   BOX  shift 581
   .  error



state 447
   generic_type_definition :  array_type_definition!   (reduce 419)

   .  reduce 419



state 448
   generic_type_definition :  access_type_definition!   (reduce 420)

   .  reduce 420



state 449
   array_type_definition :  unconstrained_array_definition!   (reduce 79)

   .  reduce 79



state 450
   array_type_definition :  constrained_array_definition!   (reduce 80)

   .  reduce 80



state 451
   access_type_definition :  ACCESS!subtype_indication 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   subtype_indication  goto 582
   type_mark  goto 411


state 452
   unconstrained_array_definition :  ARRAY!( index_subtype_definition r.index_subtype_definition ) OF component_subtype_indication 
   constrained_array_definition :  ARRAY!index_constraint OF component_subtype_indication 

   (  shift 583
   .  error

   index_constraint  goto 532


state 453
   discriminant_part :  ( discriminant_specification!r.discriminant_specification ) 
   r.discriminant_specification : !   (reduce 103)

   ;  shift 585
   .  reduce 103

   r.discriminant_specification  goto 584


state 454
   discriminant_specification :  identifier_list!: type_mark o.expression 

   :  shift 586
   .  error



state 455
   prefix :  name!   (reduce 146)
   generic_parameter_declaration :  WITH subprogram_specification IS name!; 

   ;  shift 587
   .  reduce 146



state 456
   generic_parameter_declaration :  WITH subprogram_specification IS BOX!; 

   ;  shift 588
   .  error



state 457
   r.identifier :  , IDENTIFIER r.identifier!   (reduce 35)

   .  reduce 35



state 458
   indexed_component :  prefix ( expression r.expression )!   (reduce 148)

   .  reduce 148



state 459
   r.expression :  , expression!r.expression 
   r.expression : !   (reduce 150)

   ,  shift 330
   .  reduce 150

   r.expression  goto 589


state 460
   attribute_designator :  simple_name ( UNIVERSAL_STATIC_expression!) 

   )  shift 590
   .  error



state 461
   UNIVERSAL_STATIC_expression :  expression!   (reduce 211)

   .  reduce 211



state 462
   actual_parameter :  type_mark ( VARIABLE_name )!   (reduce 308)

   .  reduce 308



state 463
   r.component_association :  , component_association r.component_association!   (reduce 162)

   .  reduce 162



state 464
   component_association :  choice r.choice ASSOC expression!   (reduce 164)

   .  reduce 164



state 465
   r.choice :  | choice r.choice!   (reduce 117)

   .  reduce 117



state 466
   index_constraint :  ( discrete_range r.discrete_range!) 

   )  shift 591
   .  error



state 467
   r.discrete_range :  ,!discrete_range r.discrete_range 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 252
   discrete_range  goto 592
   discrete_subtype_indication  goto 154
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 468
   discriminant_constraint :  ( discriminant_association r.discriminant_association!) 

   )  shift 593
   .  error



state 469
   r.discriminant_association :  ,!discriminant_association r.discriminant_association 
   o.DISCRIMINANT_name : !   (reduce 110)

   DISCRIMINANT_name  shift 348
   .  reduce 110

   discriminant_association  goto 594
   o.DISCRIMINANT_name  goto 347


state 470
   discriminant_association :  o.DISCRIMINANT_name expression!   (reduce 108)

   .  reduce 108



state 471
   o.DISCRIMINANT_name :  DISCRIMINANT_name r.DISCRIMINANT_name!   (reduce 109)

   .  reduce 109



state 472
   r.DISCRIMINANT_name :  |!DISCRIMINANT_name r.DISCRIMINANT_name 

   DISCRIMINANT_name  shift 595
   .  error



state 473
   qualified_expression :  type_mark PRIME ( expression )!   (reduce 214)

   .  reduce 214



state 474
   subprogram_body :  subprogram_specification IS declarative_part BEGIN sequence_of_statements o.EXCEPTION!END o.designator ; 

   END  shift 596
   .  error



state 475
   o.EXCEPTION :  EXCEPTION!exception_handler r.exception_handler 

   WHEN  shift 598
   .  error

   exception_handler  goto 597


state 476
   sequence_of_statements :  statement r.statement!   (reduce 218)

   .  reduce 218



state 477
   r.statement :  statement!r.statement 
   r.statement : !   (reduce 220)
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   BEGIN  reduce 266
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 220

   pragma  goto 364
   type_mark  goto 391
   statement  goto 477
   r.statement  goto 599
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 478
   statement :  label simple_statement!   (reduce 221)

   .  reduce 221



state 479
   statement :  label compound_statement!   (reduce 222)

   .  reduce 222



state 480
   label :  < <!LABEL_name > > 

   LABEL_name  shift 600
   .  error



state 481
   null_statement :  NULL ;!   (reduce 244)

   .  reduce 244



state 482
   assignment_statement :  VARIABLE_name BECOMES!expression ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 601
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 483
   procedure_call_statement :  PROCEDURE_name actual_parameter_part!; 

   ;  shift 602
   .  error



state 484
   procedure_call_statement :  PROCEDURE_name ;!   (reduce 297)

   .  reduce 297



state 485
   exit_statement :  EXIT LOOP_name!WHEN condition ; 
   exit_statement :  EXIT LOOP_name!; 

   WHEN  shift 603
   ;  shift 604
   .  error



state 486
   exit_statement :  EXIT WHEN!condition ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 500
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   BOOLEAN_expression  goto 499
   condition  goto 605


state 487
   exit_statement :  EXIT ;!   (reduce 273)

   .  reduce 273



state 488
   return_statement :  RETURN expression!; 

   ;  shift 606
   .  error



state 489
   return_statement :  RETURN ;!   (reduce 275)

   .  reduce 275



state 490
   goto_statement :  GOTO LABEL_name!; 

   ;  shift 607
   .  error



state 491
   entry_call_statement :  ENTRY_name actual_parameter_part!; 

   ;  shift 608
   .  error



state 492
   entry_call_statement :  ENTRY_name ;!   (reduce 337)

   .  reduce 337



state 493
   delay_statement :  DELAY simple_expression!; 

   ;  shift 609
   .  error



state 494
   abort_statement :  ABORT TASK_name!r.TASK_name ; 
   r.TASK_name : !   (reduce 370)

   ,  shift 611
   .  reduce 370

   r.TASK_name  goto 610


state 495
   raise_statement :  RAISE EXCEPTION_name!; 

   ;  shift 612
   .  error



state 496
   raise_statement :  RAISE ;!   (reduce 402)

   .  reduce 402



state 497
   code_statement :  type_mark PRIME!record_aggregate ; 

   (  shift 542
   .  error

   aggregate  goto 614
   record_aggregate  goto 613


state 498
   if_statement :  IF condition!THEN sequence_of_statements r.elsif.condition o.else END IF ; 

   THEN  shift 615
   .  error



state 499
   condition :  BOOLEAN_expression!   (reduce 251)

   .  reduce 251



state 500
   BOOLEAN_expression :  expression!   (reduce 212)

   .  reduce 212



state 501
   case_statement :  CASE expression!IS case_statement_alternative r.case_statement_alternative END CASE ; 

   IS  shift 616
   .  error



state 502
   loop_statement :  LOOP_name :!iteration_scheme LOOP sequence_of_statements END LOOP LOOP_name ; 
   iteration_scheme : !   (reduce 260)

   FOR  shift 403
   WHILE  shift 402
   .  reduce 260

   iteration_scheme  goto 617


state 503
   loop_statement :  iteration_scheme LOOP!sequence_of_statements END LOOP ; 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 618
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 504
   block_statement :  BLOCK_name :!o.DECLARE BEGIN sequence_of_statements o.EXCEPTION END BLOCK_name ; 
   o.DECLARE : !   (reduce 266)

   DECLARE  shift 404
   .  reduce 266

   o.DECLARE  goto 619


state 505
   block_statement :  o.DECLARE BEGIN!sequence_of_statements o.EXCEPTION END ; 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 620
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 506
   accept_statement :  ACCEPT ENTRY_name!( entry_index ) o.formal_part o.DO ; 
   accept_statement :  ACCEPT ENTRY_name!o.formal_part o.DO ; 
   o.formal_part : !   (reduce 343)

   (  shift 621
   .  reduce 343

   formal_part  goto 623
   o.formal_part  goto 622


state 507
   iteration_scheme :  WHILE condition!   (reduce 258)

   .  reduce 258



state 508
   iteration_scheme :  FOR loop_parameter_specification!   (reduce 259)

   .  reduce 259



state 509
   loop_parameter_specification :  IDENTIFIER!IN REVERSE discrete_range 
   loop_parameter_specification :  IDENTIFIER!IN discrete_range 

   IN  shift 624
   .  error



state 510
   o.DECLARE :  DECLARE declarative_part!   (reduce 265)

   .  reduce 265



state 511
   selective_wait :  SELECT select_alternative!o.OR.select_alternative o.ELSE.sequence_of_statements END SELECT ; 
   o.OR.select_alternative : !   (reduce 351)

   OR  shift 626
   .  reduce 351

   o.OR.select_alternative  goto 625


state 512
   conditional_entry_call :  SELECT entry_call_statement!o.sequence_of_statements ELSE sequence_of_statements END SELECT ; 
   timed_entry_call :  SELECT entry_call_statement!o.sequence_of_statements OR delay_alternative END SELECT ; 
   o.sequence_of_statements : !   (reduce 366)
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   BEGIN  reduce 266
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 366

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 628
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401
   o.sequence_of_statements  goto 627


state 513
   select_alternative :  WHEN!condition ASSOC selective_wait_alternative 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 500
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   BOOLEAN_expression  goto 499
   condition  goto 629


state 514
   select_alternative :  selective_wait_alternative!   (reduce 355)

   .  reduce 355



state 515
   selective_wait_alternative :  accept_alternative!   (reduce 356)

   .  reduce 356



state 516
   selective_wait_alternative :  delay_alternative!   (reduce 357)

   .  reduce 357



state 517
   selective_wait_alternative :  terminate_alternative!   (reduce 358)

   .  reduce 358



state 518
   accept_alternative :  accept_statement!sequence_of_statements 
   accept_alternative :  accept_statement!   (reduce 360)
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   BEGIN  reduce 266
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 360

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 630
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 519
   delay_alternative :  delay_statement!sequence_of_statements 
   delay_alternative :  delay_statement!   (reduce 362)
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   BEGIN  reduce 266
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 362

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 631
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 520
   terminate_alternative :  TERMINATE!; 

   ;  shift 632
   .  error



state 521
   object_declaration :  identifier_list : object_specification ;!   (reduce 22)

   .  reduce 22



state 522
   object_specification :  CONSTANT subtype_indication!o.expression 
   o.expression : !   (reduce 26)

   BECOMES  shift 530
   .  reduce 26

   o.expression  goto 633


state 523
   object_specification :  CONSTANT constrained_array_definition!o.expression 
   o.expression : !   (reduce 26)

   BECOMES  shift 530
   .  reduce 26

   o.expression  goto 634


state 524
   number_declaration :  identifier_list : CONSTANT BECOMES!UNIVERSAL_STATIC_expression ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 461
   UNIVERSAL_STATIC_expression  goto 635
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


525: shift/reduce conflict (shift 636, reduce 51) on ;
state 525
   subtype_indication :  type_mark!constraint 
   subtype_indication :  type_mark!   (reduce 51)
   deferred_constant_declaration :  identifier_list : CONSTANT type_mark!; 

   DELTA  shift 282
   DIGITS  shift 281
   RANGE  shift 278
   ;  shift 636
   (  shift 283
   .  reduce 51

   constraint  goto 271
   range_constraint  goto 273
   floating_point_constraint  goto 274
   fixed_point_constraint  goto 275
   index_constraint  goto 276
   discriminant_constraint  goto 277
   floating_accuracy_definition  goto 279
   fixed_accuracy_definition  goto 280


state 526
   object_specification :  EXCEPTION RENAMES!EXCEPTION_name 

   EXCEPTION_name  shift 637
   .  error



state 527
   exception_declaration :  identifier_list : EXCEPTION ;!   (reduce 395)

   .  reduce 395



state 528
   object_specification :  subtype_indication o.expression!   (reduce 29)

   .  reduce 29



state 529
   object_specification :  subtype_indication RENAMES!OBJECT_name 

   OBJECT_name  shift 638
   .  error



state 530
   o.expression :  BECOMES!expression 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 639
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 531
   object_specification :  constrained_array_definition o.expression!   (reduce 31)

   .  reduce 31



state 532
   constrained_array_definition :  ARRAY index_constraint!OF component_subtype_indication 

   OF  shift 640
   .  error



state 533
   index_constraint :  (!discrete_range r.discrete_range ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 252
   discrete_range  goto 345
   discrete_subtype_indication  goto 154
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 534
   object_declaration :  PACKAGE IDENTIFIER RENAMES SUBPROGRAM_name!; 

   ;  shift 641
   .  error



state 535
   object_declaration :  PACKAGE IDENTIFIER RENAMES ENTRY_name!; 

   ;  shift 642
   .  error



state 536
   package_body :  PACKAGE BODY PACKAGE_name IS!declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ; 
   body_stub :  PACKAGE BODY PACKAGE_name IS!SEPARATE ; 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SEPARATE  shift 643
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 428
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 537
   subtype_declaration :  SUBTYPE IDENTIFIER IS subtype_indication!; 

   ;  shift 644
   .  error



state 538
   body_stub :  subprogram_specification IS SEPARATE ;!   (reduce 391)

   .  reduce 391



state 539
   length_clause :  FOR attribute USE simple_expression!; 

   ;  shift 645
   .  error



state 540
   enumeration_representation_clause :  FOR TYPE_name USE aggregate!; 

   ;  shift 646
   .  error



state 541
   record_representation_clause :  FOR TYPE_name USE RECORD!o.alignment_clause o.component_clause END RECORD ; 
   o.alignment_clause : !   (reduce 446)

   AT  shift 648
   .  reduce 446

   o.alignment_clause  goto 647


state 542
   aggregate :  (!component_association r.component_association ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   OTHERS  shift 152
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   COMPONENT_name  shift 153
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 340
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 150
   discrete_range  goto 151
   discrete_subtype_indication  goto 154
   choice  goto 149
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   component_association  goto 147
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 543
   address_clause :  FOR simple_name USE AT!simple_expression ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 649
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 544
   task_specification :  TASK o.TYPE IDENTIFIER IS!r.entry_declaration r.representation_clause END TASK_name 
   r.entry_declaration : !   (reduce 330)

   ENTRY  shift 652
   .  reduce 330

   r.entry_declaration  goto 650
   entry_declaration  goto 651


state 545
   task_body :  TASK BODY TASK_name IS!declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 
   body_stub :  TASK BODY TASK_name IS!SEPARATE ; 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SEPARATE  shift 654
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 653
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 546
   full_type_declaration :  TYPE IDENTIFIER discriminant_part IS!type_definition ; 

   ACCESS  shift 451
   ARRAY  shift 452
   DELTA  shift 282
   DIGITS  shift 281
   NEW  shift 561
   RANGE  shift 278
   RECORD  shift 560
   (  shift 556
   .  error

   constrained_array_definition  goto 450
   type_definition  goto 655
   enumeration_type_definition  goto 549
   integer_type_definition  goto 550
   real_type_definition  goto 551
   array_type_definition  goto 552
   record_type_definition  goto 553
   access_type_definition  goto 554
   derived_type_definition  goto 555
   range_constraint  goto 557
   floating_point_constraint  goto 558
   fixed_point_constraint  goto 559
   floating_accuracy_definition  goto 279
   fixed_accuracy_definition  goto 280
   unconstrained_array_definition  goto 449


state 547
   incomplete_type_declaration :  TYPE IDENTIFIER discriminant_part ;!   (reduce 124)

   .  reduce 124



state 548
   full_type_declaration :  TYPE IDENTIFIER IS type_definition!; 

   ;  shift 656
   .  error



state 549
   type_definition :  enumeration_type_definition!   (reduce 42)

   .  reduce 42



state 550
   type_definition :  integer_type_definition!   (reduce 43)

   .  reduce 43



state 551
   type_definition :  real_type_definition!   (reduce 44)

   .  reduce 44



state 552
   type_definition :  array_type_definition!   (reduce 45)

   .  reduce 45



state 553
   type_definition :  record_type_definition!   (reduce 46)

   .  reduce 46



state 554
   type_definition :  access_type_definition!   (reduce 47)

   .  reduce 47



state 555
   type_definition :  derived_type_definition!   (reduce 48)

   .  reduce 48



state 556
   enumeration_type_definition :  (!enumeration_literal_specification r.enumeration_literal_specification ) 

   CHARACTER_LITERAL  shift 660
   IDENTIFIER  shift 659
   .  error

   enumeration_literal_specification  goto 657
   enumeration_literal  goto 658


state 557
   integer_type_definition :  range_constraint!   (reduce 70)

   .  reduce 70



state 558
   real_type_definition :  floating_point_constraint!   (reduce 71)

   .  reduce 71



state 559
   real_type_definition :  fixed_point_constraint!   (reduce 72)

   .  reduce 72



560: shift/reduce conflict (shift 104, reduce 98) on IDENTIFIER
state 560
   record_type_definition :  RECORD!component_list END RECORD 
   r.component_declaration : !   (reduce 98)

   NULL  shift 664
   IDENTIFIER  shift 104
   .  reduce 98

   identifier_list  goto 665
   component_list  goto 661
   component_declaration  goto 662
   r.component_declaration  goto 663


state 561
   derived_type_definition :  NEW!subtype_indication 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   subtype_indication  goto 666
   type_mark  goto 411


state 562
   package_specification :  PACKAGE IDENTIFIER IS declarative_part o.private_part END!PACKAGE_name 

   PACKAGE_name  shift 667
   .  error



state 563
   o.private_part :  PRIVATE declarative_part!   (reduce 311)

   .  reduce 311



state 564
   generic_instantiation :  PACKAGE IDENTIFIER IS NEW GENERIC_PACKAGE_name o.generic_actual_part!; 

   ;  shift 668
   .  error



state 565
   o.generic_actual_part :  (!generic_association r.generic_association ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   ENTRY_name  shift 677
   FUNCTION_name  shift 63
   PARAMETER_name  shift 672
   SUBPROGRAM_name  shift 676
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 675
   (  shift 75
   .  error

   name  goto 137
   expression  goto 674
   type_mark  goto 678
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 673
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   generic_association  goto 669
   generic_formal_parameter  goto 670
   generic_actual_parameter  goto 671


state 566
   package_body :  PACKAGE BODY PACKAGE_name IS declarative_part o.BEGIN!o.EXCEPTION END PACKAGE_name ; 

   EXCEPTION  shift 475
   .  error

   o.EXCEPTION  goto 679


state 567
   o.BEGIN :  BEGIN!sequence_of_statements 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 680
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 568
   generic_instantiation :  PROCEDURE IDENTIFIER IS NEW GENERIC_PROCEDURE_name o.generic_actual_part!; 

   ;  shift 681
   .  error



state 569
   formal_part :  ( parameter_specification r.parameter_specification )!   (reduce 285)

   .  reduce 285



state 570
   r.parameter_specification :  ; parameter_specification!r.parameter_specification 
   r.parameter_specification : !   (reduce 287)

   ;  shift 431
   .  reduce 287

   r.parameter_specification  goto 682


state 571
   parameter_specification :  identifier_list : mode!type_mark o.expression 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   type_mark  goto 683


state 572
   generic_instantiation :  FUNCTION designator IS NEW GENERIC_FUNCTION_name o.generic_actual_part!; 

   ;  shift 684
   .  error



state 573
   task_body :  TASK BODY!TASK_name IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 

   TASK_name  shift 685
   .  error



state 574
   generic_parameter_declaration :  identifier_list : mode type_mark o.expression!; 

   ;  shift 686
   .  error



state 575
   private_type_declaration :  TYPE IDENTIFIER o.discriminant_part IS o.LIMITED!PRIVATE ; 

   PRIVATE  shift 687
   .  error



state 576
   o.LIMITED :  LIMITED!   (reduce 319)

   .  reduce 319



state 577
   generic_parameter_declaration :  TYPE IDENTIFIER IS generic_type_definition ;!   (reduce 410)

   .  reduce 410



state 578
   generic_type_definition :  ( BOX!) 

   )  shift 688
   .  error



state 579
   generic_type_definition :  RANGE BOX!   (reduce 416)

   .  reduce 416



state 580
   generic_type_definition :  DIGITS BOX!   (reduce 417)

   .  reduce 417



state 581
   generic_type_definition :  DELTA BOX!   (reduce 418)

   .  reduce 418



state 582
   access_type_definition :  ACCESS subtype_indication!   (reduce 123)

   .  reduce 123



state 583
   unconstrained_array_definition :  ARRAY (!index_subtype_definition r.index_subtype_definition ) OF component_subtype_indication 
   index_constraint :  (!discrete_range r.discrete_range ) 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 690
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 252
   index_subtype_definition  goto 689
   discrete_range  goto 345
   discrete_subtype_indication  goto 154
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 584
   discriminant_part :  ( discriminant_specification r.discriminant_specification!) 

   )  shift 691
   .  error



state 585
   r.discriminant_specification :  ;!discriminant_specification r.discriminant_specification 

   IDENTIFIER  shift 104
   .  error

   identifier_list  goto 454
   discriminant_specification  goto 692


state 586
   discriminant_specification :  identifier_list :!type_mark o.expression 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   type_mark  goto 693


state 587
   generic_parameter_declaration :  WITH subprogram_specification IS name ;!   (reduce 412)

   .  reduce 412



state 588
   generic_parameter_declaration :  WITH subprogram_specification IS BOX ;!   (reduce 413)

   .  reduce 413



state 589
   r.expression :  , expression r.expression!   (reduce 149)

   .  reduce 149



state 590
   attribute_designator :  simple_name ( UNIVERSAL_STATIC_expression )!   (reduce 158)

   .  reduce 158



state 591
   index_constraint :  ( discrete_range r.discrete_range )!   (reduce 87)

   .  reduce 87



state 592
   r.discrete_range :  , discrete_range!r.discrete_range 
   r.discrete_range : !   (reduce 89)

   ,  shift 467
   .  reduce 89

   r.discrete_range  goto 694


state 593
   discriminant_constraint :  ( discriminant_association r.discriminant_association )!   (reduce 105)

   .  reduce 105



state 594
   r.discriminant_association :  , discriminant_association!r.discriminant_association 
   r.discriminant_association : !   (reduce 107)

   ,  shift 469
   .  reduce 107

   r.discriminant_association  goto 695


state 595
   r.DISCRIMINANT_name :  | DISCRIMINANT_name!r.DISCRIMINANT_name 
   r.DISCRIMINANT_name : !   (reduce 112)

   |  shift 472
   .  reduce 112

   r.DISCRIMINANT_name  goto 696


state 596
   subprogram_body :  subprogram_specification IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END!o.designator ; 
   o.designator : !   (reduce 295)

   IDENTIFIER  shift 90
   OPERATOR_STRING_LITERAL  shift 58
   .  reduce 295

   operator_symbol  goto 91
   designator  goto 698
   o.designator  goto 697


state 597
   o.EXCEPTION :  EXCEPTION exception_handler!r.exception_handler 
   r.exception_handler : !   (reduce 269)

   WHEN  shift 598
   .  reduce 269

   exception_handler  goto 700
   r.exception_handler  goto 699


state 598
   exception_handler :  WHEN!exception_choice r.exception_choice ASSOC sequence_of_statements 

   OTHERS  shift 703
   EXCEPTION_name  shift 702
   .  error

   exception_choice  goto 701


state 599
   r.statement :  statement r.statement!   (reduce 219)

   .  reduce 219



state 600
   label :  < < LABEL_name!> > 

   >  shift 704
   .  error



state 601
   assignment_statement :  VARIABLE_name BECOMES expression!; 

   ;  shift 705
   .  error



state 602
   procedure_call_statement :  PROCEDURE_name actual_parameter_part ;!   (reduce 296)

   .  reduce 296



state 603
   exit_statement :  EXIT LOOP_name WHEN!condition ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 500
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   BOOLEAN_expression  goto 499
   condition  goto 706


state 604
   exit_statement :  EXIT LOOP_name ;!   (reduce 271)

   .  reduce 271



state 605
   exit_statement :  EXIT WHEN condition!; 

   ;  shift 707
   .  error



state 606
   return_statement :  RETURN expression ;!   (reduce 274)

   .  reduce 274



state 607
   goto_statement :  GOTO LABEL_name ;!   (reduce 276)

   .  reduce 276



state 608
   entry_call_statement :  ENTRY_name actual_parameter_part ;!   (reduce 336)

   .  reduce 336



state 609
   delay_statement :  DELAY simple_expression ;!   (reduce 345)

   .  reduce 345



state 610
   abort_statement :  ABORT TASK_name r.TASK_name!; 

   ;  shift 708
   .  error



state 611
   r.TASK_name :  ,!TASK_name r.TASK_name 

   TASK_name  shift 709
   .  error



state 612
   raise_statement :  RAISE EXCEPTION_name ;!   (reduce 401)

   .  reduce 401



state 613
   code_statement :  type_mark PRIME record_aggregate!; 

   ;  shift 710
   .  error



state 614
   record_aggregate :  aggregate!   (reduce 166)

   .  reduce 166



state 615
   if_statement :  IF condition THEN!sequence_of_statements r.elsif.condition o.else END IF ; 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 711
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 616
   case_statement :  CASE expression IS!case_statement_alternative r.case_statement_alternative END CASE ; 

   WHEN  shift 713
   .  error

   case_statement_alternative  goto 712


state 617
   loop_statement :  LOOP_name : iteration_scheme!LOOP sequence_of_statements END LOOP LOOP_name ; 

   LOOP  shift 714
   .  error



state 618
   loop_statement :  iteration_scheme LOOP sequence_of_statements!END LOOP ; 

   END  shift 715
   .  error



state 619
   block_statement :  BLOCK_name : o.DECLARE!BEGIN sequence_of_statements o.EXCEPTION END BLOCK_name ; 

   BEGIN  shift 716
   .  error



state 620
   block_statement :  o.DECLARE BEGIN sequence_of_statements!o.EXCEPTION END ; 

   EXCEPTION  shift 475
   .  error

   o.EXCEPTION  goto 717


state 621
   formal_part :  (!parameter_specification r.parameter_specification ) 
   accept_statement :  ACCEPT ENTRY_name (!entry_index ) o.formal_part o.DO ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 720
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 719
   identifier_list  goto 309
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   parameter_specification  goto 308
   entry_index  goto 718


state 622
   accept_statement :  ACCEPT ENTRY_name o.formal_part!o.DO ; 
   o.DO : !   (reduce 341)

   DO  shift 722
   .  reduce 341

   o.DO  goto 721


state 623
   o.formal_part :  formal_part!   (reduce 342)

   .  reduce 342



state 624
   loop_parameter_specification :  IDENTIFIER IN!REVERSE discrete_range 
   loop_parameter_specification :  IDENTIFIER IN!discrete_range 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   REVERSE  shift 723
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 252
   discrete_range  goto 724
   discrete_subtype_indication  goto 154
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 625
   selective_wait :  SELECT select_alternative o.OR.select_alternative!o.ELSE.sequence_of_statements END SELECT ; 
   o.ELSE.sequence_of_statements : !   (reduce 353)

   ELSE  shift 726
   .  reduce 353

   o.ELSE.sequence_of_statements  goto 725


state 626
   o.OR.select_alternative :  OR!select_alternative 

   ACCEPT  shift 398
   DELAY  shift 388
   TERMINATE  shift 520
   WHEN  shift 513
   .  error

   delay_statement  goto 519
   accept_statement  goto 518
   select_alternative  goto 727
   selective_wait_alternative  goto 514
   accept_alternative  goto 515
   delay_alternative  goto 516
   terminate_alternative  goto 517


state 627
   conditional_entry_call :  SELECT entry_call_statement o.sequence_of_statements!ELSE sequence_of_statements END SELECT ; 
   timed_entry_call :  SELECT entry_call_statement o.sequence_of_statements!OR delay_alternative END SELECT ; 

   ELSE  shift 728
   OR  shift 729
   .  error



state 628
   o.sequence_of_statements :  sequence_of_statements!   (reduce 365)

   .  reduce 365



state 629
   select_alternative :  WHEN condition!ASSOC selective_wait_alternative 

   ASSOC  shift 730
   .  error



state 630
   accept_alternative :  accept_statement sequence_of_statements!   (reduce 359)

   .  reduce 359



state 631
   delay_alternative :  delay_statement sequence_of_statements!   (reduce 361)

   .  reduce 361



state 632
   terminate_alternative :  TERMINATE ;!   (reduce 363)

   .  reduce 363



state 633
   object_specification :  CONSTANT subtype_indication o.expression!   (reduce 27)

   .  reduce 27



state 634
   object_specification :  CONSTANT constrained_array_definition o.expression!   (reduce 28)

   .  reduce 28



state 635
   number_declaration :  identifier_list : CONSTANT BECOMES UNIVERSAL_STATIC_expression!; 

   ;  shift 731
   .  error



state 636
   deferred_constant_declaration :  identifier_list : CONSTANT type_mark ;!   (reduce 321)

   .  reduce 321



state 637
   object_specification :  EXCEPTION RENAMES EXCEPTION_name!   (reduce 32)

   .  reduce 32



state 638
   object_specification :  subtype_indication RENAMES OBJECT_name!   (reduce 30)

   .  reduce 30



state 639
   o.expression :  BECOMES expression!   (reduce 25)

   .  reduce 25



state 640
   constrained_array_definition :  ARRAY index_constraint OF!component_subtype_indication 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   subtype_indication  goto 733
   type_mark  goto 411
   component_subtype_indication  goto 732


state 641
   object_declaration :  PACKAGE IDENTIFIER RENAMES SUBPROGRAM_name ;!   (reduce 23)

   .  reduce 23



state 642
   object_declaration :  PACKAGE IDENTIFIER RENAMES ENTRY_name ;!   (reduce 24)

   .  reduce 24



state 643
   body_stub :  PACKAGE BODY PACKAGE_name IS SEPARATE!; 

   ;  shift 734
   .  error



state 644
   subtype_declaration :  SUBTYPE IDENTIFIER IS subtype_indication ;!   (reduce 49)

   .  reduce 49



state 645
   length_clause :  FOR attribute USE simple_expression ;!   (reduce 442)

   .  reduce 442



state 646
   enumeration_representation_clause :  FOR TYPE_name USE aggregate ;!   (reduce 443)

   .  reduce 443



state 647
   record_representation_clause :  FOR TYPE_name USE RECORD o.alignment_clause!o.component_clause END RECORD ; 
   o.component_clause : !   (reduce 448)

   COMPONENT_name  shift 736
   .  reduce 448

   o.component_clause  goto 735


state 648
   o.alignment_clause :  AT!MOD STATIC_simple_expression ; 

   MOD  shift 737
   .  error



state 649
   address_clause :  FOR simple_name USE AT simple_expression!; 

   ;  shift 738
   .  error



state 650
   task_specification :  TASK o.TYPE IDENTIFIER IS r.entry_declaration!r.representation_clause END TASK_name 
   r.representation_clause : !   (reduce 332)

   FOR  shift 198
   .  reduce 332

   representation_clause  goto 740
   r.representation_clause  goto 739
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 651
   r.entry_declaration :  entry_declaration!r.entry_declaration 
   r.entry_declaration : !   (reduce 330)

   ENTRY  shift 652
   .  reduce 330

   r.entry_declaration  goto 741
   entry_declaration  goto 651


state 652
   entry_declaration :  ENTRY!IDENTIFIER ( discrete_range ) o.formal_part ; 
   entry_declaration :  ENTRY!IDENTIFIER o.formal_part ; 

   IDENTIFIER  shift 742
   .  error



state 653
   task_body :  TASK BODY TASK_name IS declarative_part!BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 

   BEGIN  shift 743
   .  error



state 654
   body_stub :  TASK BODY TASK_name IS SEPARATE!; 

   ;  shift 744
   .  error



state 655
   full_type_declaration :  TYPE IDENTIFIER discriminant_part IS type_definition!; 

   ;  shift 745
   .  error



state 656
   full_type_declaration :  TYPE IDENTIFIER IS type_definition ;!   (reduce 41)

   .  reduce 41



state 657
   enumeration_type_definition :  ( enumeration_literal_specification!r.enumeration_literal_specification ) 
   r.enumeration_literal_specification : !   (reduce 66)

   ,  shift 747
   .  reduce 66

   r.enumeration_literal_specification  goto 746


state 658
   enumeration_literal_specification :  enumeration_literal!   (reduce 67)

   .  reduce 67



state 659
   enumeration_literal :  IDENTIFIER!   (reduce 68)

   .  reduce 68



state 660
   enumeration_literal :  CHARACTER_LITERAL!   (reduce 69)

   .  reduce 69



state 661
   record_type_definition :  RECORD component_list!END RECORD 

   END  shift 748
   .  error



state 662
   component_list :  component_declaration!r.component_declaration 
   r.component_declaration : !   (reduce 98)

   .  reduce 98

   r.component_declaration  goto 749


state 663
   component_list :  r.component_declaration!variant_part 
   r.component_declaration :  r.component_declaration!component_declaration 

   CASE  shift 752
   IDENTIFIER  shift 104
   .  error

   identifier_list  goto 665
   component_declaration  goto 751
   variant_part  goto 750


state 664
   component_list :  NULL!; 

   ;  shift 753
   .  error



state 665
   component_declaration :  identifier_list!: component_subtype_definition o.expression ; 

   :  shift 754
   .  error



state 666
   derived_type_definition :  NEW subtype_indication!   (reduce 59)

   .  reduce 59



state 667
   package_specification :  PACKAGE IDENTIFIER IS declarative_part o.private_part END PACKAGE_name!   (reduce 310)

   .  reduce 310



state 668
   generic_instantiation :  PACKAGE IDENTIFIER IS NEW GENERIC_PACKAGE_name o.generic_actual_part ;!   (reduce 421)

   .  reduce 421



state 669
   o.generic_actual_part :  ( generic_association!r.generic_association ) 
   r.generic_association : !   (reduce 427)

   ,  shift 756
   .  reduce 427

   r.generic_association  goto 755


state 670
   generic_association :  generic_formal_parameter!ASSOC generic_actual_parameter 

   ASSOC  shift 757
   .  error



state 671
   generic_association :  generic_actual_parameter!   (reduce 429)

   .  reduce 429



state 672
   generic_formal_parameter :  PARAMETER_name!   (reduce 430)

   .  reduce 430



state 673
   name :  operator_symbol!   (reduce 140)
   generic_formal_parameter :  operator_symbol!   (reduce 431)

   ASSOC  reduce 431
   .  reduce 140



state 674
   generic_actual_parameter :  expression!   (reduce 432)

   .  reduce 432



state 675
   generic_actual_parameter :  VARIABLE_name!   (reduce 433)

   .  reduce 433



state 676
   generic_actual_parameter :  SUBPROGRAM_name!   (reduce 434)

   .  reduce 434



state 677
   generic_actual_parameter :  ENTRY_name!   (reduce 435)

   .  reduce 435



state 678
   type_conversion :  type_mark!( expression ) 
   qualified_expression :  type_mark!PRIME ( expression ) 
   qualified_expression :  type_mark!PRIME aggregate 
   generic_actual_parameter :  type_mark!   (reduce 436)

   PRIME  shift 164
   (  shift 163
   .  reduce 436



state 679
   package_body :  PACKAGE BODY PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION!END PACKAGE_name ; 

   END  shift 758
   .  error



state 680
   o.BEGIN :  BEGIN sequence_of_statements!   (reduce 314)

   .  reduce 314



state 681
   generic_instantiation :  PROCEDURE IDENTIFIER IS NEW GENERIC_PROCEDURE_name o.generic_actual_part ;!   (reduce 422)

   .  reduce 422



state 682
   r.parameter_specification :  ; parameter_specification r.parameter_specification!   (reduce 286)

   .  reduce 286



state 683
   parameter_specification :  identifier_list : mode type_mark!o.expression 
   o.expression : !   (reduce 26)

   BECOMES  shift 530
   .  reduce 26

   o.expression  goto 759


state 684
   generic_instantiation :  FUNCTION designator IS NEW GENERIC_FUNCTION_name o.generic_actual_part ;!   (reduce 423)

   .  reduce 423



state 685
   task_body :  TASK BODY TASK_name!IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 

   IS  shift 760
   .  error



state 686
   generic_parameter_declaration :  identifier_list : mode type_mark o.expression ;!   (reduce 409)

   .  reduce 409



state 687
   private_type_declaration :  TYPE IDENTIFIER o.discriminant_part IS o.LIMITED PRIVATE!; 

   ;  shift 761
   .  error



state 688
   generic_type_definition :  ( BOX )!   (reduce 415)

   .  reduce 415



state 689
   unconstrained_array_definition :  ARRAY ( index_subtype_definition!r.index_subtype_definition ) OF component_subtype_indication 
   r.index_subtype_definition : !   (reduce 83)

   ,  shift 763
   .  reduce 83

   r.index_subtype_definition  goto 762


state 690
   subtype_indication :  type_mark!constraint 
   subtype_indication :  type_mark!   (reduce 51)
   index_subtype_definition :  type_mark!RANGE BOX 
   type_conversion :  type_mark!( expression ) 
   qualified_expression :  type_mark!PRIME ( expression ) 
   qualified_expression :  type_mark!PRIME aggregate 

   DELTA  shift 282
   DIGITS  shift 281
   RANGE  shift 764
   PRIME  shift 164
   (  shift 272
   .  reduce 51

   constraint  goto 271
   range_constraint  goto 273
   floating_point_constraint  goto 274
   fixed_point_constraint  goto 275
   index_constraint  goto 276
   discriminant_constraint  goto 277
   floating_accuracy_definition  goto 279
   fixed_accuracy_definition  goto 280


state 691
   discriminant_part :  ( discriminant_specification r.discriminant_specification )!   (reduce 101)

   .  reduce 101



state 692
   r.discriminant_specification :  ; discriminant_specification!r.discriminant_specification 
   r.discriminant_specification : !   (reduce 103)

   ;  shift 585
   .  reduce 103

   r.discriminant_specification  goto 765


state 693
   discriminant_specification :  identifier_list : type_mark!o.expression 
   o.expression : !   (reduce 26)

   BECOMES  shift 530
   .  reduce 26

   o.expression  goto 766


state 694
   r.discrete_range :  , discrete_range r.discrete_range!   (reduce 88)

   .  reduce 88



state 695
   r.discriminant_association :  , discriminant_association r.discriminant_association!   (reduce 106)

   .  reduce 106



state 696
   r.DISCRIMINANT_name :  | DISCRIMINANT_name r.DISCRIMINANT_name!   (reduce 111)

   .  reduce 111



state 697
   subprogram_body :  subprogram_specification IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END o.designator!; 

   ;  shift 767
   .  error



state 698
   o.designator :  designator!   (reduce 294)

   .  reduce 294



state 699
   o.EXCEPTION :  EXCEPTION exception_handler r.exception_handler!   (reduce 267)

   .  reduce 267



state 700
   r.exception_handler :  exception_handler!r.exception_handler 
   r.exception_handler : !   (reduce 269)

   WHEN  shift 598
   .  reduce 269

   exception_handler  goto 700
   r.exception_handler  goto 768


state 701
   exception_handler :  WHEN exception_choice!r.exception_choice ASSOC sequence_of_statements 
   r.exception_choice : !   (reduce 398)

   |  shift 770
   .  reduce 398

   r.exception_choice  goto 769


state 702
   exception_choice :  EXCEPTION_name!   (reduce 399)

   .  reduce 399



state 703
   exception_choice :  OTHERS!   (reduce 400)

   .  reduce 400



state 704
   label :  < < LABEL_name >!> 

   >  shift 771
   .  error



state 705
   assignment_statement :  VARIABLE_name BECOMES expression ;!   (reduce 245)

   .  reduce 245



state 706
   exit_statement :  EXIT LOOP_name WHEN condition!; 

   ;  shift 772
   .  error



state 707
   exit_statement :  EXIT WHEN condition ;!   (reduce 272)

   .  reduce 272



state 708
   abort_statement :  ABORT TASK_name r.TASK_name ;!   (reduce 368)

   .  reduce 368



state 709
   r.TASK_name :  , TASK_name!r.TASK_name 
   r.TASK_name : !   (reduce 370)

   ,  shift 611
   .  reduce 370

   r.TASK_name  goto 773


state 710
   code_statement :  type_mark PRIME record_aggregate ;!   (reduce 450)

   .  reduce 450



state 711
   if_statement :  IF condition THEN sequence_of_statements!r.elsif.condition o.else END IF ; 
   r.elsif.condition : !   (reduce 248)

   ELSIF  shift 775
   .  reduce 248

   r.elsif.condition  goto 774


state 712
   case_statement :  CASE expression IS case_statement_alternative!r.case_statement_alternative END CASE ; 
   r.case_statement_alternative : !   (reduce 254)

   WHEN  shift 713
   .  reduce 254

   case_statement_alternative  goto 777
   r.case_statement_alternative  goto 776


state 713
   case_statement_alternative :  WHEN!choice r.choice ASSOC sequence_of_statements 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   OTHERS  shift 152
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   COMPONENT_name  shift 153
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 343
   discrete_range  goto 151
   discrete_subtype_indication  goto 154
   choice  goto 778
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 714
   loop_statement :  LOOP_name : iteration_scheme LOOP!sequence_of_statements END LOOP LOOP_name ; 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 779
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 715
   loop_statement :  iteration_scheme LOOP sequence_of_statements END!LOOP ; 

   LOOP  shift 780
   .  error



state 716
   block_statement :  BLOCK_name : o.DECLARE BEGIN!sequence_of_statements o.EXCEPTION END BLOCK_name ; 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 781
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 717
   block_statement :  o.DECLARE BEGIN sequence_of_statements o.EXCEPTION!END ; 

   END  shift 782
   .  error



state 718
   accept_statement :  ACCEPT ENTRY_name ( entry_index!) o.formal_part o.DO ; 

   )  shift 783
   .  error



state 719
   entry_index :  expression!   (reduce 344)

   .  reduce 344



state 720
   identifier_list :  IDENTIFIER!r.identifier 
   simple_name :  IDENTIFIER!   (reduce 145)
   r.identifier : !   (reduce 36)

   ,  shift 221
   :  reduce 36
   .  reduce 145

   r.identifier  goto 220


state 721
   accept_statement :  ACCEPT ENTRY_name o.formal_part o.DO!; 

   ;  shift 784
   .  error



state 722
   o.DO :  DO!sequence_of_statements END ENTRY_name 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 785
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 723
   loop_parameter_specification :  IDENTIFIER IN REVERSE!discrete_range 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 252
   discrete_range  goto 786
   discrete_subtype_indication  goto 154
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 724
   loop_parameter_specification :  IDENTIFIER IN discrete_range!   (reduce 262)

   .  reduce 262



state 725
   selective_wait :  SELECT select_alternative o.OR.select_alternative o.ELSE.sequence_of_statements!END SELECT ; 

   END  shift 787
   .  error



state 726
   o.ELSE.sequence_of_statements :  ELSE!sequence_of_statements 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 788
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 727
   o.OR.select_alternative :  OR select_alternative!   (reduce 350)

   .  reduce 350



state 728
   conditional_entry_call :  SELECT entry_call_statement o.sequence_of_statements ELSE!sequence_of_statements END SELECT ; 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 789
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 729
   timed_entry_call :  SELECT entry_call_statement o.sequence_of_statements OR!delay_alternative END SELECT ; 

   DELAY  shift 388
   .  error

   delay_statement  goto 519
   delay_alternative  goto 790


state 730
   select_alternative :  WHEN condition ASSOC!selective_wait_alternative 

   ACCEPT  shift 398
   DELAY  shift 388
   TERMINATE  shift 520
   .  error

   delay_statement  goto 519
   accept_statement  goto 518
   selective_wait_alternative  goto 791
   accept_alternative  goto 515
   delay_alternative  goto 516
   terminate_alternative  goto 517


state 731
   number_declaration :  identifier_list : CONSTANT BECOMES UNIVERSAL_STATIC_expression ;!   (reduce 33)

   .  reduce 33



state 732
   constrained_array_definition :  ARRAY index_constraint OF component_subtype_indication!   (reduce 84)

   .  reduce 84



state 733
   component_subtype_indication :  subtype_indication!   (reduce 85)

   .  reduce 85



state 734
   body_stub :  PACKAGE BODY PACKAGE_name IS SEPARATE ;!   (reduce 392)

   .  reduce 392



state 735
   record_representation_clause :  FOR TYPE_name USE RECORD o.alignment_clause o.component_clause!END RECORD ; 

   END  shift 792
   .  error



state 736
   o.component_clause :  COMPONENT_name!AT STATIC_simple_expression RANGE STATIC_range ; 

   AT  shift 793
   .  error



state 737
   o.alignment_clause :  AT MOD!STATIC_simple_expression ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 353
   STATIC_simple_expression  goto 794
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 738
   address_clause :  FOR simple_name USE AT simple_expression ;!   (reduce 449)

   .  reduce 449



state 739
   task_specification :  TASK o.TYPE IDENTIFIER IS r.entry_declaration r.representation_clause!END TASK_name 

   END  shift 795
   .  error



state 740
   r.representation_clause :  representation_clause!r.representation_clause 
   r.representation_clause : !   (reduce 332)

   FOR  shift 198
   .  reduce 332

   representation_clause  goto 740
   r.representation_clause  goto 796
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 741
   r.entry_declaration :  entry_declaration r.entry_declaration!   (reduce 329)

   .  reduce 329



state 742
   entry_declaration :  ENTRY IDENTIFIER!( discrete_range ) o.formal_part ; 
   entry_declaration :  ENTRY IDENTIFIER!o.formal_part ; 
   o.formal_part : !   (reduce 343)

   (  shift 797
   .  reduce 343

   formal_part  goto 623
   o.formal_part  goto 798


state 743
   task_body :  TASK BODY TASK_name IS declarative_part BEGIN!sequence_of_statements o.EXCEPTION END TASK_name ; 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 799
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 744
   body_stub :  TASK BODY TASK_name IS SEPARATE ;!   (reduce 393)

   .  reduce 393



state 745
   full_type_declaration :  TYPE IDENTIFIER discriminant_part IS type_definition ;!   (reduce 40)

   .  reduce 40



state 746
   enumeration_type_definition :  ( enumeration_literal_specification r.enumeration_literal_specification!) 

   )  shift 800
   .  error



state 747
   r.enumeration_literal_specification :  ,!enumeration_literal_specification r.enumeration_literal_specification 

   CHARACTER_LITERAL  shift 660
   IDENTIFIER  shift 659
   .  error

   enumeration_literal_specification  goto 801
   enumeration_literal  goto 658


state 748
   record_type_definition :  RECORD component_list END!RECORD 

   RECORD  shift 802
   .  error



state 749
   component_list :  component_declaration r.component_declaration!   (reduce 94)
   r.component_declaration :  r.component_declaration!component_declaration 

   IDENTIFIER  shift 104
   .  reduce 94

   identifier_list  goto 665
   component_declaration  goto 751


state 750
   component_list :  r.component_declaration variant_part!   (reduce 95)

   .  reduce 95



state 751
   r.component_declaration :  r.component_declaration component_declaration!   (reduce 97)

   .  reduce 97



state 752
   variant_part :  CASE!DISCRIMINANT_name IS variant r.variant END CASE ; 

   DISCRIMINANT_name  shift 803
   .  error



state 753
   component_list :  NULL ;!   (reduce 96)

   .  reduce 96



state 754
   component_declaration :  identifier_list :!component_subtype_definition o.expression ; 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   subtype_indication  goto 805
   type_mark  goto 411
   component_subtype_definition  goto 804


state 755
   o.generic_actual_part :  ( generic_association r.generic_association!) 

   )  shift 806
   .  error



state 756
   r.generic_association :  ,!generic_association r.generic_association 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   ENTRY_name  shift 677
   FUNCTION_name  shift 63
   PARAMETER_name  shift 672
   SUBPROGRAM_name  shift 676
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 675
   (  shift 75
   .  error

   name  goto 137
   expression  goto 674
   type_mark  goto 678
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 673
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   generic_association  goto 807
   generic_formal_parameter  goto 670
   generic_actual_parameter  goto 671


state 757
   generic_association :  generic_formal_parameter ASSOC!generic_actual_parameter 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   ENTRY_name  shift 677
   FUNCTION_name  shift 63
   SUBPROGRAM_name  shift 676
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 675
   (  shift 75
   .  error

   name  goto 137
   expression  goto 674
   type_mark  goto 678
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   generic_actual_parameter  goto 808


state 758
   package_body :  PACKAGE BODY PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION END!PACKAGE_name ; 

   PACKAGE_name  shift 809
   .  error



state 759
   parameter_specification :  identifier_list : mode type_mark o.expression!   (reduce 288)

   .  reduce 288



state 760
   task_body :  TASK BODY TASK_name IS!declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ; 
   declarative_part : !   (reduce 127)

   FOR  shift 198
   FUNCTION  shift 36
   GENERIC  shift 40
   PACKAGE  shift 188
   PRAGMA  shift 5
   PROCEDURE  shift 35
   SUBTYPE  shift 192
   TASK  shift 202
   TYPE  shift 203
   USE  shift 11
   IDENTIFIER  shift 104
   .  reduce 127

   pragma  goto 167
   basic_declaration  goto 168
   object_declaration  goto 172
   number_declaration  goto 173
   type_declaration  goto 174
   subtype_declaration  goto 175
   subprogram_declaration  goto 176
   package_declaration  goto 177
   task_declaration  goto 178
   generic_declaration  goto 179
   exception_declaration  goto 180
   generic_instantiation  goto 181
   deferred_constant_declaration  goto 182
   identifier_list  goto 187
   full_type_declaration  goto 189
   incomplete_type_declaration  goto 190
   private_type_declaration  goto 191
   declarative_part  goto 653
   r.declarative_part  goto 166
   representation_clause  goto 169
   use_clause  goto 170
   body  goto 171
   proper_body  goto 185
   body_stub  goto 186
   subprogram_body  goto 199
   package_body  goto 200
   task_body  goto 201
   subprogram_specification  goto 193
   package_specification  goto 32
   task_specification  goto 194
   generic_specification  goto 33
   generic_formal_part  goto 39
   type_representation_clause  goto 183
   address_clause  goto 184
   length_clause  goto 195
   enumeration_representation_clause  goto 196
   record_representation_clause  goto 197


state 761
   private_type_declaration :  TYPE IDENTIFIER o.discriminant_part IS o.LIMITED PRIVATE ;!   (reduce 316)

   .  reduce 316



state 762
   unconstrained_array_definition :  ARRAY ( index_subtype_definition r.index_subtype_definition!) OF component_subtype_indication 

   )  shift 810
   .  error



state 763
   r.index_subtype_definition :  ,!index_subtype_definition r.index_subtype_definition 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   type_mark  goto 812
   index_subtype_definition  goto 811


state 764
   range_constraint :  RANGE!range 
   index_subtype_definition :  type_mark RANGE!BOX 

   ABS  shift 69
   BOX  shift 813
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   range  goto 349
   RANGE_attribute  goto 157
   simple_expression  goto 252
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 765
   r.discriminant_specification :  ; discriminant_specification r.discriminant_specification!   (reduce 102)

   .  reduce 102



state 766
   discriminant_specification :  identifier_list : type_mark o.expression!   (reduce 104)

   .  reduce 104



state 767
   subprogram_body :  subprogram_specification IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END o.designator ;!   (reduce 293)

   .  reduce 293



state 768
   r.exception_handler :  exception_handler r.exception_handler!   (reduce 268)

   .  reduce 268



state 769
   exception_handler :  WHEN exception_choice r.exception_choice!ASSOC sequence_of_statements 

   ASSOC  shift 814
   .  error



state 770
   r.exception_choice :  |!exception_choice r.exception_choice 

   OTHERS  shift 703
   EXCEPTION_name  shift 702
   .  error

   exception_choice  goto 815


state 771
   label :  < < LABEL_name > >!   (reduce 243)

   .  reduce 243



state 772
   exit_statement :  EXIT LOOP_name WHEN condition ;!   (reduce 270)

   .  reduce 270



state 773
   r.TASK_name :  , TASK_name r.TASK_name!   (reduce 369)

   .  reduce 369



state 774
   if_statement :  IF condition THEN sequence_of_statements r.elsif.condition!o.else END IF ; 
   o.else : !   (reduce 250)

   ELSE  shift 817
   .  reduce 250

   o.else  goto 816


state 775
   r.elsif.condition :  ELSIF!condition THEN sequence_of_statements r.elsif.condition 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   expression  goto 500
   type_mark  goto 80
   simple_expression  goto 60
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   relation  goto 56
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   BOOLEAN_expression  goto 499
   condition  goto 818


state 776
   case_statement :  CASE expression IS case_statement_alternative r.case_statement_alternative!END CASE ; 

   END  shift 819
   .  error



state 777
   r.case_statement_alternative :  case_statement_alternative!r.case_statement_alternative 
   r.case_statement_alternative : !   (reduce 254)

   WHEN  shift 713
   .  reduce 254

   case_statement_alternative  goto 777
   r.case_statement_alternative  goto 820


state 778
   case_statement_alternative :  WHEN choice!r.choice ASSOC sequence_of_statements 
   r.choice : !   (reduce 118)

   |  shift 269
   .  reduce 118

   r.choice  goto 821


state 779
   loop_statement :  LOOP_name : iteration_scheme LOOP sequence_of_statements!END LOOP LOOP_name ; 

   END  shift 822
   .  error



state 780
   loop_statement :  iteration_scheme LOOP sequence_of_statements END LOOP!; 

   ;  shift 823
   .  error



state 781
   block_statement :  BLOCK_name : o.DECLARE BEGIN sequence_of_statements!o.EXCEPTION END BLOCK_name ; 

   EXCEPTION  shift 475
   .  error

   o.EXCEPTION  goto 824


state 782
   block_statement :  o.DECLARE BEGIN sequence_of_statements o.EXCEPTION END!; 

   ;  shift 825
   .  error



state 783
   accept_statement :  ACCEPT ENTRY_name ( entry_index )!o.formal_part o.DO ; 
   o.formal_part : !   (reduce 343)

   (  shift 208
   .  reduce 343

   formal_part  goto 623
   o.formal_part  goto 826


state 784
   accept_statement :  ACCEPT ENTRY_name o.formal_part o.DO ;!   (reduce 339)

   .  reduce 339



state 785
   o.DO :  DO sequence_of_statements!END ENTRY_name 

   END  shift 827
   .  error



state 786
   loop_parameter_specification :  IDENTIFIER IN REVERSE discrete_range!   (reduce 261)

   .  reduce 261



state 787
   selective_wait :  SELECT select_alternative o.OR.select_alternative o.ELSE.sequence_of_statements END!SELECT ; 

   SELECT  shift 828
   .  error



state 788
   o.ELSE.sequence_of_statements :  ELSE sequence_of_statements!   (reduce 352)

   .  reduce 352



state 789
   conditional_entry_call :  SELECT entry_call_statement o.sequence_of_statements ELSE sequence_of_statements!END SELECT ; 

   END  shift 829
   .  error



state 790
   timed_entry_call :  SELECT entry_call_statement o.sequence_of_statements OR delay_alternative!END SELECT ; 

   END  shift 830
   .  error



state 791
   select_alternative :  WHEN condition ASSOC selective_wait_alternative!   (reduce 354)

   .  reduce 354



state 792
   record_representation_clause :  FOR TYPE_name USE RECORD o.alignment_clause o.component_clause END!RECORD ; 

   RECORD  shift 831
   .  error



state 793
   o.component_clause :  COMPONENT_name AT!STATIC_simple_expression RANGE STATIC_range ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   simple_expression  goto 353
   STATIC_simple_expression  goto 832
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 55
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 794
   o.alignment_clause :  AT MOD STATIC_simple_expression!; 

   ;  shift 833
   .  error



state 795
   task_specification :  TASK o.TYPE IDENTIFIER IS r.entry_declaration r.representation_clause END!TASK_name 

   TASK_name  shift 834
   .  error



state 796
   r.representation_clause :  representation_clause r.representation_clause!   (reduce 331)

   .  reduce 331



state 797
   formal_part :  (!parameter_specification r.parameter_specification ) 
   entry_declaration :  ENTRY IDENTIFIER (!discrete_range ) o.formal_part ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 720
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   identifier_list  goto 309
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 252
   discrete_range  goto 835
   discrete_subtype_indication  goto 154
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74
   parameter_specification  goto 308


state 798
   entry_declaration :  ENTRY IDENTIFIER o.formal_part!; 

   ;  shift 836
   .  error



state 799
   task_body :  TASK BODY TASK_name IS declarative_part BEGIN sequence_of_statements!o.EXCEPTION END TASK_name ; 

   EXCEPTION  shift 475
   .  error

   o.EXCEPTION  goto 837


state 800
   enumeration_type_definition :  ( enumeration_literal_specification r.enumeration_literal_specification )!   (reduce 64)

   .  reduce 64



state 801
   r.enumeration_literal_specification :  , enumeration_literal_specification!r.enumeration_literal_specification 
   r.enumeration_literal_specification : !   (reduce 66)

   ,  shift 747
   .  reduce 66

   r.enumeration_literal_specification  goto 838


state 802
   record_type_definition :  RECORD component_list END RECORD!   (reduce 93)

   .  reduce 93



state 803
   variant_part :  CASE DISCRIMINANT_name!IS variant r.variant END CASE ; 

   IS  shift 839
   .  error



state 804
   component_declaration :  identifier_list : component_subtype_definition!o.expression ; 
   o.expression : !   (reduce 26)

   BECOMES  shift 530
   .  reduce 26

   o.expression  goto 840


state 805
   component_subtype_definition :  subtype_indication!   (reduce 100)

   .  reduce 100



state 806
   o.generic_actual_part :  ( generic_association r.generic_association )!   (reduce 424)

   .  reduce 424



state 807
   r.generic_association :  , generic_association!r.generic_association 
   r.generic_association : !   (reduce 427)

   ,  shift 756
   .  reduce 427

   r.generic_association  goto 841


state 808
   generic_association :  generic_formal_parameter ASSOC generic_actual_parameter!   (reduce 428)

   .  reduce 428



state 809
   package_body :  PACKAGE BODY PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name!; 

   ;  shift 842
   .  error



state 810
   unconstrained_array_definition :  ARRAY ( index_subtype_definition r.index_subtype_definition )!OF component_subtype_indication 

   OF  shift 843
   .  error



state 811
   r.index_subtype_definition :  , index_subtype_definition!r.index_subtype_definition 
   r.index_subtype_definition : !   (reduce 83)

   ,  shift 763
   .  reduce 83

   r.index_subtype_definition  goto 844


state 812
   index_subtype_definition :  type_mark!RANGE BOX 

   RANGE  shift 845
   .  error



state 813
   index_subtype_definition :  type_mark RANGE BOX!   (reduce 86)

   .  reduce 86



state 814
   exception_handler :  WHEN exception_choice r.exception_choice ASSOC!sequence_of_statements 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 846
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 815
   r.exception_choice :  | exception_choice!r.exception_choice 
   r.exception_choice : !   (reduce 398)

   |  shift 770
   .  reduce 398

   r.exception_choice  goto 847


state 816
   if_statement :  IF condition THEN sequence_of_statements r.elsif.condition o.else!END IF ; 

   END  shift 848
   .  error



state 817
   o.else :  ELSE!sequence_of_statements 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 849
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 818
   r.elsif.condition :  ELSIF condition!THEN sequence_of_statements r.elsif.condition 

   THEN  shift 850
   .  error



state 819
   case_statement :  CASE expression IS case_statement_alternative r.case_statement_alternative END!CASE ; 

   CASE  shift 851
   .  error



state 820
   r.case_statement_alternative :  case_statement_alternative r.case_statement_alternative!   (reduce 253)

   .  reduce 253



state 821
   case_statement_alternative :  WHEN choice r.choice!ASSOC sequence_of_statements 

   ASSOC  shift 852
   .  error



state 822
   loop_statement :  LOOP_name : iteration_scheme LOOP sequence_of_statements END!LOOP LOOP_name ; 

   LOOP  shift 853
   .  error



state 823
   loop_statement :  iteration_scheme LOOP sequence_of_statements END LOOP ;!   (reduce 257)

   .  reduce 257



state 824
   block_statement :  BLOCK_name : o.DECLARE BEGIN sequence_of_statements o.EXCEPTION!END BLOCK_name ; 

   END  shift 854
   .  error



state 825
   block_statement :  o.DECLARE BEGIN sequence_of_statements o.EXCEPTION END ;!   (reduce 264)

   .  reduce 264



state 826
   accept_statement :  ACCEPT ENTRY_name ( entry_index ) o.formal_part!o.DO ; 
   o.DO : !   (reduce 341)

   DO  shift 722
   .  reduce 341

   o.DO  goto 855


state 827
   o.DO :  DO sequence_of_statements END!ENTRY_name 

   ENTRY_name  shift 856
   .  error



state 828
   selective_wait :  SELECT select_alternative o.OR.select_alternative o.ELSE.sequence_of_statements END SELECT!; 

   ;  shift 857
   .  error



state 829
   conditional_entry_call :  SELECT entry_call_statement o.sequence_of_statements ELSE sequence_of_statements END!SELECT ; 

   SELECT  shift 858
   .  error



state 830
   timed_entry_call :  SELECT entry_call_statement o.sequence_of_statements OR delay_alternative END!SELECT ; 

   SELECT  shift 859
   .  error



state 831
   record_representation_clause :  FOR TYPE_name USE RECORD o.alignment_clause o.component_clause END RECORD!; 

   ;  shift 860
   .  error



state 832
   o.component_clause :  COMPONENT_name AT STATIC_simple_expression!RANGE STATIC_range ; 

   RANGE  shift 861
   .  error



state 833
   o.alignment_clause :  AT MOD STATIC_simple_expression ;!   (reduce 445)

   .  reduce 445



state 834
   task_specification :  TASK o.TYPE IDENTIFIER IS r.entry_declaration r.representation_clause END TASK_name!   (reduce 326)

   .  reduce 326



state 835
   entry_declaration :  ENTRY IDENTIFIER ( discrete_range!) o.formal_part ; 

   )  shift 862
   .  error



state 836
   entry_declaration :  ENTRY IDENTIFIER o.formal_part ;!   (reduce 335)

   .  reduce 335



state 837
   task_body :  TASK BODY TASK_name IS declarative_part BEGIN sequence_of_statements o.EXCEPTION!END TASK_name ; 

   END  shift 863
   .  error



state 838
   r.enumeration_literal_specification :  , enumeration_literal_specification r.enumeration_literal_specification!   (reduce 65)

   .  reduce 65



state 839
   variant_part :  CASE DISCRIMINANT_name IS!variant r.variant END CASE ; 

   WHEN  shift 865
   .  error

   variant  goto 864


state 840
   component_declaration :  identifier_list : component_subtype_definition o.expression!; 

   ;  shift 866
   .  error



state 841
   r.generic_association :  , generic_association r.generic_association!   (reduce 426)

   .  reduce 426



state 842
   package_body :  PACKAGE BODY PACKAGE_name IS declarative_part o.BEGIN o.EXCEPTION END PACKAGE_name ;!   (reduce 313)

   .  reduce 313



state 843
   unconstrained_array_definition :  ARRAY ( index_subtype_definition r.index_subtype_definition ) OF!component_subtype_indication 

   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   .  error

   subtype_indication  goto 733
   type_mark  goto 411
   component_subtype_indication  goto 867


state 844
   r.index_subtype_definition :  , index_subtype_definition r.index_subtype_definition!   (reduce 82)

   .  reduce 82



state 845
   index_subtype_definition :  type_mark RANGE!BOX 

   BOX  shift 813
   .  error



state 846
   exception_handler :  WHEN exception_choice r.exception_choice ASSOC sequence_of_statements!   (reduce 396)

   .  reduce 396



state 847
   r.exception_choice :  | exception_choice r.exception_choice!   (reduce 397)

   .  reduce 397



state 848
   if_statement :  IF condition THEN sequence_of_statements r.elsif.condition o.else END!IF ; 

   IF  shift 868
   .  error



state 849
   o.else :  ELSE sequence_of_statements!   (reduce 249)

   .  reduce 249



state 850
   r.elsif.condition :  ELSIF condition THEN!sequence_of_statements r.elsif.condition 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 869
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 851
   case_statement :  CASE expression IS case_statement_alternative r.case_statement_alternative END CASE!; 

   ;  shift 870
   .  error



state 852
   case_statement_alternative :  WHEN choice r.choice ASSOC!sequence_of_statements 
   iteration_scheme : !   (reduce 260)
   o.DECLARE : !   (reduce 266)

   ABORT  shift 389
   ACCEPT  shift 398
   CASE  shift 393
   DECLARE  shift 404
   DELAY  shift 388
   EXIT  shift 384
   FOR  shift 403
   GOTO  shift 386
   IF  shift 392
   LOOP  reduce 260
   NULL  shift 381
   PRAGMA  shift 5
   RAISE  shift 390
   RETURN  shift 385
   SELECT  shift 405
   WHILE  shift 402
   <  shift 362
   BLOCK_name  shift 396
   ENTRY_name  shift 387
   LOOP_name  shift 394
   PROCEDURE_name  shift 383
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   VARIABLE_name  shift 382
   .  reduce 266

   pragma  goto 364
   type_mark  goto 391
   sequence_of_statements  goto 871
   statement  goto 358
   label  goto 359
   simple_statement  goto 360
   compound_statement  goto 361
   null_statement  goto 363
   assignment_statement  goto 365
   procedure_call_statement  goto 366
   exit_statement  goto 367
   return_statement  goto 368
   goto_statement  goto 369
   entry_call_statement  goto 370
   delay_statement  goto 371
   abort_statement  goto 372
   raise_statement  goto 373
   code_statement  goto 374
   if_statement  goto 375
   case_statement  goto 376
   loop_statement  goto 377
   block_statement  goto 378
   accept_statement  goto 379
   select_statement  goto 380
   iteration_scheme  goto 395
   o.DECLARE  goto 397
   selective_wait  goto 399
   conditional_entry_call  goto 400
   timed_entry_call  goto 401


state 853
   loop_statement :  LOOP_name : iteration_scheme LOOP sequence_of_statements END LOOP!LOOP_name ; 

   LOOP_name  shift 872
   .  error



state 854
   block_statement :  BLOCK_name : o.DECLARE BEGIN sequence_of_statements o.EXCEPTION END!BLOCK_name ; 

   BLOCK_name  shift 873
   .  error



state 855
   accept_statement :  ACCEPT ENTRY_name ( entry_index ) o.formal_part o.DO!; 

   ;  shift 874
   .  error



state 856
   o.DO :  DO sequence_of_statements END ENTRY_name!   (reduce 340)

   .  reduce 340



state 857
   selective_wait :  SELECT select_alternative o.OR.select_alternative o.ELSE.sequence_of_statements END SELECT ;!   (reduce 349)

   .  reduce 349



state 858
   conditional_entry_call :  SELECT entry_call_statement o.sequence_of_statements ELSE sequence_of_statements END SELECT!; 

   ;  shift 875
   .  error



state 859
   timed_entry_call :  SELECT entry_call_statement o.sequence_of_statements OR delay_alternative END SELECT!; 

   ;  shift 876
   .  error



state 860
   record_representation_clause :  FOR TYPE_name USE RECORD o.alignment_clause o.component_clause END RECORD ;!   (reduce 444)

   .  reduce 444



state 861
   o.component_clause :  COMPONENT_name AT STATIC_simple_expression RANGE!STATIC_range ; 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   type_mark  goto 80
   range  goto 878
   RANGE_attribute  goto 157
   simple_expression  goto 252
   STATIC_range  goto 877
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 862
   entry_declaration :  ENTRY IDENTIFIER ( discrete_range )!o.formal_part ; 
   o.formal_part : !   (reduce 343)

   (  shift 208
   .  reduce 343

   formal_part  goto 623
   o.formal_part  goto 879


state 863
   task_body :  TASK BODY TASK_name IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END!TASK_name ; 

   TASK_name  shift 880
   .  error



state 864
   variant_part :  CASE DISCRIMINANT_name IS variant!r.variant END CASE ; 
   r.variant : !   (reduce 115)

   .  reduce 115

   r.variant  goto 881


state 865
   variant :  WHEN!choice r.choice ASSOC component_list 

   ABS  shift 69
   NEW  shift 79
   NOT  shift 70
   NULL  shift 78
   OTHERS  shift 152
   CHARACTER_LITERAL  shift 50
   IDENTIFIER  shift 57
   NUMERIC_LITERAL  shift 76
   OPERATOR_STRING_LITERAL  shift 58
   STRING_LITERAL  shift 77
   +  shift 64
   -  shift 65
   COMPONENT_name  shift 153
   FUNCTION_name  shift 63
   SUBTYPE_name  shift 82
   TYPE_name  shift 81
   (  shift 75
   .  error

   name  goto 137
   subtype_indication  goto 156
   type_mark  goto 158
   range  goto 155
   RANGE_attribute  goto 157
   simple_expression  goto 343
   discrete_range  goto 151
   discrete_subtype_indication  goto 154
   choice  goto 882
   simple_name  goto 49
   operator_symbol  goto 51
   indexed_component  goto 52
   slice  goto 53
   selected_component  goto 54
   attribute  goto 159
   prefix  goto 59
   function_call  goto 61
   aggregate  goto 71
   s.term  goto 62
   term  goto 66
   factor  goto 67
   primary  goto 68
   allocator  goto 72
   type_conversion  goto 73
   qualified_expression  goto 74


state 866
   component_declaration :  identifier_list : component_subtype_definition o.expression ;!   (reduce 99)

   .  reduce 99



state 867
   unconstrained_array_definition :  ARRAY ( index_subtype_definition r.index_subtype_definition ) OF component_subtype_indication!   (reduce 81)

   .  reduce 81



state 868
   if_statement :  IF condition THEN sequence_of_statements r.elsif.condition o.else END IF!; 

   ;  shift 883
   .  error



state 869
   r.elsif.condition :  ELSIF condition THEN sequence_of_statements!r.elsif.condition 
   r.elsif.condition : !   (reduce 248)

   ELSIF  shift 775
   .  reduce 248

   r.elsif.condition  goto 884


state 870
   case_statement :  CASE expression IS case_statement_alternative r.case_statement_alternative END CASE ;!   (reduce 252)

   .  reduce 252



state 871
   case_statement_alternative :  WHEN choice r.choice ASSOC sequence_of_statements!   (reduce 255)

   .  reduce 255



state 872
   loop_statement :  LOOP_name : iteration_scheme LOOP sequence_of_statements END LOOP LOOP_name!; 

   ;  shift 885
   .  error



state 873
   block_statement :  BLOCK_name : o.DECLARE BEGIN sequence_of_statements o.EXCEPTION END BLOCK_name!; 

   ;  shift 886
   .  error



state 874
   accept_statement :  ACCEPT ENTRY_name ( entry_index ) o.formal_part o.DO ;!   (reduce 338)

   .  reduce 338



state 875
   conditional_entry_call :  SELECT entry_call_statement o.sequence_of_statements ELSE sequence_of_statements END SELECT ;!   (reduce 364)

   .  reduce 364



state 876
   timed_entry_call :  SELECT entry_call_statement o.sequence_of_statements OR delay_alternative END SELECT ;!   (reduce 367)

   .  reduce 367



state 877
   o.component_clause :  COMPONENT_name AT STATIC_simple_expression RANGE STATIC_range!; 

   ;  shift 887
   .  error



state 878
   STATIC_range :  range!   (reduce 63)

   .  reduce 63



state 879
   entry_declaration :  ENTRY IDENTIFIER ( discrete_range ) o.formal_part!; 

   ;  shift 888
   .  error



state 880
   task_body :  TASK BODY TASK_name IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name!; 

   ;  shift 889
   .  error



state 881
   variant_part :  CASE DISCRIMINANT_name IS variant r.variant!END CASE ; 
   r.variant :  r.variant!variant 

   END  shift 890
   WHEN  shift 865
   .  error

   variant  goto 891


state 882
   variant :  WHEN choice!r.choice ASSOC component_list 
   r.choice : !   (reduce 118)

   |  shift 269
   .  reduce 118

   r.choice  goto 892


state 883
   if_statement :  IF condition THEN sequence_of_statements r.elsif.condition o.else END IF ;!   (reduce 246)

   .  reduce 246



state 884
   r.elsif.condition :  ELSIF condition THEN sequence_of_statements r.elsif.condition!   (reduce 247)

   .  reduce 247



state 885
   loop_statement :  LOOP_name : iteration_scheme LOOP sequence_of_statements END LOOP LOOP_name ;!   (reduce 256)

   .  reduce 256



state 886
   block_statement :  BLOCK_name : o.DECLARE BEGIN sequence_of_statements o.EXCEPTION END BLOCK_name ;!   (reduce 263)

   .  reduce 263



state 887
   o.component_clause :  COMPONENT_name AT STATIC_simple_expression RANGE STATIC_range ;!   (reduce 447)

   .  reduce 447



state 888
   entry_declaration :  ENTRY IDENTIFIER ( discrete_range ) o.formal_part ;!   (reduce 334)

   .  reduce 334



state 889
   task_body :  TASK BODY TASK_name IS declarative_part BEGIN sequence_of_statements o.EXCEPTION END TASK_name ;!   (reduce 333)

   .  reduce 333



state 890
   variant_part :  CASE DISCRIMINANT_name IS variant r.variant END!CASE ; 

   CASE  shift 893
   .  error



state 891
   r.variant :  r.variant variant!   (reduce 114)

   .  reduce 114



state 892
   variant :  WHEN choice r.choice!ASSOC component_list 

   ASSOC  shift 894
   .  error



state 893
   variant_part :  CASE DISCRIMINANT_name IS variant r.variant END CASE!; 

   ;  shift 895
   .  error



894: shift/reduce conflict (shift 104, reduce 98) on IDENTIFIER
state 894
   variant :  WHEN choice r.choice ASSOC!component_list 
   r.component_declaration : !   (reduce 98)

   NULL  shift 664
   IDENTIFIER  shift 104
   .  reduce 98

   identifier_list  goto 665
   component_list  goto 896
   component_declaration  goto 662
   r.component_declaration  goto 663


state 895
   variant_part :  CASE DISCRIMINANT_name IS variant r.variant END CASE ;!   (reduce 113)

   .  reduce 113



state 896
   variant :  WHEN choice r.choice ASSOC component_list!   (reduce 116)

   .  reduce 116


Rule not reduced:  o.discriminant_part :  
Rule not reduced:  library_unit_body :  subprogram_body 

Summary:
   119/ 150 terminals               211/ 350 nonterminals       
   451/ 750 grammar rules           897/1000 states             
  5054/7000 parser actions         4729/6000 name string pool   
   348/ 500 lookahead sets          211/ 400 working sets used  
  6381/9000 parser memory, etc.    1511 extra closures          
   122 shift/reduce conflicts        46 reduce/reduce conflicts 
  2432 shift entries                 69 exceptions              
   617 goto entries                2536 entries saved by goto default

Optimizer summary:
  5889/9000 input space            1730/7000 output space
  1730 table entries                251 zero
   357 maximum spread               894 maximum offset

