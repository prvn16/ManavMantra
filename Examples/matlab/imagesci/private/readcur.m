function [X, map, mask] = readcur(filename, index)
%READCUR Read cursor from a Windows CUR file
%   [X,MAP] = READCUR(FILENAME) reads image data from a CUR file
%   containing one or more Microsoft Windows cursor resources.  X
%   is a 2-D uint8 array.  MAP is an M-by-3 MATLAB colormap.  If
%   FILENAME contains more than one cursor resource, the first will
%   be read.
%
%   [X,MAP] = READCUR(FILENAME,INDEX) reads the cursor in position
%   INDEX from FILENAME, which contains multiple cursors.
%
%   [X,MAP,MASK] = READCUR(FILENAME,...) returns the transparency mask
%   for the given image from FILENAME.
%
%   Note: By default Microsoft Windows cursor resources are 32-by-32
%   pixels.  MATLAB requires that pointers be 16-by-16.  Images read
%   with READCUR will likely need to be scaled.  The IMRESIZE function
%   in the Image Processing Toolbox may be helpful.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2013 The MathWorks, Inc.

if (nargin < 2)
    index = 1;
end

validateattributes(filename,{'char'},{'row'},'','FILENAME');
validateattributes(index,{'numeric'},{'scalar','positive'},'','INDEX');

if (isempty(strfind(filename,'.')))
    filename=[filename,'.cur'];
end;

info = imfinfo(filename, 'cur');

if (index > length(info))
    error(message('MATLAB:imagesci:readcur:indexOutOfRange', index, filename, length( info )));
end

% Read the XOR data and its colormap
X = readbmpdata(info(index));

map = info(index).Colormap;

maskinfo = info(index);
maskinfo.BitDepth = 1;

% Calculate the offset of the AND mask.
% Bitmap scanlines are aligned on 4 byte boundaries
imsize = maskinfo.Height * (32 * ceil(maskinfo.Width / 32))/8;
maskinfo.ImageDataOffset = maskinfo.ResourceDataOffset + ...
    maskinfo.ResourceSize - imsize;

mask = readbmpdata(maskinfo);
