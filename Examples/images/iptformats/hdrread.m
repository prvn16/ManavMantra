function data = hdrread(filename)
%HDRREAD    Read Radiance HDR image.
%   HDR = HDRREAD(FILENAME) reads the high dynamic range image HDR from
%   FILENAME, which points to a Radiance .hdr file.  HDR is an m-by-n-by-3
%   RGB array in the range [0,inf) and has type single.  For scene-referred
%   datasets, these values usually are scene illumination in radiance
%   units.  To display these images, use an appropriate tone-mapping
%   operator.
%
%   Class Support
%   -------------
%   The output image HDR is an m-by-n-by-3 image with type single.
%
%   Example
%   -------
%       hdr = hdrread('office.hdr');
%       rgb = tonemap(hdr);
%       imshow(rgb);
%
%   Reference: "Radiance File Formats" by Greg Ward Larson
%   (http://radsite.lbl.gov/radiance/refer/filefmts.pdf)
%
%   See also HDRWRITE, MAKEHDR, TONEMAP.

%   Copyright 2007-2017 The MathWorks, Inc.

filename = matlab.images.internal.stringToChar(filename);

fid = openFile(filename);
oc = onCleanup(@() fclose(fid));
fileinfo = readHeader(fid);
data = readImage(fid, fileinfo);

end


function fid = openFile(filename)
%openFile   Open a file.

validateattributes(filename, {'char'}, {'row'}, mfilename, 'FILENAME', 1);

[fid, msg] = fopen(filename, 'r');
if (fid == -1)
    
    error(message('images:hdrread:fileOpen', filename, msg));
    
end

end


function fileInfo = readHeader(fid)
%readHeader   Extract key HDR values from the text header.

header = '';

% Ensure that we're reading an HDR file.
while (isempty(strfind(header, '#?')) && ~feof(fid))
    header = fgetl(fid);
    continue;
end

radianceMarker = strfind(header, '#?');
if (isempty(radianceMarker))
    error(message('images:hdrread:notRadiance'))
end

fileInfo.identifier = header((radianceMarker+1):end);
if (isempty(strfind(fileInfo.identifier, 'RADIANCE')) && ...
    isempty(strfind(fileInfo.identifier, 'RGBE')))
    
    error(message('images:hdrread:noMarker'))
end

% Use fgetl, which strip newlines and to find the transition between
% header and data.
headerLine = fgetl(fid);
while (~isempty(headerLine))
    headerLine = fgetl(fid);
end

% Read the resolution variables.  This is the number and length of scanlines.
headerLine = fgetl(fid);
fileInfo.Ysign = headerLine(1);
[fileInfo.height, ~, ~, nextindex] = sscanf(headerLine(4:end), '%d', 1);
fileInfo.Xsign = headerLine(nextindex+4);
fileInfo.width = sscanf(headerLine(nextindex+7:end), '%d', 1);

end


function img = readImage(fid, fileInfo)
%readImage   Get the decoded RGB data from the file.

% The file pointer (fid) should be at the start of the image data.

% Allocate space for the output.
img(fileInfo.height, fileInfo.width, 3) = single(0);

% Read the remaining data
encodedData = fread(fid, inf, 'uint8=>uint8');

scanlineWidth = fileInfo.width;
scanlineCount = fileInfo.height;

% Set the data pointer to the beginning of the compressed data.
offset = 1;

compressed = isCompressedScanline(encodedData, offset);

% Process each scanline.
for scanline = 1:scanlineCount
    
    if compressed
        [unpackedData, offset] = decompressScanline(encodedData, offset, scanlineWidth);
    else
        unpackedData = unpackScanline(encodedData, offset, scanlineWidth);
        offset = offset + 4*scanlineWidth;
    end
    
    % Convert the UINT8 buffer to floating point and add it to the output.
    img(scanline,:,:) = rgbe2rgb(unpackedData);
    
end

end


function scanlineLength = getScanlineLength(rawData)
%getScanlineLength   Determine the length of a scanline.

% Scanline length is a two-byte, big-endian word.
scanlineLength = double(rawData(1)) * 256 + ...
                 double(rawData(2));
return

end


function [decodedData, offset] = decompressScanline(encodedData, offset, scanlineWidth)
        
% The next two bytes represent the scanline width.
if (getScanlineLength(encodedData((2:3) + offset)) ~= scanlineWidth)
    
    error(message('images:hdrread:scanlineWidth'))
    
end

% Create a buffer for the uncompressed data.
decodedData(scanlineWidth, 4) = uint8(0);

offset = offset + 4;

for sample = 1:4
    
    % Decode the portion of the scanline for the current sample.  When
    % determining how much of the encoded scanline to send, assume the
    % worst possible compression (1:2).
    stopIdx = min(numel(encodedData), offset + 2*scanlineWidth);
    
    [decodedBytes, numDecodedBytes] = ...
        rleDecoder(encodedData(offset:stopIdx), scanlineWidth);
    
    if (numel(decodedBytes) ~= scanlineWidth)
        error(message('images:hdrread:incorrectDecodeCount'))
    end
    
    decodedData(:, sample) = decodedBytes;
    offset = offset + numDecodedBytes;
    
end

end


function unpackedData = unpackScanline(encodedData, offset, scanlineWidth)

startIdx = offset;
stopIdx = startIdx + 4*scanlineWidth - 1;

unpackedData = reshape(encodedData(startIdx:stopIdx), 4, []);
unpackedData = unpackedData';

end


function compressed = isCompressedScanline(encodedData, offset)

% "New format" RLE scanlines encode the RGBE components separately.
% These scanlines start with [2 2].
%
% "Old format" RLE scanlines use [1 1 1 n] where n is the number of times
% the previous pixel is repeated. This is currently unsupported.
%
% Everything else is uncompressed.

if ((encodedData(offset) == 2) && (encodedData(offset+1) == 2))
    
    compressed = true;
    
elseif ((encodedData(offset) == 1) && ...
        (encodedData(offset+1) == 1) && ...
        (encodedData(offset+2) == 1))
    
    error(message('images:hdrread:unsupportedRLE'));
    
else
    
    compressed = false;
    
end

end
