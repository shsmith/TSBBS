
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * PCBoard file configuration file declarations (3-1-89)
 *
 *)

const
   min_control = '0';
   max_control = '[';

type
   sysop_control_rec = record
      minlevel:      integer;       (* minimum security level for access *)
      timefact:      real;          (* time charge(+) or credit(-) factor *)
      bytefact:      real;          (* bytecount charge(+) or credit(-) fact *)
   end;

   control_table = array[min_control..max_control] of sysop_control_rec;


const
   min_desc  = 15;           (* minimum upload description length *)
   max_files = 50;           (* maximum number of files per transfer *)
   max_proto = 100;          (* number of protocols in the protocol table *)
   max_dir   = 200;          (* maximum number of download directories *)
      
type
   name_table  = record
      entry: array[1..max_files] of varstring;
      count: integer;
   end;

   dir_table  = record
      entry: array[1..max_dir] of varstring;
      count: integer;
   end;


   transfer_modes = (TX,RX);      (* data transfer modes *)

   protocol_description = record
      code:    char;              (* single letter protocol code *)
      mode:    transfer_modes;    (* the protocol mode TX or RX *)
      files:   integer;           (* the maximum number of filenames *)
      title:   varstring;         (* the menu title/protocol name *)
      command: varstring;         (* the command prefix *)
      peffic:  real;              (* protocol efficiency *)
      efree:   boolean;           (* error free connection required? *)
   end;


   (* layout of PCBPRO.CNF configuration *)
   config_rec = record
      overhead:        real;       (* overhead time to load protocol and
                                      reload logger (seconds) *)

      playpen_dir:     filenames;  (* path of "playpen" directory for uploads *)
      scratch_prefix:  string8;    (* scratch filename prefix *)

      trashcan_list:   filenames;  (* path of held-upload list \pcb\main\trash *)
      trashcan_dir:    filenames;  (* location of trashed-upload subdir *)

      scratch_dir:     filenames;  (* location of scratch.arc *)
      mail_prefix:     string8;    (* ARCM filename prefix *)

      listing_command: filenames;  (* list arc members *)
      typetext_command:filenames;  (* get text member to stdout *)
      xtract_command:  filenames;  (* extract from arc to arc *)
      test_command:    filenames;  (* test archive *)
      rearc_command:   filenames;  (* repack archive *)
      badarc_keymsg:   filenames;  (* message for arc test failure *)

      protocol_table:  array[1..max_proto] of protocol_description;
      protocol_count:  integer;
   end;


const
   max_capcount: integer = 400;  {maximum number of msgs to capture at once}

