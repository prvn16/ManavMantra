function info = imjpginfo(filename,baseline_only)
%IMJPGINFO Information about a JPEG file.
%   INFO = IMJPGINFO(FILENAME) returns a structure containing
%   information about the JPEG file specified by the string
%   FILENAME.  
%
%   INFO = IMJPGINFO(FILENAME,BASELINE_ONLY=true) returns a structure with
%   only metadata as provided directly by the JPEG file.  Any Exif
%   or directory metadata is omitted.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 2
    baseline_only = false;
end

info = matlab.io.internal.imagesci.imjpginfo(filename,baseline_only);

