%FCLOSE Close file.
%   ST = FCLOSE(FID) closes the file associated with file identifier FID,
%   which is an integer value obtained from an earlier call to FOPEN.  
%   FCLOSE returns 0 if successful or -1 if not.  If FID does not represent
%   an open file, or if it is equal to 0 (standard input), 1 (standard
%   output), or 2 (standard error), FCLOSE throws an error.
%
%   ST = FCLOSE('all') closes all open files, except 0, 1 and 2.
%
%   See also FOPEN, FERROR, FPRINTF, FREAD, FREWIND, FSCANF, FTELL, FWRITE.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

