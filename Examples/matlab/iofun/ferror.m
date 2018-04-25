%FERROR Inquire about file error status. 
%   MESSAGE = FERROR(FID) returns the error message for the
%   most recent file I/O operation associated with the specified file. 
%   FID is an integer valued file identifier obtained from FOPEN.  It may 
%   also be 0 for standard input, 1 for standard output or 2 for standard 
%   error.
%
%   [MESSAGE,ERRNUM] = FERROR(FID) returns the error number as well.
%
%   If the most recent I/O operation was successful, MESSAGE is empty
%   and ERRNUM is 0.  A nonzero ERRNUM indicates that an error
%   occurred.  Positive values of ERRNUM match those returned by the C
%   library on your platform.  Negative values are MATLAB-specific.
%
%   [...] = FERROR(FID,'clear') also clears the error indicator for
%   the specified file.  Succeeding calls to FERROR with the same FID, and
%   no intervening calls to other file I/O functions using the same FID,
%   will behave as if the most recent I/O operation was successful.
%
%   See also FCLOSE, FEOF, FOPEN, FPRINTF, FREAD, FSCANF, FSEEK, FTELL, 
%            FWRITE.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   Built-in function.

