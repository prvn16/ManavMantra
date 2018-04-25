function [X, metadata] = parseDPX(filename, readImages)
%parseDPX  Basic DPX parser.

% Copyright 2014-2016 The MathWorks, Inc.

file = openFile(filename);
file = readMetadata(file);
if (readImages)
    X = readImage(file);
else
    X = [];
end

metadata = file.metadata;
metadata.AbsoluteFilePath = file.AbsoluteFilePath;

end


function file = openFile(filename)

[file.fid, msg] = fopen(filename);

if (file.fid == -1)
    error(message('images:dpx:fileOpen', filename, msg))
end

file.closer = onCleanup(@() fclose(file.fid));
file.AbsoluteFilePath = fopen(file.fid);

end


function file = readMetadata(file)

% File Information Header
file = determineFileEndian(file);
metadata.FormatSignature = file.magicNumber;
metadata.FileEndian = file.fileEndian;
skipBytes(file, 4);
metadata.FormatVersion = readData(file, 8, 'uint8=>char');
metadata.FormatVersion = metadata.FormatVersion';
metadata.ImageBytes = readData(file, 1, 'uint32');

% Image Information Header
offsetToImageInformationHeader = 768;
fseek(file.fid, offsetToImageInformationHeader, 'bof');
metadata.ImageOrientation = getImageOrientation(file);
metadata.NumberOfImageElements = readData(file, 1, 'uint16');
metadata.PixelsPerLine = readData(file, 1, 'uint32');  % Columns
metadata.LinesPerImageElement = readData(file, 1, 'uint32');  % Rows

for imageElement = 1:metadata.NumberOfImageElements
    metadata.ImageElementMetadata(imageElement) = readImageElementMetadata(file);
end

file.metadata = metadata;

numChannels = getNumberOfChannels(file);
file.metadata.NumberOfChannels = numChannels;

end


function skipBytes(file, numBytes)

fread(file.fid, numBytes);

end


function data = readData(file, numberOfItems, precision)

data = fread(file.fid, numberOfItems, precision, file.fileEndian);

end


function file = determineFileEndian(file)

magicNumber = fread(file.fid, 4, 'uint8');
magicNumber = reshape(magicNumber, [1 4]);

bigEndianValue = uint8([83   68   80   88]); % SDPX
littleEndianValue = fliplr(bigEndianValue);

if (isequal(magicNumber, bigEndianValue))
    file.fileEndian = 'ieee-be';
elseif (isequal(magicNumber, littleEndianValue))
    file.fileEndian = 'ieee-le';
else
    error(message('images:dpx:unexpectedEndian', char(magicNumber)))
end

file.magicNumber = magicNumber;

end


function orientation = getImageOrientation(file)

orientation = readData(file, 1, 'uint16');

end


function elementMetadata = readImageElementMetadata(file)

elementMetadata.DataSign = readData(file, 1, 'uint32');

skipBytes(file, 16);

elementMetadata.Descriptor = readData(file, 1, 'uint8');
elementMetadata.TransferCharacteristic = readData(file, 1, 'uint8');
elementMetadata.ColorimetricSpecification = readData(file, 1, 'uint8');
elementMetadata.BitDepth = readData(file, 1, 'uint8');
elementMetadata.Packing = readData(file, 1, 'uint16');
elementMetadata.Encoding = readData(file, 1, 'uint16');
elementMetadata.OffsetToData = readData(file, 1, 'uint32');

skipBytes(file, 40)

end


function X = readImage(file)

if (isInterleaved(file))
    X = readInterleaved(file);
else
    X = readSeparate(file);
end

X = permute(X, [2 1 3]);

end


function tf = isInterleaved(file)

if (numel(file.metadata.ImageElementMetadata) > 1)
    tf = false;
else
    switch (getDescriptor(file, 1))
    case {1, 2, 3, 4, 6, 7, 8, 9}
        tf = false;
    case {50, 51, 52, 100, 101, 102, 103}
        tf = true;
    otherwise
        error(message('images:dpx:unsupportedDescriptor', ...
            metadata.ImageElementMetadata.Descriptor))
    end
