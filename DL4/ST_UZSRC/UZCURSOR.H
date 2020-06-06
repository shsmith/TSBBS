    /* this header contains cursor positioning info */


/*
	vt-52 escape codes

	<esc> A  	cursor up
	<esc> B  	cursor down
	<esc> C		Cursor forward
	<esc> D		Cursor backward
	<esc> E		Clear and home the cursor
	<esc> H		Home cursor
	<esc> I		cursor up (note: if cursor is at top line the text
					will scroll down
	<esc> J		Erase to end of page
	<esc> K		Erase to end of line
	<esc> L		Insert line
	<esc> M		Delete Line
	<esc> Yrc	Places the cursor at the row ``r'' and the column ``c''.  The
				values must have the space character added to their values

	<esc> == \033

	<esc> b#	select character color   (note: character is lower case)
	<esc> c#	select background color
	<esc> d		clear from top to cursor
	<esc> e		cursor visible
	<esc> f		cursor invisible
	<esc> j		save cursor position
	<esc> k		restore cursor position (note: from <esc> j save)
	<esc> l		clear line and put cursor at start of line
	<esc> o		clear to start of line
	<esc> p		inverse on
	<esc> q		inverse off
	<esc> v		overflow on  (Text wrap on)
	<esc> w		overflow off (Text wrap off)
*/



/* these functions reposions the cursor prior to feedback to the user */
#define pos_show_user()     fprintf(stdout,"\033f\033Y%c%c\033K", cy + ' ', cx + ' ');fflush(stdout);
#define pos_prompt(file,string){fprintf(stdout,"\033f\033Y%c%c%-13s =\033p>%s \033q\033K", cp + ' ', cx + ' ',file,string);\
                                fprintf(stdout,"\033Y%c%c\033e", 24 + ' ', 14 + ' ');fflush(stdout);}
#define pos_abort(file,string) {fprintf(stdout,"\033f\033Y%c%c%-13s =\033p>%s\033q\033K", cp + ' ', cx + ' ',file,string);\
                                fflush(stdout);}

#define clr_scrn()          {fprintf(stdout,"\033f\033E"); fflush(stdout);}
#define clr_from_cup()      {fprintf(stdout,"\033f\033A\033A\033d\033H"); fflush(stdout);}
#define pos_home()          fprintf(stdout,"\033f\033Y%c%c\033l", 0 + ' ', 0 + ' ');
#define pos_one()           fprintf(stdout,"\033f\033Y%c%c\033l", 0 + ' ', 0 + ' ');
#define pos_two()           fprintf(stdout,"\033f\033Y%c%c\033l", 1 + ' ', 0 + ' ');
#define pos_three()         fprintf(stdout,"\033f\033Y%c%c\033l", 2 + ' ', 0 + ' ');
#define pos_four()          fprintf(stdout,"\033f\033Y%c%c\033l", 3 + ' ', 0 + ' ');
#define pos_five()          fprintf(stdout,"\033f\033Y%c%c\033l", 4 + ' ', 0 + ' ');
#define pos_six()           fprintf(stdout,"\033f\033Y%c%c\033l", 5 + ' ', 0 + ' ');
#define pos_seven()         fprintf(stdout,"\033f\033Y%c%c\033l", 6 + ' ', 0 + ' ');
#define pos_twenty()        fprintf(stdout,"\033f\033Y%c%c\033l", 19 + ' ', 0 + ' ');
#define pos_twentytwo()     fprintf(stdout,"\033f\033Y%c%c\033l", 21 + ' ', 0 + ' ');
#define pos_twentythree()   fprintf(stdout,"\033f\033Y%c%c", 23 + ' ', 0 + ' ');
#define clr_twentythree()   fprintf(stdout,"\033f\033Y%c%c\033l", 23 + ' ', 0 + ' ');
#define pos_twentyfour()    fprintf(stdout,"\033f\033Y%c%c", 24 + ' ', 0 + ' ');
#define clr_cmdline()       fprintf(stdout,"\033f\033Y%c%c\033l", 24 + ' ', 0 + ' ');
#define verbose_cursor()    fprintf(stdout,"\033f\033Y%c%c\033e", 24 + ' ', 14 + ' ');

#define pos_cursor()        {fprintf(stdout,"\033f\033Y%c%c\033K\033e", 24 + ' ', 63 + ' ');}
#define clr_view()          for(i = 22; i > 1; i--){fprintf(stdout,"\033f\033Y%c%c\033l", i + ' ', 0 + ' ');}fflush(stdout);
#define clr_verbose()       for(i = 22; i > 5; i--){fprintf(stdout,"\033f\033Y%c%c\033l", i + ' ', 0 + ' ');}fflush(stdout);
#define clr_display()       for(i = 22; i > 2; i--){fprintf(stdout,"\033f\033Y%c%c\033l", i + ' ', 0 + ' ');}fflush(stdout);
#define pos_zipfn()         fprintf(stdout,"\033f\033Y%c%c\033K", 1 + ' ', 25 + ' ');fflush(stdout);
#define display_screen(line,num) {fprintf(stdout,"\033f\033Y%c%c\033l", num + ' ', 0 + ' ');\
                                     fprintf(stdout,"%s",line);fflush(stdout);} 
#define display_line(string,filename,num) {fprintf(stdout,"\033f\033Y%c%c", num + ' ', 0 + ' ');\
                                     fprintf(stdout,"%s%s\033B",string,filename);fprintf(stdout,"\033j");fflush(stdout);} 
#define display_crc(string,val,string2,num) {fprintf(stdout,"\033f\033Y%c%c", num + ' ', 27 + ' ');\
                                             fprintf(stdout,"%s %08lx %s\033B",string,val,string2);fprintf(stdout,"\033j");fflush(stdout);} 
#define display_badcrc(string,val,string2,val2,num) {fprintf(stdout,"\07\033f\033Y%c%c", num + ' ', 27 + ' ');\
                                             fprintf(stdout,"%s %08lx %s %08lx\033B",string,val,string2,val2);fprintf(stdout,"\033j");fflush(stdout);} 
#define rem_pos()                    fprintf(stdout,"\033j");fflush(stdout);
#define restore_pos()                fprintf(stdout,"\033k");fflush(stdout);
#define cursor_off()                 fprintf(stdout,"\033f");fflush(stdout); 
#define cursor_on()                  fprintf(stdout,"\033e");fflush(stdout); 
#define show_names(name,why,ex) {fprintf(stdout,"\033f\033Y%c%c", why + ' ', ex + ' ');\
                                     fprintf(stdout,"%s%s",name);fflush(stdout);} 
#define pos_exit()       fprintf(stdout,"\033f\033Y%c%c\033K", 24 + ' ',66 + ' ');fflush(stdout); /* clears the command line */
                               
#define print_count(file,outcount,size){fprintf(stdout,"\033f\033Y%c%c%-13s =\033p>%12ld \033qtarget size=>%12ld\033K",\
                                     24 + ' ', 0 + ' ',file,outcount,size);fflush(stdout);}
                                          
