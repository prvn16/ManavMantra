function tline = fgetl(fid)
%FGETL Read line from file, discard newline character.
%   TLINE = FGETL(FID) returns the next line of a file associated with file
%   identifier FID as a MATLAB character vector. The line terminator is NOT included.
%   Use FGETS to get the next line with the line terminator INCLUDED. If just an
%   end-of-file is encountered, -1 is returned.
%
%   If an error occurs while reading from the file, FGETL returns an empty character
%   vector. Use FERROR to determine the nature of the error.
%
%   MATLAB reads characters using the encoding scheme associated with the file. See
%   FOPEN for more information.
%
%   FGETL is intended for use with files that contain newline characters. Given a
%   file with no newline characters, FGETL may take a long time to execute.
%
%   Example
%       fid=fopen('fgetl.m');
%       while 1
%           tline = fgetl(fid);
%           if ~ischar(tline), break, end
%           disp(tline)
%       end
%       fclose(fid);
%
%   See also FGETS, FOPEN, FERROR.

%   Copyright 1984-2016 The MathWorks, Inc.

narginchk(1,1)

[tline,lt] = fgets(fid);
tline = tline(1:end-length(lt));
if isempty(tline)
    tline = '';
end

end