end
end


function packingMethod = getPackingMethod(file, elementNumber)

packingMethod = file.metadata.ImageElementMetadata(elementNumber).Packing;

end


function numberOfImageElements = getNumberOfImageElements(file)

numberOfImageElements = file.metadata.NumberOfImageElements;

end


function descriptor = getDescriptor(file, elementNumber)

descriptor = file.metadata.ImageElementMetadata(elementNumber).Descriptor;

end


function numberOfRows = getNumberOfRows(file)

numberOfRows = file.metadata.LinesPerImageElement;

end


function numberOfColumns = getNumberOfColumns(file)

numberOfColumns = file.metadata.PixelsPerLine;

end


function X = readInterleaved(file)

X = preallocateImage(file);

elementNumber = 1;
isSubsampled = channelIsSubsampled(file, elementNumber);
if (isSubsampled)
    error(message('images:dpx:interleavedSubsampledNotSupported'))
end

gotoImageData(file, elementNumber)

packingMethod = getPackingMethod(file, elementNumber);
switch (packingMethod)
case 0
    X = readInterleavedPackingMode0(X, file);
case 1
    X = readInterleavedPackingMode1(X, file);
case 2
    X = readInterleavedPackingMode2(X, file);
otherwise
    error(message('images:dpx:unsupportedPacking', packingMethod))
end

end


function X = readSeparate(file)

X = preallocateImage(file);

numberOfElements = getNumberOfImageElements(file);

for elementNumber = 1:numberOfElements

    gotoImageData(file, elementNumber)

    packingMethod = getPackingMethod(file, elementNumber);
    isSubsampled = channelIsSubsampled(file, elementNumber);

    switch (packingMethod)
    case 0
        X = readSeparatePackingMode0(X, file, elementNumber, isSubsampled);
    case 1
        if (isSubsampled)
            error(message('images:dpx:interleavedSubsampledNotSupported'))
        end
        X = readSeparatePackingMode1(X, file, elementNumber);
    case 2
        if (isSubsampled)
            error(message('images:dpx:interleavedSubsampledNotSupported'))
        end
        X = readSeparatePackingMode2(X, file, elementNumber);
    otherwise
        error(message('images:dpx:unsupportedPacking', packingMethod))
    end
    
end

end


function gotoImageData(file, elementNumber)

imageElementStart = file.metadata.ImageElementMetadata(elementNumber).OffsetToData;
fseek(file.fid, imageElementStart, 'bof');

end


function X = readSeparatePackingMode0(X, file, elementNumber, isSubsampled)

bitDepth = getBitDepth(file);
numRows = getNumberOfRows(file);
numColumns = getNumberOfColumns(file);

if (bitDepth == 8)
    numberOfSamplesPerLine = numColumns + paddingAmount(numColumns, 4);

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint8=>uint8');
        
        if isSubsampled
            X(1:2:end, currentLine, elementNumber) = buffer(1:2:numColumns);
            X(2:2:end, currentLine, elementNumber) = buffer(1:2:numColumns);
            X(1:2:end, currentLine, elementNumber+1) = buffer(2:2:numColumns);
            X(2:2:end, currentLine, elementNumber+1) = buffer(2:2:numColumns);
        else
            X(:, currentLine, elementNumber) = buffer(1:numColumns);
        end
    end
    
elseif (bitDepth == 16)
    numberOfSamplesPerLine = numColumns;

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint16=>uint16');
        
        if isSubsampled
            X(1:2:end, currentLine, elementNumber) = buffer(1:2:numColumns);
            X(2:2:end, currentLine, elementNumber) = buffer(1:2:numColumns);
            X(1:2:end, currentLine, elementNumber+1) = buffer(2:2:numColumns);
            X(2:2:end, currentLine, elementNumber+1) = buffer(2:2:numColumns);
        else
            X(:, currentLine, elementNumber) = buffer(1:numColumns);
        end
    end
    
