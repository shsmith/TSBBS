#include <uzhdr.h>
#include <uzcursor.h>


extern int zipfd;
extern int cw;
extern int cp;
extern int cy;
extern int cx;
extern char zipfn[13];
extern char filename[STRSIZ];
extern char ifilename[STRSIZ];
extern struct central_directory_file_header rec;
extern local_file_header lrec;
extern longint outpos; /* absolute position in outfile */
extern boolean zipeof;
extern boolean nomore;
extern boolean def_pat;
extern boolean vflag;
extern boolean cflag;
extern boolean find_file_fail;
extern boolean skip;
extern boolean header_present;
extern boolean expand_files;
boolean flist = 0;
boolean text = 1;
boolean text2 = 1;
boolean text3 = 1;
boolean verbose = 0;
boolean scroll = 0;
boolean names = 1;
boolean flag = 1;
extern struct display_save *start;
extern struct display_save *info;
int linenum;
char uoutbuf[max_linelen]; /* disp line buffer */

int binary_count; /* non-text chars so far */

static int c; /* local global */
char m_outbuf[hsize]; /* must be >= 8192 for look-back */

char default_pattern[STRSIZ]; /* psuedo wildcard: *.*  */

char pattern[STRSIZ];
int i = 0;
int num;
int why = 3;
int ex  = 0;
extern int count;
/*----------------------------------------------------------*/

void OutByte(c) 
/* output each string from archive to screen */ 
{ 
   m_outbuf[outpos % sizeof(m_outbuf)] = c; 
   outpos++;

   switch (c) {
   case 13:
      { 
         flushbuf(); 
         if (nomore) 
            skip_rest(); 
      }

      break; 

   case 10:
      ; 

      break; 

   case 26:
      { 
         flushbuf(); 
         skip_rest(); /* jump to nomore mode on ^z */


      }

      break; 

   case 8:
   case 9:
   case 32:
   case 33:
   case 34:
   case 35:
   case 36:
   case 37:
   case 38:
   case 39:
   case 40:
   case 41:
   case 42:
   case 43:
   case 44:
   case 45:
   case 46:
   case 47:
   case 48:
   case 49:
   case 50:
   case 51:
   case 52:
   case 53:
   case 54:
   case 55:
   case 56:
   case 57:
   case 58:
   case 59:
   case 60:
   case 61:
   case 62:
   case 63:
   case 64:
   case 65:
   case 66:
   case 67:
   case 68:
   case 69:
   case 70:
   case 71:
   case 72:
   case 73:
   case 74:
   case 75:
   case 76:
   case 77:
   case 78:
   case 79:
   case 80:
   case 81:
   case 82:
   case 83:
   case 84:
   case 85:
   case 86:
   case 87:
   case 88:
   case 89:
   case 90:
   case 91:
   case 92:
   case 93:
   case 94:
   case 95:
   case 96:
   case 97:
   case 98:
   case 99:
   case 100:
   case 101:
   case 102:
   case 103:
   case 104:
   case 105:
   case 106:
   case 107:
   case 108:
   case 109:
   case 110:
   case 111:
   case 112:
   case 113:
   case 114:
   case 115:
   case 116:
   case 117:
   case 118:
   case 119:
   case 120:
   case 121:
   case 122:
   case 123:
   case 124:
   case 125:
   case 126:
   case 127:
   case 128:
   case 129:
   case 130:
   case 131:
   case 132:
   case 133:
   case 134:
   case 135:
   case 136:
   case 137:
   case 138:
   case 139:
   case 140:
   case 141:
   case 142:
   case 143:
   case 144:
   case 145:
   case 146:
   case 147:
   case 148:
   case 149:
   case 150:
   case 151:
   case 152:
   case 153:
   case 154:
   case 155:
   case 156:
   case 157:
   case 158:
   case 159:
   case 160:
   case 161:
   case 162:
   case 163:
   case 164:
   case 165:
   case 166:
   case 167:
   case 168:
   case 169:
   case 170:
   case 171:
   case 172:
   case 173:
   case 174:
   case 175:
   case 176:
   case 177:
   case 178:
   case 179:
   case 180:
   case 181:
   case 182:
   case 183:
   case 184:
   case 185:
   case 186:
   case 187:
   case 188:
   case 189:
   case 190:
   case 191:
   case 192:
   case 193:
   case 194:
   case 195:
   case 196:
   case 197:
   case 198:
   case 199:
   case 200:
   case 201:
   case 202:
   case 203:
   case 204:
   case 205:
   case 206:
   case 207:
   case 208:
   case 209:
   case 210:
   case 211:
   case 212:
   case 213:
   case 214:
   case 215:
   case 216:
   case 217:
   case 218:
   case 219:
   case 220:
   case 221:
   case 222:
   case 223:
   case 224:
   case 225:
   case 226:
   case 227:
   case 228:
   case 229:
   case 230:
   case 231:
   case 232:
   case 233:
   case 234:
   case 235:
   case 236:
   case 237:
   case 238:
   case 239:
   case 240:
   case 241:
   case 242:
   case 243:
   case 244:
   case 245:
   case 246:
   case 247:
   case 248:
   case 249:
   case 250:
   case 251:
   case 252:
   case 253:
   case 254:
   case 255:
      { 
         if (strlen(uoutbuf) >= max_linelen) 
         { 
            flushbuf(); 
            if (lrec.compressed_size > 10) 
               not_text(); 
         }
         addchar(c); 
      }

      break; 

   default:
      { 
         if (binary_count < max_binary) 
            binary_count++; 
         else 
            if (lrec.compressed_size > 10) 
               not_text(); 
      }
      break; 
   }
   if(linenum >= pagelen){
      if(!scroll){
         int c;
         linenum = 1;
         pos_prompt(ifilename,"More: <space bar>=yes, (N)o, (C)ontinuous?");
         /*fprintf(stdout,"\033p\033f More: <space bar>=yes, (N)o, (C)ontinuous?\033q\033e "); */
         fflush(stdout);
         do{
            pos_cursor();
            c = toupper(Cconin());
            if(c == 67) 
            { 
               scroll = 1; /* scroll to end of file  */

               clr_scrn();
            }
            if(c == 78) 
            { 
               nomore = 1; 
               def_pat = 1;
            }
            if(c == 32)
            {
               clr_view(); 
            }
         }while(c != 32 && c != 78 && c != 67);
      }
   }

}

