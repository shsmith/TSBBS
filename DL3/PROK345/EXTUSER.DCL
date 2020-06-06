
(*
 * Copyright 1987, 1991 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

const
   max_conf = 39;               {highest conference number}
   conf_limit = max_conf+1;

   min_econf = conf_limit;      {lowest extended conference number}
   max_econf = 5000+conf_limit; {highest extended conference number}

   max_extcount = max_econf - min_econf;
                                {highest extcount for extuser file}

   {bit values in conf[n].flags}
   ext_scan       = $01;         {are we scanning this conf?}
   ext_dly        = $02;         {download only your own messages}
   ext_qnet       = $04;         {qnet status}
   ext_sysop      = $08;         {sysop status}
   ext_joined     = $10;         {have we joined today?}
   ext_ro         = $20;         {read/only status}
   ext_priv       = $40;         {updloads private??}
   ext_member     = $80;         {are a member of this conf?}

 (* --- Bits defined in fixed.flag1 --- *)

   km_quick_g  =   1;   { hangup, then process REP file   }
   km_news     =   2;   { send the system news file       }
   km_blt      =   4;   { send bulletins                  }
   km_files    =   8;   { send New Files List             }
   km_own      =  16;   { download msgs you have uploaded }
   km_xpert    =  32;   { expert on/off                   }
   km_ndx_off  =  64;   { Do not send .NDX files          }
   km_init     = 128;   { On after first time in door     }

 (* --- Bits defined in fixed.flag2 --- *)

   km_f21      =   1;   { unallocated
   km_f22      =   2;   { unallocated
   km_PersLimit=   4;   { Enable personal packet limits   }


(* layout of extended user information file *)
type
   extuser_fixed_rec = record
      extcount: byte;         {number of extended conferences in first}
      extcounth:byte;         {high part of extcount if <$20}
      spare0:   char3;        {unallocated spares}
      name:     char25;       {user name}
      lockreg:  boolean;      {lock conference registrations?}
      lastdate: char8;        {last date of access mm-dd-yy}
      level:    byte;         {security level of last access}
      spare2:   char39;       {unallocated spares}

   (* following fields used by KMail and other mail doors *)
      flag1:    byte;         {flags described above    }
      flag2:    byte;         {flags described above    }
      prot:     char;         {Protocol - X/Y/Z/H       }
      arch:     char;         {Archiver - A/Z/L         }
      sysfile:  longint;      {Date of last file send   }
      conflimit:integer;      {User defined conf limit  }
      mstrlimit:integer;      {User defined total limit }

      spare3:   char28;       {unallocated spare}
   end;

   extuser_conf_rec = record
      flags:    byte;         {flag bits}
      lastread: single;       {last message read}
   end;

   extuser_rec = record
      fixed:   extuser_fixed_rec;      {fixed user info}

      conf:    array[0..max_econf]     {extended conference info}
               of extuser_conf_rec;
   end;

   extuser_ptr = ^extuser_rec;  {dynamic extuser variable, allocated
                                 with dos_getmem for actual size}