elseif (bitDepth == 1)
    numberOf32BitBlocks = ceil(numColumns / 32);
    
    for currentLine = 1:numRows
        buffer32 = readData(file, numberOf32BitBlocks, 'uint32=>uint32');
        bufferLogical = unpack32ToLogical(buffer32);
        X(:, currentLine, elementNumber) = bufferLogical(1:numColumns);
    end
    
else
    if (needToSwapPackedBits(file))
        numChannelsToUnpack = 1;
        X = readAndSwapPackedData(X, file, bitDepth, numRows, numColumns, numChannelsToUnpack, elementNumber, isSubsampled);
        
    else
        numberOfSamplesPerLine = numColumns;
        readFormat = sprintf('ubit%d=>uint16', bitDepth);
        extraPadding = paddingAmount(numberOfSamplesPerLine * bitDepth, 32);
        
        for currentLine = 1:numRows
            buffer = readData(file, numberOfSamplesPerLine, readFormat);
        
            if isSubsampled
                X(1:2:end, currentLine, elementNumber) = buffer(1:2:numColumns);
                X(2:2:end, currentLine, elementNumber) = buffer(1:2:numColumns);
                X(1:2:end, currentLine, elementNumber+1) = buffer(2:2:numColumns);
                X(2:2:end, currentLine, elementNumber+1) = buffer(2:2:numColumns);
            else
                X(:, currentLine, elementNumber) = buffer(1:numColumns);
            end
            
            readData(file, extraPadding, 'ubit1');
        end
        
    end
end

end


function X = readSeparatePackingMode1(X, file, elementNumber)

bitDepth = getBitDepth(file);
numRows = getNumberOfRows(file);
numColumns = getNumberOfColumns(file);

if (bitDepth == 8)
    numberOfSamplesPerLine = numColumns + paddingAmount(numColumns, 4);

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint8=>uint8');
        X(:, currentLine, elementNumber) = buffer(1:numColumns);
    end
    
elseif (bitDepth == 10)
    
    X = readPadded10BitData(X, file, numRows, numColumns, 1, elementNumber, 1);
    
elseif (bitDepth == 12)
    
    X = readPadded12BitData(X, file, numRows, numColumns, 1, elementNumber, 1);
    
elseif (bitDepth == 16)
    numberOfSamplesPerLine = numColumns;

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint16=>uint16');
        X(:, currentLine, elementNumber) = buffer(1:numColumns);
    end
    
else
    error(message('images:dpx:unsupportedBitDepth', bitDepth))
end

end


function X = readSeparatePackingMode2(X, file, elementNumber)

bitDepth = getBitDepth(file);
numRows = getNumberOfRows(file);
numColumns = getNumberOfColumns(file);

if (bitDepth == 8)
    numberOfSamplesPerLine = numColumns + paddingAmount(numColumns, 4);

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint8=>uint8');
        X(:, currentLine) = buffer(1:numColumns);
    end
    
elseif (bitDepth == 10)
    
    X = readPadded10BitData(X, file, numRows, numColumns, 1, elementNumber, 2);
    
elseif (bitDepth == 12)
    
    X = readPadded12BitData(X, file, numRows, numColumns, 1, elementNumber, 2);
    
elseif (bitDepth == 16)
    numberOfSamplesPerLine = numColumns;

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint16=>uint16');
        X(:, currentLine) = buffer(1:numColumns);
    end
    
else
    error(message('images:dpx:unsupportedBitDepth', bitDepth))
end

end


function X = readInterleavedPackingMode0(X, file)

bitDepth = getBitDepth(file);
numRows = getNumberOfRows(file);
numColumns = getNumberOfColumns(file);
numChannels = getNumberOfChannels(file);

if (bitDepth == 16)
    numberOfSamplesPerLine = numChannels * numColumns;

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint16=>uint16');
        
        for currentChannel = 1:numChannels
            X(:, currentLine, currentChannel) = buffer(currentChannel:numChannels:(numChannels*numColumns));
        end
    end
    
