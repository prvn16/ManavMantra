function info = impcxinfo(filename)
%IMPCXINFO Get information about the image in a PCX file.
%   INFO = IMPCXINFO(FILENAME) returns information about
%   the image contained in a PCX file.  
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2013 The MathWorks, Inc.

fid = fopen(filename, 'r', 'ieee-le');
assert(fid ~= -1, message('MATLAB:imagesci:validate:fileOpen', filename));

% Initialize universal structure fields to fix the order
info = initializeMetadataStruct('pcx', fid);
info.FormatSignature = [];

status = fseek(fid, 128, 'bof');
assert(status == 0, 'PCX header too small.');

fseek(fid, 0, 'bof');

info.FormatSignature = fread(fid, 2, 'uint8');
assert(info.FormatSignature(1) == 10, 'Not a PCX file.');

info.FormatVersion = info.FormatSignature(2);
assert( ismember(info.FormatVersion, [0 2 3 4 5]), 'Unrecognized PCX format.');

encoding = fread(fid, 1, 'uint8');
if (encoding == 1)
    info.Encoding = 'RLE';
else
    info.Encoding = 'unknown';
end

info.BitsPerPixelPerPlane = fread(fid, 1, 'uint8');
info.XStart = fread(fid, 1, 'uint16');
info.YStart = fread(fid, 1, 'uint16');
info.XEnd = fread(fid, 1, 'uint16');
info.YEnd = fread(fid, 1, 'uint16');
info.HorzResolution = fread(fid, 1, 'uint16');
info.VertResolution = fread(fid, 1, 'uint16');
info.EGAPalette = fread(fid, 48, 'uint8');
info.Reserved1 = fread(fid, 1, 'uint8');
info.NumColorPlanes = fread(fid, 1, 'uint8');
info.BytesPerLine = fread(fid, 1, 'uint16');
info.PaletteType = fread(fid, 1, 'uint16');
info.HorzScreenSize = fread(fid, 1, 'uint16');
info.VertScreenSize = fread(fid, 1, 'uint16');

info.Width = info.XEnd - info.XStart + 1;
info.Height = info.YEnd - info.YStart + 1;
info.BitDepth = info.NumColorPlanes * info.BitsPerPixelPerPlane;
if (info.BitDepth == 24)
    info.ColorType = 'truecolor';

else
    % There might not be a colormap at the end of the file.  We
    % don't want to find out in this function because it requires
    % seeking to the end-of-file, which takes too much time for
    % big image files.   In fact, to be absolutely sure we would
    % have to decode the image.  But most PCX files that are
    % 8-bit or less are indexed.
    info.ColorType = 'indexed';
    
end


fclose(fid);
