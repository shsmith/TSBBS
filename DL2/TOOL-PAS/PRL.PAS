
(*
 * Prototype Condat user interface with pulldown menus.
 *
 * Samuel H. Smith, 13-nov-87 (19-oct-89)
 *
 *)

{$D+}    {Global debug information}
{$L+}    {Local debug information}
{$F+}    {Required for procedure pointers to work}

{$M 16000,16000,500000}

uses ERRTRAP, CRT, PULL;


{define line item actions}
const
   UNDEF_ACTION         = 10000;
   LEAVE_MENU           = 10001;
   QUIT_TOP             = 10002;

   NEW_PROVING          = 10003;
   START_PROVING        = 10004;
   STORE_SETTINGS       = 10005;
   LOAD_SETTINGS        = 10006;


{define variable item actions}
const
   PASSES_PER_RUN_VAR   = FIRST_VAR+0;
   NUMBER_OF_RUNS_VAR   = FIRST_VAR+1;
   MAX_DEVIATION_VAR    = FIRST_VAR+2;
   EQUILIBRIUM_P_VAR    = FIRST_VAR+3;
   OPTICS_T_VAR         = FIRST_VAR+4;
   COMP_REF_P_VAR       = FIRST_VAR+5;
   COMP_REF_T_VAR       = FIRST_VAR+6;
   CPLP_VAR             = FIRST_VAR+7;
   CTLP_VAR             = FIRST_VAR+8;
   CPSP_VAR             = FIRST_VAR+9;
   CPLM_VAR             = FIRST_VAR+10;
   VAR_COUNT            = 10;


{define pulldown menu action codes}
const
   TOP_LEVEL_MENU       = 0;
   UNDEFINED_MENU       = 1;
   RUN_MENU             = 2;
   DISPLAY_MENU         = 3;
   GRAPH_MENU           = 4;
   REPORT_MENU          = 5;
   FILES_MENU           = 6;
   SETUP_MENU           = 7;
   QUIT_MENU            = 8;
   METER_LOCATION_SEL   = 9;
   COMPENSATION_MENU    = 10;
   GENERAL_SETUP_MENU   = 11;
   DIAG_MENU            = 12;


(* -------------------------------------------------------- *)
{define pulldown menu contents}
const
   PULL_COUNT = 12;
   my_table: array[0..PULL_COUNT] of pulldown_rec = (


{TOP_LEVEL_MENU}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;   {color definition}
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;       {init and exit actions}

        line: ( (title: 'Run';          action: RUN_MENU),
                (title: 'Display';      action: DISPLAY_MENU),
                (title: 'Graph';        action: GRAPH_MENU),
                (title: 'Report';       action: REPORT_MENU),
                (title: 'File';         action: FILES_MENU),
                (title: 'Setup';        action: SETUP_MENU),
                (title: 'Test';         action: DIAG_MENU),
                (title: 'Quit';         action: QUIT_MENU),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) )),


{UNDEFINED_MENU}
      ( border:    single_border;
        border_fg: black;  border_bg: red;
        text_fg:   white;  text_bg:   red;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: '[NOT IMPLEMENTED]';            action: divider_entry),
                (title: '     Cancel      ';            action: LEAVE_MENU),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) )),


{RUN_MENU}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'New meter proving';    action: NEW_PROVING),
                (title: 'Single prover run';    action: START_PROVING),
                (title: 'Multiple prover runs'; action: START_PROVING),
                (title: '---------------------';action: divider_entry),
                (title: 'Meter location...';    action: METER_LOCATION_SEL),
                (title: 'Compensation...';      action: COMPENSATION_MENU),
                (title: ' Passes per run =';    action: PASSES_PER_RUN_VAR),
                (title: ' Number of runs =';    action: NUMBER_OF_RUNS_VAR),
                (title: 'Max % deviation =';    action: MAX_DEVIATION_VAR),
                (title: ''; action: unused_entry) )),


{DISPLAY_MENU}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'Next';                 action: UNDEFINED_MENU),
                (title: 'Previous';             action: UNDEFINED_MENU),
                (title: 'Delete';               action: UNDEFINED_MENU),
                (title: 'Insert';               action: UNDEFINED_MENU),
                (title: 'Edit';                 action: UNDEFINED_MENU),
                (title: 'Formula';              action: UNDEFINED_MENU),
                (title: 'Recalculate';          action: UNDEFINED_MENU),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) )),