elseif (bitDepth == 8)

    numberOfSamplesPerLine = numChannels * numColumns;
    numberOfSamplesPerLine = numberOfSamplesPerLine + paddingAmount(numberOfSamplesPerLine, 4);

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint8=>uint8');
        
        for currentChannel = 1:numChannels
            X(:, currentLine, currentChannel) = buffer(currentChannel:numChannels:(numChannels*numColumns));
        end
    end
    
else

    if (needToSwapPackedBits(file))
        
        X = readAndSwapPackedData(X, file, bitDepth, numRows, numColumns, numChannels, [], false);
        
    else
        
        numberOfSamplesPerLine = numChannels * numColumns;
        readFormat = sprintf('ubit%d=>uint16', bitDepth);
        extraPadding = paddingAmount(numberOfSamplesPerLine * bitDepth, 32);
        
        for currentLine = 1:numRows
            buffer = readData(file, numberOfSamplesPerLine, readFormat);
            for currentChannel = 1:numChannels
                X(:, currentLine, currentChannel) = buffer(currentChannel:numChannels:(numChannels*numColumns));
            end
            readData(file, extraPadding, 'ubit1');
        end
        
    end
    
end

end


function X = readInterleavedPackingMode1(X, file)

bitDepth = getBitDepth(file);
numRows = getNumberOfRows(file);
numColumns = getNumberOfColumns(file);
numChannels = getNumberOfChannels(file);

if (bitDepth == 8)
    numberOfSamplesPerLine = numChannels * numColumns;
    numberOfSamplesPerLine = numberOfSamplesPerLine + paddingAmount(numberOfSamplesPerLine, 4);
    
    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint8=>uint8');
        
        for currentChannel = 1:numChannels
            X(:, currentLine, currentChannel) = buffer(currentChannel:numChannels:(numChannels*numColumns));
        end
    end
    
elseif (bitDepth == 10)
    
    X = readPadded10BitData(X, file, numRows, numColumns, numChannels, [], 1);
    
elseif (bitDepth == 12)
    
    X = readPadded12BitData(X, file, numRows, numColumns, numChannels, [], 1);
    
elseif (bitDepth == 16)
    numberOfSamplesPerLine = numChannels * numColumns;

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint16=>uint16');
        
        for currentChannel = 1:numChannels
            X(:, currentLine, currentChannel) = buffer(currentChannel:numChannels:(numChannels*numColumns));
        end
    end
    
else
    error(message('images:dpx:unsupportedBitDepth', bitDepth))
end

end


function X = readInterleavedPackingMode2(X, file)

bitDepth = getBitDepth(file);
numRows = getNumberOfRows(file);
numColumns = getNumberOfColumns(file);
numChannels = getNumberOfChannels(file);

if (bitDepth == 8)
    numberOfSamplesPerLine = numChannels * numColumns;
    numberOfSamplesPerLine = numberOfSamplesPerLine + paddingAmount(numberOfSamplesPerLine, 4);

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint8=>uint8');
        
        for currentChannel = 1:numChannels
            X(:, currentLine, currentChannel) = buffer(currentChannel:numChannels:(numChannels*numColumns));
        end
    end
    
elseif (bitDepth == 10)
    
    X = readPadded10BitData(X, file, numRows, numColumns, numChannels, [], 2);
    
elseif (bitDepth == 12)
    
    X = readPadded12BitData(X, file, numRows, numColumns, numChannels, [], 2);
    
elseif (bitDepth == 16)
    numberOfSamplesPerLine = numColumns;

    for currentLine = 1:numRows
        buffer = readData(file, numberOfSamplesPerLine, 'uint16=>uint16');
        
        for currentChannel = 1:numChannels
            X(:, currentLine, currentChannel) = buffer(currentChannel:numChannels:(numChannels*numColumns));
        end
    end
    
else
    error(message('images:dpx:unsupportedBitDepth', bitDepth))
end

end


function bitDepth = getBitDepth(file)

