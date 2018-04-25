function out=fileread(filename)
%FILEREAD Return contents of file as a character vector.
%   TEXT = FILEREAD(FILENAME) returns the contents of the file FILENAME
%   as a character vector.
%
%   See also FREAD, TEXTSCAN, LOAD, READTABLE, UIIMPORT, IMPORTDATA

% Copyright 1984-2017 The MathWorks, Inc.

narginchk(1, 1);

filename = convertStringsToChars(filename);

if ~ischar(filename)
    error(message('MATLAB:fileread:filenameNotString')); 
end

if isempty(filename)
    error(message('MATLAB:fileread:emptyFilename')); 
end

[fid, msg] = fopen(filename);
if fid == -1
    error(message('MATLAB:fileread:cannotOpenFile', filename, msg));
end

try
    out = fread(fid,'*char')';
catch exception
    fclose(fid);
    throw(exception);
end

fclose(fid);
    