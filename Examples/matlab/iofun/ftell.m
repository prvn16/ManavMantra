%FTELL Get file position indicator. 
%   POSITION = FTELL(FID) returns the location of the file position
%   indicator in the specified file.  Position is indicated in bytes
%   from the beginning of the file.  If -1 is returned, it indicates
%   that the query was unsuccessful. Use FERROR to determine the nature
%   of the error.
%
%   FID is an integer file identifier obtained from FOPEN.
%
%   See also FERROR, FOPEN, FPRINTF, FREAD, FREWIND, FSCANF, FSEEK, FWRITE.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.

