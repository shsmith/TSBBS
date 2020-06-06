*** unzipbsd.c	Wed May 24 10:21:40 1989
--- ../unzipbsd.c	Tue May 30 09:32:08 1989
***************
*** 17,23 ****
   *
   */
  
! #define VERSION  "UnZip:  Zipfile Extract v1.2 of 03-15-89;  (C) 1989 Samuel H. Smith"
  
  typedef unsigned char byte;	/* code assumes UNSIGNED bytes */
  typedef long longint;
--- 17,24 ----
   *
   */
  
! #include "patchlevel.h"
! #define VERSION  "1.2"
  
  typedef unsigned char byte;	/* code assumes UNSIGNED bytes */
  typedef long longint;
***************
*** 1048,1053 ****
--- 1049,1064 ----
  
  	if (debugging) {
  	printf("\n\nProcess END_CENTRAL directory header.\n");
+ 	printf("This disk       : %d\n",rec.number_this_disk);
+ 	printf("Starting disk	: %d\n",
+ 		rec.number_disk_with_start_central_directory);
+ 	printf("Total this disk	: %d\n",
+ 		rec.total_entries_central_dir_on_this_disk);
+ 	printf("Total entries	: %d\n",rec.total_entries_central_dir);
+ 	printf("Central dir size: %d\n",rec.size_central_directory);
+ 	printf("Offset to dir   : %d\n",rec.offset_start_central_directory);
+ 	printf("Comment size    : %d\n",rec.zipfile_comment_length);
+ 	printf("Comment         : %s\n",comment); 
  	}
  }
  
***************
*** 1084,1095 ****
  		{
  			process_end_central_dir(); 
  			if (test_zip) {
! 			if (numbad < 1)
  				printf("No errors detected\n");
! 			else
! 			if (numbad == 1)
  				printf("One error detected\n");
! 			else
  				printf("%d errors detected\n",numbad);
  			}
  			if (list_zip) {
--- 1095,1106 ----
  		{
  			process_end_central_dir(); 
  			if (test_zip) {
! 			 if (numbad < 1)
  				printf("No errors detected\n");
! 			 else
! 			 if (numbad == 1)
  				printf("One error detected\n");
! 			 else
  				printf("%d errors detected\n",numbad);
  			}
  			if (list_zip) {
***************
*** 1102,1108 ****
  					Total_bytes);
  			else
  				printf("---\n");
- 
  			 } else {
  			 printf("        ====  ========\n");
  			 printf("Total:  %4d  %8d\n",
--- 1113,1118 ----
***************
*** 1109,1114 ****
--- 1119,1126 ----
  				Total_files,Total_bytes);
  			 }
  			}
+ 			if (strlen(comment))
+ 				printf("%s\n",comment); 
  			return;
  		} 
  	else 
***************
*** 1204,1210 ****
  
  long_help()
  {
! printf("\n%s\n",VERSION);
  printf("Courtesy of:  S.H.Smith and The Tool Shop BBS, (602) 279-2673.");
  printf("\n\n");
  printf("UNIX mods by: Michael Enkelis\n\n");
--- 1216,1223 ----
  
  long_help()
  {
! printf("\nUnZip:  Zipfile Extract Version:%s Patchlevel:%d",VERSION,PATCH);
! printf(";  (C) 1989 Samuel H. Smith\n");
  printf("Courtesy of:  S.H.Smith and The Tool Shop BBS, (602) 279-2673.");
  printf("\n\n");
  printf("UNIX mods by: Michael Enkelis\n\n");
***************
*** 1221,1227 ****
  printf("PROFITS, LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES\n");
  printf("ARISING OUT OF YOUR USE OR INABILITY TO USE THE PROGRAM, OR FOR ANY\n");
  printf("CLAIM BY ANY OTHER PARTY.\n\n");
! printf("Usage:  UnZip FILE[.zip]\n");
  exit(1);
  }
  
--- 1234,1240 ----
  printf("PROFITS, LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES\n");
  printf("ARISING OUT OF YOUR USE OR INABILITY TO USE THE PROGRAM, OR FOR ANY\n");
  printf("CLAIM BY ANY OTHER PARTY.\n\n");
! short_help();
  exit(1);
  }
  
