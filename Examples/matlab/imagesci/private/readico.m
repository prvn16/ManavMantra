function [X, map, mask] = readico(filename, index)
%READICO Read icon from a Windows ICO file
%   [X,MAP] = READICO(FILENAME) reads image data from an ICO file
%   containing one or more Microsoft Windows icon resources.  X is
%   a 2-D uint8 array.  MAP is an M-by-3 MATLAB colormap.  If
%   FILENAME contains more than one icon resource, the first will
%   be read.
%
%   [X,MAP] = READICO(FILENAME,INDEX) reads the icon in position INDEX
%   from FILENAME, which contains multiple icons.
%
%   [X,MAP,MASK] = READICO(FILENAME,...) returns the transperency mask
%   for the given image from FILENAME.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2016 The MathWorks, Inc.

if (nargin < 2)
    index = 1;
end

validateattributes(filename,{'char'},{'nonempty'},'','FILENAME');
validateattributes(index,{'numeric'},{'scalar','positive'},'','INDEX');

if (isempty(strfind(filename,'.')))
    filename=[filename,'.ico'];
end;

info = imfinfo(filename, 'ico');

if (index > length(info))
    error(message('MATLAB:imagesci:readico:indexOutOfRange', index, filename, length( info )));
end

% Read the XOR data and its colormap
if strcmp(info(index).CompressionType, 'png')
    % Need to call this to get the BackGroundColor.
    infoPNG = pnginfoc(filename, false, double(info(index).ImageDataOffset));
    
    background = infoPNG.BackgroundColor;
    if isempty(infoPNG.BackgroundColor)
        background = 'none';
    end
    [X, map] = readpngutil(filename, background, double(info(index).ImageDataOffset));
    return;
else
    X = readbmpdata(info(index));
end

map = info(index).Colormap;

maskinfo = info(index);
maskinfo.BitDepth = 1;

% Calculate the offset of the AND mask.
% Bitmap scanlines are aligned on 4 byte boundaries
imsize = maskinfo.Height * (32 * ceil(maskinfo.Width / 32))/8;
maskinfo.ImageDataOffset = maskinfo.ResourceDataOffset + ...
    maskinfo.ResourceSize - imsize;

mask = readbmpdata(maskinfo);
