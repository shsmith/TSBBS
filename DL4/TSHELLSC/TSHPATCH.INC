
const tshpatch_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Turbo patches turbo 1.0'#0;
#log Install patches in turbo.com


(*------------------------------------------
 *
 * new_search - this ASM procedure is a replacement for the
 *              slowest part of the turbo pascal symbol table
 *              search routine.  it uses inline code instead
 *              of looping to increase instruction queue performance
 *              and to reduce branch-prefetch overhead.
 *)

procedure _new_search;
begin
   inline(
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$66/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$6D/                   {  jz not_found   }
                                  { ;               }
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$5A/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$61/                   {  jz not_found   }
                                  { ;               }
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$4E/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$55/                   {  jz not_found   }
                                  { ;               }
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$42/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$49/                   {  jz not_found   }
                                  { ;               }
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$36/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$3D/                   {  jz not_found   }
                                  { ;               }
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$2A/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$31/                   {  jz not_found   }
                                  { ;               }
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$1E/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$25/                   {  jz not_found   }
                                  { ;               }
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$12/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$19/                   {  jz not_found   }
                                  { ;               }
       $03/$6E/$00/               {  add bp,[bp]    }
       $3B/$4E/$FD/               {  cmp cx,[bp]-3  }
       $74/$06/                   {  jz found       }
       $3B/$EB/                   {  cmp bp,bx      }
       $74/$0D/                   {  jz not_found   }
                                  { ;               }
       $EB/$92/                   {  jmp new_search }
                                  { ;               }
                                  { found:          }
       $8A/$46/$FF/               {  mov al,[bp]-1  }
       $0A/$C0/                   {  or al,al       }
       $74/$8B/                   {  jz new_search  }
       $3C/$08/                   {  cmp al,=8      }
       $74/$87/                   {  jz new_search  }
                                  { ;               }
                                  { not_found: ;z=search failed  }
       $CB                        {  ret (f)   ;nz=need to check keyword }
    );
end;


(*------------------------------------------
 *
 * new_getline - this ASM procedure checks for a line on the
 *               repleacement stack and uses it, if present.
 *               otherwise control is passed back to the
 *               normal get_line procedure inside turbo.
 *)

procedure _new_getline;
begin
   inline(
       $BF/$B6/$00/               {  mov di,00b6            }
       $B9/$7F/$00/               {  mov cx,007f            }

       {is there a line on the replacement stack?}
       $2E/$83/$3E/replevel/$00/  {  cmp word cs:replevel,0 }
       $75/$07/                   {  jnz need_pop           }

       $FF/$06/$B0/$05/           {  inc word [05b0]        }
       $31/$C0/                   {  xor ax,ax ;z=do old way}
       $CB/                       {  ret (f)                }


       {there is a line, pop it and pretend that it was just input}
                                  {need_pop:                }
       $1E/$56/                   {  push ds,si             }
       $2e/$8e/$1E/our_ds/        {  mov ds,cs:[our_ds]     }
       $E8/pop_replacement-*-2/   {  call pop_replacement   }
       $5E/$1F/                   {  pop si,ds              }
       $B8/$01/$00/               {  mov ax,1               }
       $09/$C0/                   {  or ax,ax  ;set nz      }
       $CB                        {  ret (f)   ;nz=line ready }
    );
end;


(*------------------------------------------
 *
 * install_turbo_patches
 *    install patches in turbo.com to speed-up
 *    operation or to facilitate tshell features
 *
 *)

procedure install_turbo_patches;
const

{pseudo-op constants}
   orgp     = -1;   {set origin(offset within turbo cseg}
   csegp    = -2;   {insert tshell cseg}
   searchp  = -3;   {insert tshell new_search offset}
   getlnp   = -4;   {insert tshell new_getline offset}
   endp     = -5;   {end of patch}

{patch table for turbo v3.01a}

(* v301a_patch: array[1..63] of integer = *)
   v301a_patch: array[1..10] of integer =

                (* patch in new symtab search *)
      (

                (* patch in new getline *)
       orgp,$914b,
       $9A,getlnp,csegp,          {  call (f) cseg:new_getln  }
       $74,$03,                   {  jz 9155            }
       $EB,$7B,                   {  jmp 91cf           }
(****************************************************************88
       orgp,$8e55,
       $8B,$2E,$98,$05,           {  mov bp,0598h       }
       $16,                       {  push ss            }
       $07,                       {  pop es             }
       $FC,                       {  cld                }
                                  { ;                   }
                                  { try_next:           }
       $8A,$EA,                   {  mov ch,dl          }
       $3B,$EB,                   {  cmp bp,bx          }
       $75,$02,                   {  jnz search_table   }
       $F9,                       {  stc                }
       $C3,                       {  ret (n)            }
                                  { ;                   }
                                  { search_table:       }
       $9A,searchp,csegp,         {  call (f) cseg:new_search  }
       $75,$02,                   {  jnz check_keyword  }
       $F9,                       {  stc                }
       $C3,                       {  ret (n)            }
                                  { ;                   }
                                  { check_keyword:      }
       $32,$ED,                   {  xor ch,ch          }
       $8B,$FD,                   {  mov di,bp          }
       $83,$EF,$03,               {  sub di,=03         }
       $2B,$F9,                   {  sub di,cx          }
       $BE,$03,$07,               {  mov si,=0703h      }
       $8B,$C1,                   {  mov ax,cx          }
       $F3,$A6,                   {  repz cmps (b)      }
       $91,                       {  xchg ax,cx         }
       $75,$DC,                   {  jnz try_next       }
       $8A,$46,$FF,               {  mov al,[bp]-1      }
       $83,$ED,$03,               {  sub bp,=03         }
       $2B,$E9,                   {  sub bp,cx          }
       $F8,                       {  clc                }
       $C3,                       {  ret (n)            }
************************************)
       endp);                     { ;                   }


{install a patch according to a patch table}
   procedure install_patch(var patch_table);
   var
      table:    array[1..maxint] of integer absolute patch_table;
      i:        integer;
      offset:   integer;

   begin
      offset := 0;
      i := 1;

      while table[i] <> endp do
      begin
         case table[i] of
         orgp: begin
                  INCR(i);
                  offset := table[i];
               end;

         csegp: begin
                  memw[turbo_cs:offset] := cseg;
                  offset := offset + 2;
               end;

         searchp: begin
                  memw[turbo_cs:offset] := ofs(_new_search)+7;
                  offset := offset + 2;    {skip 7 byte proc header}
               end;

         getlnp: begin
                  memw[turbo_cs:offset] := ofs(_new_getline)+7;
                  offset := offset + 2;
               end;

         else  begin
                  mem[turbo_cs:offset] := table[i];
                  INCR(offset);
               end;
         end;

         INCR(i);
      end;

   end;

#ifdef DEBUGGING
   #include <itoh.inc>
#endif

begin

#ifdef DEBUGGING
   writeln('cseg=',itoh(cseg),
           ' dseg=',itoh(dseg),
           ' turbo_cseg=',itoh(turbo_cs),
           ' search=',itoh(ofs(_new_search)),
           ' getln=', itoh(ofs(_new_getline)));
   delay(1000);
#endif

   case version of
      v301a:  install_patch(v301a_patch);
   end;

end;

