function info = impnginfo(filename)
%IMPNGNFO Information about a PNG file.
%   INFO = IMPNGINFO(FILENAME) returns a structure containing
%   information about the PNG file specified by the string
%   FILENAME.  
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2016 The MathWorks, Inc.

try
    info = pnginfoc(filename,false);
catch myException
    if strcmp(myException.identifier,'MATLAB:imagesci:png:libraryFailure')
        info = pnginfoc(filename,true);
        warning(message('MATLAB:imagesci:png:tooManyIDATsMetadata'));
    else
        error(message('MATLAB:imagesci:png:libraryFailure', myException.message));
    end
end

info.FileModDate = [];
info.FileSize = [];
s = dir(filename);
info.FileModDate = datestr(s.datenum);
info.FileSize = s.bytes;