/*---------------------------------------------------------------*/


struct display_save *find_names()
{
   struct display_save *info; 

   lseek(zipfd,0L,SEEK_SET); 
   info = start;
   while(info){
      if(verbose)
         Verbose(info);
      else 
         Action(info);
      if(info->next == NULL)
         info = start;
      else 
         info = info->next;
   }
}


void Action(info)
struct display_save *info;
{
   char action[STRSIZ];
   char listname[STRSIZ];
   long o;
   int bitflag;
   long offset = (info->total_offset + info->filename_length +
      info->extra_field_length + sizeof(lrec) +4L);
   int compression = info->Compression_method;

   lrec.version_needed_to_extract = info->version_needed_to_extract;
   lrec.general_purpose_bit_flag = info->general_purpose_bit_flag;
   lrec.compression_method = info-> Compression_method;
   lrec.last_mod_file_time = info->mod_file_time;
   lrec.last_mod_file_date = info->mod_file_date;
   lrec.crc32 = info->CRC32;
   lrec.compressed_size = info->Compressed_size;
   lrec.uncompressed_size = info->unCompressed_size;
   lrec.filename_length = info->filename_length;
   lrec.extra_field_length = info->extra_field_length;

   bitflag = info->general_purpose_bit_flag;
   strcpy(action,"S");
   strcpy(listname,info->Nameptr);

