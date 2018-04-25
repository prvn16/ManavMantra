function X = nitfReadJPEG(details, region)
%nitfReadJPEG   Extract JPEG-compressed image from NITF file.
%   X = nitfReadJPEG(DETAILS, REGION) returns the image X from the NITF
%   file described in the DETAILS structure.  The REGION argument is
%   currently not used.
%
%   See MIL-STD-188-198 for details of this scheme.

% Copyright 2010-2013 The MathWorks, Inc.

% Currently there's no pixel subsetting for NITF I/O.
if (~isempty(region))
    error(message('images:nitfread:jpegSubsetting'))
end

% Get the JPEG data from the file.
compData = getJpegStream(details);

% Get the number of blocks, dimensions and markers.
nColsBlocks = double(swapbytes(typecast(compData(15:16), 'uint16')));
nRowsBlocks = double(swapbytes(typecast(compData(17:18), 'uint16')));

h = details.tileHeight;
w = details.tileWidth;

[startIdx, stopIdx, maskedBlocks] = getBlockLocations(compData, details, nColsBlocks, nRowsBlocks);

% Create the full-sized image.
X = createOutputArray(details);

% Read all of the blocks.
name = [tempname '.jpg'];
cleaner = onCleanup(@() delete(name));

idx = 1;
r = 1;
for j = 1:nRowsBlocks
    c = 1;
    for i = 1:nColsBlocks
        
        % If the block is masked, update the position and go to the next.
        if (maskedBlocks(idx))
            c = c + w;
            idx = idx + 1;
            continue;
        end
        
        start = startIdx(idx);
        stop = stopIdx(idx);
        frameData = compData(start:stop);

        % Read the portion of the image and store it.
        data = getImageDataFromFrame(name, frameData);
        X(r:(r+h-1), c:(c+w-1), :) = data;

        % Update the position.
        c = c + w;
        idx = idx + 1;
    end
    
    r = r + h;
end



function compData = getJpegStream(details)

% Open the NITF file.
fid = fopen(details.filename, 'rb');
if (fid == 0)
    error(message('images:nitfread:jpegFileOpen', details.filename))
else
    c = onCleanup(@() fclose(fid));
end

% Move to the location in the file where the JPEG stream begins.
details.offsetStart = convertOffsetType(details.offsetStart);

status = fseek(fid, details.offsetStart, 'bof');
if (status ~= 0)
    error(message('images:nitfread:jpegFseek'));
end

% Read the JPEG data, which comprises the rest of the NITF file.
compData = fread(fid, inf, 'uint8=>uint8');

% Trim leading 0xFF pad values before SOI.
while ((numel(compData > 2)) && (compData(2) == 255))
    compData(1) = [];
end

% Validate the JPEG stream.  It should start with an SOI marker (0xFF 0xD8)
% and then an APP6 marker (0xFF 0xE6).
if (~isequal(compData(1:2), [255; 216]))
    error(message('images:nitfread:badEncapsulation'))
end

if (~isequal(compData(3:4), [255; 230]))
    error(message('images:nitfread:missingAppMarker'))
end



function [startIdx, stopIdx, skipIdx] = getBlockLocations(compData, details, nColsBlocks, nRowsBlocks)

% Find the Image markers
SOIidx = findpattern(compData', sscanf('ff d8', '%x')');
EOIidx = findpattern(compData', sscanf('ff d9', '%x')');
SOFidx = sort([findpattern(compData', sscanf('ff c0', '%x')'), ...
               findpattern(compData', sscanf('ff c1', '%x')'), ...
               findpattern(compData', sscanf('ff c2', '%x')'), ...
               findpattern(compData', sscanf('ff c3', '%x')')]);

if ((numel(SOIidx) ~= numel(EOIidx)) || ...
    (numel(SOIidx) ~= numel(SOFidx)))
    error(message('images:nitfread:jpegSoiEoiCount'))
end

% Does the NITF file use block masking, where some tiles are "virtual"?
if (isfield(details, 'blockOffsets'))
    blockMasking = true;
    skipIdx = (details.blockOffsets == intmax('uint32'));
else
    blockMasking = false;
    skipIdx = false(nRowsBlocks * nColsBlocks, 1);
end

if ((numel(SOIidx) ~= (nColsBlocks * nRowsBlocks)) && ~blockMasking)
    warning(message('images:nitfread:wrongSOFIndexCount'));
end

% Compute where each tile's JPEG data starts and ends.
if (~blockMasking)
    % If there's no masking, the data starts and stops with each SOI/EOI pair.
    startIdx = SOIidx;
    stopIdx = EOIidx + 1;
else
    % If there is masking, the data start positions are given by the
    % blockOffset values.  NaN indicates a masked out frame.
    startIdx = details.blockOffsets + 1;
    startIdx(skipIdx) = NaN;

    % Each tile ends directly before the next one starts.  (Masked frames
    % are tricky, so just use the end of the stream.)  Shift the start
    % values one over and subtract one to determine where they end.  The
    % last stop value is the last compressed value location.
    stopIdx = [(startIdx(2:end) - 1) numel(compData)];
    stopIdx(isnan(stopIdx)) = numel(compData);
    stopIdx(skipIdx) = NaN;
end



function X = createOutputArray(details)

imgSize = [details.imageHeight, details.imageWidth, details.samplesPerPixel];
if (details.bitsPerSample <= 8)
    X = zeros(imgSize, 'uint8');
elseif (details.bitsPerSample <= 16)
    X = zeros(imgSize, 'uint16');
else
    error(message('images:nitfread:jpegBitDepth', details.bitsPerSample));
end



function img = getImageDataFromFrame(name, frameData)

fid = fopen(name, 'wb');
if (fid == 0)
    error(message('images:nitfread:tmpJpegFileOpen', name))
else
    c = onCleanup(@() fclose(fid));
end

fwrite(fid, frameData, 'uint8');
delete(c);

img = imread(name, 'jpeg');



function idx = findpattern(array, pattern)
%FINDPATTERN  Find a pattern in an array.

% Despite its name, "strfind" is very good at finding numeric patterns in
% numeric vectors.
idx = strfind(array, pattern);


function out = convertOffsetType(in)

if (in > intmax('uint32'))
    error(message('images:nitfread:offsetTooBigForJPEG'))
end

out = double(in);
