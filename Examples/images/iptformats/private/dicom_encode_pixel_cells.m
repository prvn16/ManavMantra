function pixelCells = dicom_encode_pixel_cells(X, map, ba, bs, hb)
%DICOM_ENCODE_PIXEL_CELLS   Convert an image to pixel cells.
%   PIXCELLS = DICOM_ENCODE_PIXEL_CELLS(X, MAP) convert the image X with
%   colormap MAP to a sequence of DICOM pixel cells.

%   Copyright 1993-2014 The MathWorks, Inc.

% Images are stored across then down.  If there are multiple samples,
% keep all samples for each pixel contiguously stored.
X = permute(X, [3 2 1 4]);

pixelCells = basicEncoding(X, map, ba);

% For floating point pixels, basicEncoding() is sufficient.
switch (class(X))
case {'single', 'double', 'logical'}
    return
case {'uint8', 'int8'}
    maxBitsAlloc = 8;
case {'uint16', 'int16'}
    maxBitsAlloc = 16;
case {'uint32', 'int32'}
    maxBitsAlloc = 32;
case {'uint64', 'int64'}
    maxBitsAlloc = 64;
otherwise
    assert(false, 'Internal error: Unsupported data type')
end

% Find out whether to shift the pixels within the cell. Pixels that fully
% span have a "high bit" value one less than "bits stored" (0-based).
if (hb ~= (bs - 1))
    pixelCells = shiftPixels(pixelCells, bs, hb);
end

% "Squeeze" the extra bits out of the pixel stream if BitsAllocated is less
% than the number of bits used by the MATLAB datatype.
if (ba ~= maxBitsAlloc)
    pixelCells = advancedEncoding(pixelCells, ba);
end

%--------------------------------------------------------------------------
function pixelCells = basicEncoding(X, map, ba)

% Convert to correct output type.
switch (class(X))
case 'logical'
   
    warning(message('images:dicom_encode_pixel_cells:scalingLogicalData'));
    
    tmp = uint8(X);
    tmp(X) = 255;
    
    X = tmp;
    
case {'single', 'double'}
   
    maxValue = 2^ba - 1;
    
    if (isempty(map))
        
        % RGB or Grayscale.
        X = uint16(maxValue * X);
        
    else
       
        if (size(X, 1) == 1)
            
            % Indexed.
            X = uint16(X - 1);
            
        elseif (size(X, 1) == 4)
            
            % RGBA
            X(1:3, :, :) = X(1:3, :, :) * maxValue;
            X(4, :, :)   = X(4, :, :) - 1;
            X = uint16(X);
            
        end
    end
end

pixelCells = X(:);
 
%--------------------------------------------------------------------------
function pixelCells = advancedEncoding(pixelCells, ba)
%advancedEncoding  Encode pixel cells while writing to a temporary file and
%then reading the encoded pixels back to the buffer. This truncates "short"
%pixel cells that don't span the full datatype.

pixelCellClass = class(pixelCells);

% Write the data to the temporary file, squeezing out extra bits. The last
% pixel cell will be padded to end on a byte boundary.
filename = tempname();
fid = fopen(filename, 'wb');
if (fid < 0)
    error(message('images:dicomwrite:tempFileNotCreated'))
end

fileCleaner = onCleanup(@() delete(filename));

switch (pixelCellClass)
    case {'int8', 'int16', 'int32', 'int64'}
        precision = sprintf('bit%d', ba);
    case {'uint8', 'uint16', 'uint32', 'uint64'}
        precision = sprintf('ubit%d', ba);
end
fwrite(fid, pixelCells, precision);
fclose(fid);

% Read all of the data back into the original encoded class type. Each
% "pixel cell" read will incorporate more than one pixel, but this is done
% to ensure that any potential byte-swapping happens correctly.
precision = sprintf('%s=>%s', pixelCellClass, pixelCellClass);

fid = fopen(filename, 'rb');
pixelCells = fread(fid, inf, precision);
fclose(fid);

%--------------------------------------------------------------------------
function pixelCells = shiftPixels(pixelCells, bs, hb)

bitsToShift = hb - bs + 1;
pixelCells = bitshift(pixelCells, bitsToShift);