{GRAPH_MENU}    
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'K vs Flow';            action: UNDEFINED_MENU),
                (title: 'K vs Frequency';       action: UNDEFINED_MENU),
                (title: 'Freq vs Flow';         action: UNDEFINED_MENU),
                (title: 'K vs Density';         action: UNDEFINED_MENU),
                (title: 'Reading Error';        action: UNDEFINED_MENU),
                (title: 'F.S. Error';           action: UNDEFINED_MENU),
                (title: 'User Defined';         action: UNDEFINED_MENU),
                (title: 'Options...';           action: UNDEFINED_MENU),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) )),


{REPORT_MENU}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'Header data...';       action: UNDEFINED_MENU),
                (title: 'Data review/Summary';  action: UNDEFINED_MENU),
                (title: 'Standard reports';     action: UNDEFINED_MENU),
                (title: 'Custom forms';         action: UNDEFINED_MENU),
                (title: '-------------------';  action: divider_entry),
                (title: 'Select forms';         action: UNDEFINED_MENU),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) )),


{FILES_MENU}    
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'Store';                action: UNDEFINED_MENU),
                (title: 'Load';                 action: UNDEFINED_MENU),
                (title: 'Delete';               action: UNDEFINED_MENU),
                (title: '-----------------';    action: divider_entry),
                (title: 'Working directory';    action: UNDEFINED_MENU),
                (title: 'Sort order';           action: UNDEFINED_MENU),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) )),


{SETUP_MENU}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'General';              action: GENERAL_SETUP_MENU),
                (title: 'Analog inputs';        action: UNDEFINED_MENU),
                (title: 'Proving mode';         action: UNDEFINED_MENU),
                (title: 'Fluid type';           action: UNDEFINED_MENU),
                (title: 'Density mode';         action: UNDEFINED_MENU),
                (title: 'Unit systems';         action: UNDEFINED_MENU),
                (title: '-----------------';    action: divider_entry),
                (title: 'stoRe settings';       action: STORE_SETTINGS),
                (title: 'Load settings';        action: LOAD_SETTINGS),
                (title: 'Factory defaults';     action: UNDEFINED_MENU) )),


{QUIT_MENU}     
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'No';                   action: LEAVE_MENU),
                (title: 'Yes';                  action: QUIT_TOP),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) )),

{METER_LOCATION_SEL}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'Upstream';          action: LEAVE_MENU),
                (title: 'Downstream';        action: LEAVE_MENU),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) )),

{COMPENSATION_MENU}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: '  Equilibrium vapor pressure ='; action: EQUILIBRIUM_P_VAR),
                (title: '      Switch bar temperature ='; action: OPTICS_T_VAR),
                (title: '       Reference    pressure ='; action: COMP_REF_P_VAR),
                (title: '       Reference temperature ='; action: COMP_REF_T_VAR),
                (title: '';                               action: divider_entry),
                (title: '----- Corrections (0=calculated) -----'; action: divider_entry),
                (title: 'Pres on Liq.  @ prover CPL-P ='; action: CPLP_VAR),
                (title: 'Temp on Liq.  @ prover CTL-P ='; action: CTLP_VAR),
                (title: 'Pres on Steel @ prover CPS-P ='; action: CPSP_VAR),
                (title: 'Pres on Liq.  @ meter  CPL-M ='; action: CPLM_VAR)
                )),

{GENERAL_SETUP_MENU}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'Company name';         action: UNDEFINED_MENU),
                (title: 'Certified volumes';    action: UNDEFINED_MENU),
                (title: 'Prover dimensions';    action: UNDEFINED_MENU),
                (title: 'Prover serial number'; action: UNDEFINED_MENU),
                (title: 'Water draw dates';     action: UNDEFINED_MENU),
                (title: 'Prover type';          action: UNDEFINED_MENU),
                (title: '';                     action: unused_entry),
                (title: '';                     action: unused_entry),
                (title: '';                     action: unused_entry),
                (title: '';                     action: unused_entry) )),

{DIAG_MENU}
      ( border:    taildouble_border;
        border_fg: white;  border_bg: black;
        text_fg:   white;  text_bg:   black;
        select_fg: black;  select_bg: white;
        ainit:     0;      aexit:     0;

        line: ( (title: 'Water draw';                 action: UNDEFINED_MENU),
                (title: 'Analog';                     action: UNDEFINED_MENU),
                (title: 'Counters';                   action: UNDEFINED_MENU),
                (title: 'Simulation';                 action: UNDEFINED_MENU),
                (title: 'Head check';                 action: UNDEFINED_MENU),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry),
                (title: ''; action: unused_entry) ))
 );


