function info = imtifinfo(filename)
%IMTIFINFO Information about a TIFF file.
%   INFO = IMTIFINFO(FILENAME) returns a structure containing
%   information about the TIFF file specified by the string
%   FILENAME.  If the TIFF file contains more than one image,
%   INFO will be a structure array; each element of INFO contains
%   information about one image in the TIFF file.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2015 The MathWorks, Inc.

info = matlab.io.internal.imagesci.imtifinfo(filename);
