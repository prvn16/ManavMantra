function frewind(fid)
%FREWIND Rewind file.
%   FREWIND(FID) sets the file position indicator to the beginning of
%   the file associated with file identifier FID.
%
%   WARNING: Rewinding an FID associated with a tape device may not work.
%            In such cases, no error message is generated.
%
%   See also FOPEN, FPRINTF, FREAD, FSCANF, FSEEK, FTELL, FWRITE.

%   Martin Knapp-Cordes, 1-30-92, 7-13-92, 11-2-92
%   Copyright 1984-2011 The MathWorks, Inc.

narginchk(1, 1);

status = fseek(fid, 0, -1);
if (status == -1)
    error (message('MATLAB:frewind:Failed'))
end
