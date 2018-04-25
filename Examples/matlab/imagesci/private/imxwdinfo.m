function info = imxwdinfo(filename)
%IMXWDINFO Get information about the image in an XWD file.
%   INFO = IMXWDINFO(FILENAME) returns information about
%   the image contained in an XWD file.  
%
%   See also IMREAD, IMWRITE, and IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2013 The MathWorks, Inc.

%   Reference:  Murray and vanRyper, Encyclopedia of Graphics
%   File Formats, 2nd ed, O'Reilly, 1996.

fid = fopen(filename, 'r', 'ieee-be');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));

% Initialize the standard fields to fix the order.
info = initializeMetadataStruct('xwd', fid);

info.FormatSignature = [];

% The file may be written as big-endian or little-endian.
% If the second uint value we read is not 7, re-open the file as
% little-endian.
[info.FormatSignature,count] = fread(fid, 2, 'uint32');
assert( (count == 2), message('MATLAB:imagesci:imfinfo:badFormat', filename, 'XWD'));

info.HeaderSize = info.FormatSignature(1);
info.FormatVersion = info.FormatSignature(2);
if (info.FormatVersion ~= 7)
    fclose(fid);
    fid = fopen(filename, 'r', 'ieee-le');
    assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));
    info.FormatSignature = fread(fid, 2, 'uint32');
    info.HeaderSize = info.FormatSignature(1);
    info.FormatVersion = info.FormatSignature(2);
    if (info.FormatVersion ~= 7)
        fclose(fid);
        error(message('MATLAB:imagesci:imxwdinfo:XWDVersion'));
    end
else
    cfid = onCleanup(@()fclose(fid));
end

format = fread(fid, 1, 'uint32');
if (isempty(format))
    msg = ferror(fid);
    fclose(fid);
    error(message('MATLAB:imagesci:imfinfo:freadError','PIXMAPFORMAT',msg));
end

switch format
case 0
    info.PixmapFormat = 'XYBitmap';
case 1
    info.PixmapFormat = 'XYPixmap';
case 2
    info.PixmapFormat = 'ZPixmap';
otherwise
    info.PixmapFormat = 'unknown';
end

[buffer,count] = fread(fid,22,'uint32');
if count ~= 22
    fclose(fid);
    error(message('MATLAB:imagesci:imxwdinfo:truncatedHeader'));
end

info.PixmapDepth        = buffer(1);
info.Width              = buffer(2);
info.Height             = buffer(3);
info.XOffset            = buffer(4);
info.ByteOrder          = buffer(5);
info.BitmapUnit         = buffer(6);
info.BitmapBitOrder     = buffer(7);
info.BitmapPad          = buffer(8);
info.BitDepth           = buffer(9);
info.BytesPerLine       = buffer(10);
info.VisualClass        = buffer(11);
info.RedMask            = buffer(12);
info.GreenMask          = buffer(13);
info.BlueMask           = buffer(14);
info.BitsPerRgb         = buffer(15);
info.NumberOfColors     = buffer(16);
info.NumColormapEntries = buffer(17);
info.WindowWidth        = buffer(18);
info.WindowHeight       = buffer(19);
info.WindowX            = buffer(20);
info.WindowY            = buffer(21);
info.WindowBorderWidth  = buffer(22);

nbytes = info.HeaderSize - ftell(fid);
[info.Name, count] = fread(fid, nbytes, 'uint8=>char');
info.Name = info.Name';

if (count < 1)
    msg = ferror(fid);
    fclose(fid);
    error(message('MATLAB:imagesci:imfinfo:freadError','NAME',msg));
end

if (info.NumColormapEntries > 0)
    info.ColorType = 'indexed';
    
else
    if (info.BitDepth <= 8)
        info.ColorType = 'grayscale';
    else
        info.ColorType = 'truecolor';
    end
end

