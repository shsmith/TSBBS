:         External Protocol Upload Example
:
:         Uploads using external protocols are handled in a slightly
:         different manner, and multiple file transfers are not permitted.
:         At the time of the upload the caller is asked for the name of the
:         file to upload followed by the file area where the new upload
:         should be placed.  A caller may choose from any file area to which
:         he has upload rights as specified by his security level in
:         MAKEWILD.
:
:         The previous batch parameters of %1 through %3 are used for the
:         same purposes, but since only one file may be uploaded it is always
:         the %3 parameter.  The %4 parameter is assigned to the full drive
:         and path of the file area to receive the new file, and %5 is the
:         full drive, path plus the new filename.  As an example of these two
:         new parameters let's assume a caller is uploading a file named
:         NEWFILE.TXT to file area "E".  Let's further assume that file area
:         "E" is located in C:\WILDCAT\UPLOADS.  The parameters passed as %4
:         and %5 are as follows:
:
:         %4   C:\WILDCAT\UPLOADS
:         %5   C:\WILDCAT\UPLOADS\NEWFILE.TXT
:
:         Now let's look at a sample upload batch file and review its
:         contents.
:
          CD \WILDCAT\EP
:                        makes sure that we are in the external protocol
:                        directory
:
          HSLINK -P%2 -B%1 -U%5
:                        runs the HSLINK program with command
:                        line arguments as required.  in this case the -U
:                        parameter forces a single incoming file to match
:                        the filename given by the user prior to uploading.
:
