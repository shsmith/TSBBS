
(*
 * outline - a simple "outline" oriented document generator
 *
 * This program allows you to make an outline of the sections in
 * a document, and then move around in the heirarchy to edit
 * your document.   You can move whole sections of the document
 * by simply moving the section title!
 *
 * Author:  Samuel H. Smith,  11-Jan-86
 *
 *
 * Release history:
 *
 *   date      version             notes
 * ---------   -------    ------------------------
 *
 * 11-jan-86     1.0      Initial release to public domain
 *
 * 12-jan-86     1.1      Added include files in section description.
 *                        Added file directory in select-file.
 *                        Speeded up some screens.  Cleaned up
 *                        user interface and error handling.
 *                        Added paragraph reformat in printing.
 *
 * 16-Jan-86     1.2      Added estimate calculation.  Added the
 *                        ability to load old format OLF files.
 *                        made function keys more consistant.
 *
 * 20-Jan-86     1.3      Added search paths for option file and load-files.
 *                        Fixed bug in 0 estimates at top level.  Changed
 *                        printout estimate to match display format.  Moves
 *                        print procedures to a seperate include file.
 *
 * 06-Feb-86              Fixed a bug in reformat line that caused some lines
 *                        to be truncated.
 *
 * 28-Feb-86     1.4      Made print handlers remove underlining and extra
 *                        blank lines on empty subsections.  Removed summary
 *                        from beginning of detail printout.  Added graphic
 *                        picture include files.  Changed "print" directory
 *                        to include *.PRN,*.SUM only.
 *
 * 29-Apr-86     1.5      Added tree print format.  Changes all printing to
 *                        use the F4 key.   Added contents/outline format.
 *                        Added keyword index format.  Fixed bugs related
 *                        to moving sections.
 *
 * 14-Jul-86     1.6      Added -mono and -slowdisplay command line options.
 *
 *)


{$C-     Do not check for ^C}
{$D-     Buffer outputs for devices}
{$R-     Disable subscript and variable rangechecks}
{$V-     Enable variable length string parameters}


program outline_processor (input, output, optionfd, savefd, printfd);

const
   version = '        Document Outline Processor          v1.6 (14-Jul-86 SHS)';


{$I \shs\tools\regpack.inc    Utility register package data type}
{$I outdata.inc               Outline data declarations}
{$I \shs\tools\popup.inc      Utility library for pop-up windows and quick displays}
{$i \shs\tools\gettime.inc    Utility to get time of day from DOS}
{$i \shs\tools\givetime.inc   Utility to give up time in doubledos}
{$I outmisc.inc               Outline utility procedures}
{$I \shs\tools\getfiles.inc   Utility library to get file directories}
{$I \shs\tools\locfile.inc    Utility library to locate files with search paths}
{$I outfilex.inc              Outline File Load/Save procedures}
{$I outindex.inc              Outline Print index procedures}
{$I outtree.inc               Outline Print tree procedures}
{$I outgraph.inc              Outline Print graphics procedures}
{$I outform.inc               Outline Print reformat text procedures}
{$I outsect.inc               Outline Print sections procedures}
{$I outprint.inc              Outline Print procedures}
{$I outedit.inc               Outline Editing procedures}
{$I outinit.inc               Outline initialization}


(*
 * main program - give main menu and select main handler procedures
 *
 *)

var
   key:  char;

begin {main}

   initialize;

   repeat
      normvideo;
      clrscr;
      lowvideo; displn(version); writeln;
      normvideo;
      displn('                       M A I N     M E N U');
      writeln;
      displn('            Key                 Action'); lowvideo;
      displn('           อออออ    อออออออออออออออออออออออออออออ');
      writeln;
      displn('             F1     Work on the current outline');
      writeln;
      displn('             F2     Retrieve an outline from disk');
      writeln;
      displn('             F3     Save the outline on disk');
      writeln;
      displn('             F4     Print the document');
      writeln;
      displn('             F5     Change the working directory');
      writeln;
      displn('             F6     Delete the current outline from memory');
      writeln;
      disp  ('             F10    Exit to DOS');

      gotoxy(74,25);
      write(maxavail shr 6,'k');
      if not saved then
         disp (' *');

      normvideo;
      gotoxy(1,24);
      write  ('        Select function: ');

      repeat
         key := getkey;
         if not (key in [F1..F6,F10,PGDN]) then
            write(^G);

      until key in [F1..F10,PGDN];
      clrscr;

      case key of

         PGDN,
         F1:   edit_section(document,docfile);

         F2:   load_document;

         F3:   save_document;

         F4:   print_document(document,1);

         F5:   change_dir;

         F6:   begin
                  save_if_needed;
                  if delsec <> nil then
                     delete_section(delsec);
                  delsec := nil;
                  delete_section(document);
                  document := new_section;
               end;

         F10:  ;

         else  write(^G);
      end;

   until key = F10;

   save_if_needed;

   clrscr;
   displn('Thank you for using OUTLINE!');

end.