bitDepth = file.metadata.ImageElementMetadata(1).BitDepth;

end


function X = preallocateImage(file)

% "All components in an image element shall have the same number of bits
% and the same data metric." - SMPTE 268M-2003, Table 1.

bitDepth = getBitDepth(file);
numRows = getNumberOfRows(file);
numColumns = getNumberOfColumns(file);
numChannels = getNumberOfChannels(file);

% Create transposed image.
switch bitDepth
case 1
    X = false([numColumns, numRows, numChannels]);
case 8
    X = zeros([numColumns, numRows, numChannels], 'uint8');
case {10, 12, 16}
    X = zeros([numColumns, numRows, numChannels], 'uint16');
otherwise
    error(message('images:dpx:unsupportedBitDepth', bitDepth))
end

end


function numChannels = getNumberOfChannels(file)

numChannels = 0;
for currentElement = 1:getNumberOfImageElements(file)
    descriptor = getDescriptor(file, currentElement);
    switch descriptor
    case {1, 2, 3, 4, 6, 8, 9}
        numChannels = numChannels + 1;
    case {7}
        numChannels = numChannels + 2;
    case {50, 100, 102}
        numChannels = numChannels + 3;
    case {51, 52, 101, 103}
        numChannels = numChannels + 4;
    otherwise
        error(message('images:dpx:unsupportedDescriptor', descriptor))
    end
end

end


function X = readPadded10BitData(X, file, numRows, numColumns, numChannels, outputChannel, mode)

isInterleaved = isempty(outputChannel);

total32BitChunksPerLine = ceil(numChannels * numColumns / 3);
numberOfPaddingSamples = total32BitChunksPerLine*3 - numChannels * numColumns;

if (numberOfPaddingSamples == 2)
    lastMeaningfulPos1 = total32BitChunksPerLine - 1;
    lastMeaningfulPos2 = total32BitChunksPerLine - 1;
elseif (numberOfPaddingSamples == 1)
    lastMeaningfulPos1 = total32BitChunksPerLine - 1;
    lastMeaningfulPos2 = total32BitChunksPerLine;
else
    lastMeaningfulPos1 = total32BitChunksPerLine;
    lastMeaningfulPos2 = total32BitChunksPerLine;
end

tempLine = zeros(1, numChannels * numColumns, 'uint16');

for currentLine = 1:numRows
    fullLine = readData(file, total32BitChunksPerLine, 'uint32=>uint32');
    
    [position1, position2, position3] = unpack10BitData(fullLine, mode);

    tempLine(1:3:end) = uint16(position3);
    tempLine(2:3:end) = uint16(position2(1:lastMeaningfulPos2));
    tempLine(3:3:end) = uint16(position1(1:lastMeaningfulPos1));
    
    if isInterleaved
        for currentChannel = 1:numChannels
            X(:, currentLine, currentChannel) = tempLine(currentChannel:numChannels:end);
        end
    else
        X(:, currentLine, outputChannel) = tempLine;
    end
end

end


function [position1, position2, position3] = unpack10BitData(fullLine, mode)

max10BitValue = uint32(1023);

if mode == 1
    position1 = bitand(bitshift(fullLine, -2), max10BitValue);
    position2 = bitand(bitshift(fullLine, -12), max10BitValue);
    position3 = bitand(bitshift(fullLine, -22), max10BitValue);
else
    position1 = bitand(fullLine, max10BitValue);
    position2 = bitand(bitshift(fullLine, -10), max10BitValue);
    position3 = bitand(bitshift(fullLine, -20), max10BitValue);
end

end


function X = readPadded12BitData(X, file, numRows, numColumns, numChannels, outputChannel, mode)

isInterleaved = isempty(outputChannel);

total16BitChunksPerLine = numChannels * numColumns;

