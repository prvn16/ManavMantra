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

fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));

% Check that it is a valid tiff file.
sig = fread(fid, 4, 'uint8')';
assert ( (isequal(sig, [73 73 42 0]) || ...
    isequal(sig, [77 77 0 42]) || ...
    isequal(sig, [73 73 43 0]) || ...
    isequal(sig, [77 77 0 43])), ...
    message('MATLAB:imagesci:imfinfo:badFormat', filename, 'TIF'))

fclose(fid);

% 4th argument: count of zero means "retrieve all IFDs".
raw_tags = matlab.io.internal.imagesci.tifftagsread(filename,0,0,0);
if numel(raw_tags) == 0
    error(message('MATLAB:imagesci:imtifinfo:noImages'));
end
info = matlab.io.internal.imagesci.tifftagsprocess ( raw_tags );