   while (info){
      scroll = 0;
      nomore = 0;
      if(flist){
         count = 0;
         fprintf(stdout,"\033f\033E");
         pos_one();
         fprintf(stdout,"                          \033pZipfile: %s\033q",zipfn);
         pos_two();
         fprintf(stdout,"                              \033psorted by name\033q");
         if(!names)
            List_head();
         restore_flist();
         fflush(stdout);
         ex =  0;
         why = 3;
      }
      if(text)
        {
         pos_prompt(info->Nameptr,"(N)ext (V)iew (R)elist/(O)ne (Q)uit");
         /*fprintf(stdout,"%-13s \033p=> (N)ext (V)iew (R)elist/(O)ne (Q)uit\033q\033e ",
                    info->Nameptr);*/
        }
      else
        {
          pos_twentyfour();
          fprintf(stdout,"%-13s",info->Nameptr);
        }
      verbose_cursor();                    
      fflush(stdout);
      do{
         *action = Bconin(2);
         strupr(action);
         switch (*action) {

         case 'N':
            {  
               text = 0;
               text3 = 1;
               if(text2)
                 {
                   pos_show_user();
                   fprintf(stdout,"%-13s => [Skipped] ",listname);
                 }
               else
                 {
                   pos_twentythree();
                   fprintf(stdout,"%-13s",listname);
                 }       
               find_file_fail = 1;
               flist = 0;
               skip = 1;
               text2 = 0;
               return;
            }

            break; 

         case 'O':
            {
               text = 1;
               verbose = 1;
               return;
               verbose = 0;
            }
            break;

         case 'R':
            { 
               names = 0;
               text = 1;
               text2 =1;
               text3 = 1;
               /*clr_cmdline();*/
               clr_view();
               count = 0;
               List_head();
               restore_flist();
               names = 1;
               ex =  0;
               why = 3;
               /*clr_cmdline();*/
               verbose_cursor();
               fprintf(stdout,"\033K");
               fprintf(stdout,"\033p=>press any key to continue \033q\033e ");
               verbose_cursor();
               fflush(stdout);
               Bconin(2);
               /*clr_cmdline();*/
            }

            break;

         case 'V':
            { 
               skip = 0;
               find_file_fail = 1;
               text = 1;
               text2 = 1;
               if(text3)
                 {
                   pos_show_user();
                   fprintf(stdout,"\033f%-13s => [Viewing] ",listname);
                 }
               else
                 {
                   pos_twentythree();
                   fprintf(stdout,"\033f%-13s",listname);
                 }      
               pos_two();
               def_pat = 0;
               strcpy(ifilename,info->Nameptr);
               lrec.general_purpose_bit_flag = bitflag;
               lrec.compression_method = compression;
               o = lseek(zipfd,offset,SEEK_CUR);
               if(o < 0){ 
                  abort("Can not position to file record!");
               }
               extract_member(); 
               o = lseek(zipfd,0L,SEEK_SET);
               if(o < 0) 
                  abort("Can not position to file beginning!");
               def_pat = 1;
               flist = 1;
               nomore = 0;
               header_present = FALSE; 
               pos_prompt(ifilename,"press any key to continue");
               /*fprintf(stdout," \033p press any key to continue \033q\033e ");*/
               fprintf(stdout,"\033f\033Y%c%c\033K", 23 + ' ', 14 + ' ');
               fprintf(stdout,"\033f=> [View complete] \033e\07");
               fflush(stdout);
               Bconin(2);
               strcpy(ifilename, default_pattern);
               ex =  0;
               why = 3;
               return;
            }

            break; 

         case 'Q':
            { 
               fprintf(stdout,"\033f\033Y%c%c\033K\07", 24 + ' ', 54 + ' ');
               fprintf(stdout,"[Quit]"); 
               lseek(zipfd, 0L, SEEK_END); 
               close(zipfd);
               prg_exit(0);
            }

            break; 
         }
      }
      while(*action != 'V' && *action != 'N' 
         && *action != 'Q' && *action != 'R' && *action != 'O');
   }
}


/* ---------------------------------------------------------- */ 


void select_pattern() 
{ 
   char cmdbuf[STRSIZ];
   struct display_save *info; 
   strcpy(default_pattern, " *.* "); 
   while(TRUE){ 
      pos_prompt(zipfn,"View file?: (No)/(Quit)/<name> or <cr>= list"); 
      /*fprintf(stdout,"%-13s: \033f\033pView file?: (No)/(Quit)/<name> or %s%s?\033q \033e",zipfn,enter_eq,default_pattern);*/ 
      pos_cursor();
      fflush(stdout);
      strupr(gets(cmdbuf));
      clr_scrn();
      pos_one();
      fprintf(stdout,"                          \033pZipfile: %s\033q",zipfn);
      fflush(stdout);
      /*fprintf(stdout,"\033f\033A\033K");*/
      if((strcmp(cmdbuf,"QUIT") == 0)||(strcmp(cmdbuf,"NO") == 0)){
         abort(" ");
      }
      if (*cmdbuf == NULL){ 
         strcpy(cmdbuf, default_pattern); 
         def_pat = 1;
         pos_two();
         fprintf(stdout,"                              \033psorted by name\033q");
         restore_flist();
         fflush(stdout);
      }
      vflag = 0;
      find_file_fail = 0;
      cflag = 1;
      lseek(zipfd,0L,SEEK_SET);
      strupr(strncpy(ifilename,cmdbuf,(strlen(cmdbuf)))); 
      process_headers(); 
      if(!def_pat){
         pos_show_user();
         fprintf(stdout,"\033fCould not find : %s in Zipfile: %s",ifilename,zipfn); 
      }
   }
   close(zipfd); 
}



/* ---------------------------------------------------------- */ 


void view_zipfile(fullname)
char *fullname; 
{ 
   if (expand_files){ 
      select_pattern(); 
   }
   else 
   { 
      find_file_fail = 0;
      strcpy(pattern, "*.*"); 
      fprintf(stdout,"\033f");
      ListZipFile(fullname,pattern);
      fprintf(stdout,"\033e");
   }


}




/* ---------------------------------------------------------- */ 


void process_zipfile(fullname)
char *fullname; 
{ 

   int c;
   linenum = 1;
   expand_files = 0;
   vflag = 1;
   cflag = 0; 
   view_zipfile(fullname); 
   linenum++;
   pos_prompt(zipfn,"View text files?:<space bar>= yes or (N)o?");
   /*fprintf(stdout,"%-13s: \033f\033pView text files?:<space bar>= yes or (N)o?\033q\033e\033K ",zipfn);*/ 
   fflush(stdout);
   do{ /* process text viewing if desired */
      pos_cursor();
      c = toupper(Cconin());
      if ((c == 78) || (c == 110)) 
      { 
         abort(" ");
      }

      if (c == 32) 
      { 
         expand_files = TRUE;
         view_zipfile(); 
      }
   }
   while(c != 78 && c != 32);
}

