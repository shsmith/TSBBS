
(*
 * Copyright 1987, 1991 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *  NOTICE: ALL MODIFIED VERSIONS OF THIS PROGRAM _MUST_ BE DISTRIBUTED
 *          WITH SOURCE CODE.  I STRICTLY FORBID THE USE OF ANY NON-
 *          PUBLIC INFORMATION IN MODIFICATIONS.  FOR EXAMPLE, YOU
 *          CANNOT USE CDC PROVIDED INFORMATION FOR PCBOARD 14.5
 *          COMPATIBILITY, SINCE SUCH A VERSION CANNOT BE RELEASED IN
 *          SOURCE CODE.
 *)



{some commonly used message strings}

(********

const
   local_msg       = 'Local';
   upload_msg      = 'Upload ';
   download_msg    = 'Download ';
   ul_dir_has      = ' upload dir has ';
   k_free          = 'k free';
   k_max_per_xfr   = 'k max per transfer';
   no_ul_space     = 'Insufficient disk space for uploading!';
   wild_ok         = 'Wildcards are Okay, ';
   is_assumed      = ' is assumed.';
   enter_up_to     = 'Enter up to ';
   end_list_with   = ' filespecs.  End the list with a blank line.';
   enter_desc_of   = 'Please enter a description of (';
   mins_left_msg   = ' min. left';
   filespec_msg    = 'Filespec';
   checking        = 'Checking ... ';
   enter_to_end    = '  (Enter) alone to end.';
   begin_descrip   = 'Begin description with (/) to make upload ''Private''.';
   longer_descrip  = 'Enter a longer description of the file please!';
   completed_using = ' Completed using ';
   aborted_using   = ' Aborted using ';
   msgs_captured   = ' messages captured.';
   conf_joined     = ' Conference Joined.';
   changes_saved   = 'Changes saved ...';
   please_wait     = 'Processing your request.  Please wait ...';
   ctrlk_aborts    = ') ... (Ctrl-K) aborts';
*******)

const
   onoff: array[boolean] of string[4] = (' OFF', ' ON');
   yesno: array[boolean] of string[3] = ('NO ', 'YES');


const
   dotpak:          string[4]  = '.ZIP';

const
   all25:           char25     = 'ALL                      ';
   sysop25:         char25     = 'SYSOP                    ';

const
   allkeys:         string[62] = '!"#$%&''()*+, -./ :<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`';
   all_stars:       string[62] = '**************************************************************';
   enter_eq:        string[8]  = '(Enter)=';
   enter_eq_none:   string[14] = '(Enter)=none? ';
   enter_eq_no:     string[13] = '(Enter)=no? ';
   enter_eq_yes:    string[13] = '(Enter)=yes? ';

var
   enter_eq_yesno:  array[false..true] of string[13] absolute enter_eq_no;