for currentLine = 1:numRows
    fullLine = readData(file, total16BitChunksPerLine, 'uint16=>uint16');
    
    max12BitValue = uint16(4095);
    
    if (mode == 1)
        maskedLine = bitand(bitshift(fullLine, -4), max12BitValue);
    else
        maskedLine = bitand(fullLine, max12BitValue);
    end

    if (isInterleaved)
        for currentChannel = 1:numChannels
            X(:, currentLine, currentChannel) = maskedLine(currentChannel:numChannels:end);
        end
    else
        X(1:2:end, currentLine, outputChannel) = uint16(maskedLine(1:2:end));
        X(2:2:end, currentLine, outputChannel) = uint16(maskedLine(2:2:end));
    end
    
end

end


function bufferLogical = unpack32ToLogical(buffer32)

buffer32Size = size(buffer32);
bufferLogical = false(buffer32Size(1)*32, buffer32Size(2));

for bitPosition = 0:31
    bitsAtThisPosition = bitand(bitshift(buffer32,-bitPosition), uint32(1)) == 1;
    bufferLogical((bitPosition+1):32:end) = bitsAtThisPosition;
end

end


function tf = needToSwapPackedBits(file)

% Assumes MATLAB is only supported on little endian platforms.
tf = isequal(file.fileEndian, 'ieee-be');

end


function X = readAndSwapPackedData(X, file, bitDepth, numRows, numColumns, numChannels, elementNumber, isSubsampled)

isInterleaved = isempty(elementNumber);

numberOf32BitBlocks = ceil(numColumns * numChannels * bitDepth / 32);

mask = uint32(2^bitDepth - 1);

for currentLine = 1:numRows
    buffer = readData(file, numberOf32BitBlocks, 'uint32=>uint32');
    
    chunkIsWithinBlock = true;
    outputLocation = 1;
    bitStart = 0;
    currentBlock = 1;
    
    if (~isInterleaved)
        outputChannel = elementNumber;
    else
        outputChannel = 1;
    end
    
    while (currentBlock <= numberOf32BitBlocks)
        % Shuffle *bitDepth* chunks off the stream of blocks.
        
        if (outputLocation > numColumns)
            currentBlock = currentBlock + 1;
            continue
        end
        
        if chunkIsWithinBlock
            shiftedChunk = bitshift(buffer(currentBlock), -bitStart);
            value = bitand(shiftedChunk, mask);
        else
            lsbPart = bitshift(buffer(currentBlock), -bitStart);
            
            remainderBits = bitDepth - (32 - bitStart);
            remainderMask = uint32(2^remainderBits - 1);
            msbPart = bitand(buffer(currentBlock+1), remainderMask);
            
            value = bitor(lsbPart, bitshift(msbPart, (bitDepth - remainderBits)));
        end
        
        if (isSubsampled)
            if (rem(outputLocation, 2) == 1)
                X(outputLocation, currentLine, outputChannel) = uint16(value);
                X(outputLocation+1, currentLine, outputChannel) = uint16(value);
            else
                X(outputLocation-1, currentLine, outputChannel+1) = uint16(value);
                X(outputLocation, currentLine, outputChannel+1) = uint16(value);
            end
        else
            X(outputLocation, currentLine, outputChannel) = uint16(value);
        end
        
        if (isInterleaved)
            if (outputChannel == numChannels)
                outputLocation = outputLocation + 1;
                outputChannel = 1;
            else
                outputChannel = outputChannel + 1;
            end
        else
            outputLocation = outputLocation + 1;
        end
        
        newBitStart = rem(bitStart + bitDepth, 32);
        if (newBitStart + bitDepth > 32)
            chunkIsWithinBlock = false;
        else
            chunkIsWithinBlock = true;
        end
        
        if (newBitStart < bitStart)
            currentBlock = currentBlock + 1;
        end
            
        bitStart = newBitStart;
        
    end
end

end


function tf = channelIsSubsampled(file, elementNumber)

switch (getDescriptor(file, elementNumber))
case {7, 100, 101}
    tf = true;
otherwise
    tf = false;
end

end


function padding = paddingAmount(unpaddedLength, blockSize)

padding = rem(blockSize - rem(unpaddedLength, blockSize), blockSize);

end