/* ------------------------------------------------------------ */ 

void flushbuf()
{
   uoutbuf[i] = '\0';
   if(!scroll){
      display_screen(uoutbuf,linenum);
   }
   else{
      fprintf(stdout,"%s",uoutbuf);
      fprintf(stdout,"\n");
   }
   linenum++;
   i = 0;
}


void addchar(n)
int n;
{
   (uoutbuf[i]) = n;
   i++; 
}


void not_text()
{
   pos_show_user();
   fprintf(stdout,"%-13s => *This is not a text file! ",filename); 
   skip_rest();
}

int strpos(symbol,string)
register char *string;
register char symbol;
/*
 *	Return the index of the first occurance of <symbol> in <string>.
 *	-1 is returned if <symbol> is not found.
 */
{
   register int i = 0;

   do {
      if(*string == symbol)
         return(i);
      ++i;
   }
   while(*string++);
   return(-1);
}

/*-----------------------------------------------------------*/

restore_flist()
{
   register int t;
   struct display_save *info;
   info = start;
   pos_five();
   while(info){
      if(!names)
         display(info);
      else 
         display_names(info);
      info = info->next;
   }
}

display(info)
struct display_save *info;
{
   fprintf(stdout,"%-14s%8ld  %s   %2d%%  %8ld  %02d %s %2d  %02d:%02d   %08lX\n",
   info->Nameptr,
   info->unCompressed_size, 
   info->Comp_type,
   info->stowageFactor,
   info->Compressed_size,
   info->day,
   info->month,
   info->year,
   info->hour,
   info->minutes, 
   info->CRC32);
   fflush(stdout);
   count++;
   if(count == 18){
      int i;
      /*pos_prompt();*/
      fprintf(stdout,"\033f\033Y%c%c\033ppress any key for more files\033q ",24 + ' ', 15 + ' '); 
      fflush(stdout);
      Bconin(2);
      clr_verbose();
      pos_six();
      count = 0;
   }

}


display_names(info)
struct display_save *info;
{
   if(ex == 75){
      why += 1;
      ex = 0;
   }     
   show_names(info->Nameptr,why,ex);
   ex += 15;
   /*fprintf(stdout,"\033f%-16s",info->Nameptr);
     fflush(stdout);
   */
}

void Verbose(info)
struct display_save *info;
{
   char action[STRSIZ];
   if(text3)
   {
     pos_prompt(info->Nameptr," (N)ext (V)iew (M)ain menu");
     /*fprintf(stdout,"%-13s \033p=> (N)ext (V)iew (M)ain menu\033\q\033e ",info->Nameptr);*/
   }
   else
   {
     pos_twentyfour();
     fprintf(stdout,"%-13s",info->Nameptr);
     verbose_cursor();
   }   
   fflush(stdout);
   text3 = 0;
   do{
      *action = Bconin(2);
      strupr(action);
      switch (*action) {

      case 'M':
         { 
            flag = 1;
            text = 1;
            text2 = 1;
            text3 = 1;
            flist = 0; 
            verbose = 0;
            return;
         }
         break;
 
         case 'N':
            {  
               if(text2)
               {
                 pos_show_user();
                 fprintf(stdout,"%-13s => [Skipped] ",info->Nameptr);
               }
               else
               {
                 pos_twentythree();
                 fprintf(stdout,"%-13s",info->Nameptr);
                 verbose_cursor();
               }
               text = 1;
               text2 = 0;   
               /*return;*/
            }
         break;

      case 'V':
         { 
            if(flag){
               List_head();
               fflush(stdout);
            }
            else{
               pos_twentytwo();
            }   
            fprintf(stdout,"\033q\033f%-14s%8ld  %s   %2d%%  %8ld  %02d %s %2d  %02d:%02d   %08lX   ",
            info->Nameptr,
            info->unCompressed_size, 
            info->Comp_type,
            info->stowageFactor,
            info->Compressed_size,
            info->day,
            info->month,
            info->year,
            info->hour,
            info->minutes, 
            info->CRC32);
            flag = 0;
            fflush(stdout);
            if(text)
              {
                pos_show_user();
                fprintf(stdout,"\033f%-13s => [Viewing] ",info->Nameptr);
                verbose_cursor();
              }
            else
              {
                pos_twentythree();
                fprintf(stdout,"\033f%-13s",info->Nameptr);
                verbose_cursor();
              }    
            fflush(stdout);
            text2 = 1;
            text = 0;
         }
         break; 
      }
   }
   while(*action != 'N' && *action != 'V' && *action != 'M');
}