(* -------------------------------------------------------- *)
function my_action(pull:     integer;   (* pulldown menu number *)
                   entry:    integer;   (* entry in pulldown menu *)
                   action:   integer;   (* action code *)
                   var sel:  char)      (* select key *)
                             : boolean;       (* true to force menu exit *)
   {pulldown action routine; called when a pulldown entry is selected}

   procedure do_leave;
   begin
      my_action := true;
      sel := ESC;
   end;

begin
   my_action := false;

   case action of
      TOP_LEVEL_MENU..PULL_COUNT:        {call submenus}
         open_pulldown(action,sel);

      FIRST_VAR..LAST_VAR:               {edit variables}
         begin
            edit_variable(pull,action);      {edit the variable[action]}
            fixup_vars(pull);                {update display image}
            pulldown_redisp := true;
            my_action := true;               {force redisplay}
         end;

      LEAVE_MENU:                        {otherwise execute specific actions}
         do_leave;

      QUIT_TOP:
         begin
            my_action := true;
            sel := quit_sel;
         end;

      STORE_SETTINGS:
         begin
            do_store_settings;
            do_leave;
         end;

      LOAD_SETTINGS:
         begin
            do_load_settings;
            do_leave;
         end;
   end;
end;


(* -------------------------------------------------------- *)
procedure my_init(pull:      integer;
                  action:    integer;
                  var sel:   char);
   {pulldown init routine; called when a pulldown menu is opened}
begin
   setcolor(white,red);
   fixup_vars(pull);

   case pull of

      UNDEFINED_MENU:
         ;

      RUN_MENU:
         begin
            gotoxy(20,16);   disp('                             ');
            gotoxy(20,17);   disp(' Runs completed     = _____  ');
            gotoxy(20,18);   disp(' Actual % deviation = _____  ');
            gotoxy(20,19);   disp('                             ');
         end;

      DISPLAY_MENU:
         begin
            gotoxy(10,20);   disp('  Datapoint ___ out of ___  ');
         end;

      GRAPH_MENU:
         ;

      REPORT_MENU:
         ;

      FILES_MENU:
         ;

      SETUP_MENU:
         ;

      GENERAL_SETUP_MENU:
         ;

      QUIT_MENU:
         ;
   end;
end;


(* -------------------------------------------------------- *)
procedure my_exit(pull:      integer;
                  action:    integer;
                  var sel:   char);
   {pulldown exit routine; called when a pulldown menu is closed}
begin
end;


(* -------------------------------------------------------- *)
function my_key(pull:     integer;   (* pulldown menu number *)
                entry:    integer;   (* entry in pulldown menu *)
                var sel:  char)      (* select key *)
                             : boolean;       (* true to force menu exit *)

   {process unknown keys}
   procedure help;
   var
      save: ^window_save_rec;
   begin
      new(save);
      save_window(save^);

      window(1,1,80,25);
      setcolor(yellow,black);
      display_border(24,7,57,16,thinsolid_border);

      gotoxy(25, 8);   disp('                               ');
      gotoxy(25, 9);   disp('     --- Help-on-tap ---       ');
      gotoxy(25,10);   disp('                               ');
      gotoxy(25,11);   disp('        Pulldown # '); write(pull :3); disp('         ');
      gotoxy(25,12);   disp('           Entry # '); write(entry:3); disp('         ');
      gotoxy(25,13);   disp('                               ');
      gotoxy(25,14);   disp('     [ Press ESC to exit ]     ');
      gotoxy(25,15);   disp('                               ');

      repeat
      until getkey = ESC;

      restore_window(save^);
      dispose(save);
   end;

begin
   my_key := false;

   case sel of
      F1:    help;
      else   disp(^G);
   end;
end;



(* -------------------------------------------------------- *)

begin
   init_pulldown(my_action,my_init,my_exit,my_key, {action procedures}
                 my_table, PULL_COUNT,             {pulldown table}
                 VAR_COUNT,                        {variable table}
                 'PRL.CNF');                       {config file name}

   setcolor(white,blue);
   clrscr;

{  setcolor(cyan,black);
   display_border(25,9,56,17,evensolid_border);
   gotoxy(26,10); displn('                             ');
   gotoxy(26,11); displn('         C o n d a t         ');
   gotoxy(26,12); displn('                             ');
   gotoxy(26,13); displn('    Liquid Prover Control    ');
   gotoxy(26,14); displn('             by              ');
   gotoxy(26,15); displn('   Calibron Systems, Inc.    ');
   gotoxy(26,16); displn('                             ');
}

   setcolor(lightgray,black);
   gotoxy(14,24);
   displn('  '#24#25#27#26' to select,   ды to activate,   F1 for Help  ');

   do_load_settings;

   top_menu(8,3);

   setcolor(lightgray,black);
   clrscr;
end.

