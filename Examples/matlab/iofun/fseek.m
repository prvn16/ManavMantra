%FSEEK Set file position indicator. 
%   STATUS = FSEEK(FID, OFFSET, ORIGIN) repositions the file position
%   indicator in the file associated with the given FID.  FSEEK sets the 
%   position indicator to the byte with the specified OFFSET relative to 
%   ORIGIN.
%
%   FID is an integer file identifier obtained from FOPEN.
%
%   OFFSET values are interpreted as follows:
%       >= 0    Move position indicator OFFSET bytes after ORIGIN.
%       < 0    Move position indicator OFFSET bytes before ORIGIN.
%
%   ORIGIN values are interpreted as follows:
%       'bof' or -1   Beginning of file
%       'cof' or  0   Current position in file
%       'eof' or  1   End of file
%
%   STATUS is 0 on success and -1 on failure.  If an error occurs, use
%   FERROR to get more information.
%
%   Example:
%
%       fseek(fid,0,-1)
%
%   "rewinds" the file.
%
%   See also FERROR, FOPEN, FPRINTF, FREAD, FREWIND, FSCANF, FSEEK, FTELL, 
%            FWRITE.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   Built-in function.

