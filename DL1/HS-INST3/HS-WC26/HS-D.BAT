:         External Protocol Download Example
:
:         The batch files controlling both downloads and uploads must be
:         located in the external protocol directory as specified in
:         MAKEWILD.
:
          CD \WILDCAT\EP
:                                  makes sure that we are in the external
:                                  protocol directory.
:
          HSLINK -P%2 -B%1 %3 %4 %5 %6 %7 %8 %9
:                                  starts the HSLINK program and tells it
:                                  which port, speed and the filenames
:                                  to use
:
          IF ERRORLEVEL 1 COPY ALL.OK TRANSFER.BAD
:                                  test for standard "aborted"
:                                  errorlevel to indicate bad transfer
