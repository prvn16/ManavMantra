function metadata = dpxinfo(filename)
%dpxinfo   Read metadata about DPX image.
%    METADATA = DPXINFO(FILENAME) reads information about the image
%    contained in a DPX file. FILENAME can contain the absolute path to the
%    file, the name of a file on the MATLAB path, or a relative path.
%    METADATA is a structure containing the file details.
%
%    Digital Picture Exchange (DPX) is an ANSI standard file format
%    commonly used for still frames storage in digital intermediate post-
%    production facilities and film labs.
%
%    Example:
%    metadata = dpxinfo('peppers.dpx')
%
%    See also DPXREAD.

% Copyright 2015-2017 The MathWorks, Inc.

filename = matlab.images.internal.stringToChar(filename);

validateattributes(filename, {'char'}, {'nonempty', 'row'}, mfilename, 'filename', 1)

readImages = false;
[~, rawMetadata] = parseDPX(filename, readImages);

metadata = postProcessMetadata(rawMetadata);

end


function metadata = postProcessMetadata(rawMetadata)
%postProcessMetadata   Convert raw DPX metadata to MATLAB struct.

% Standard imfinfo fields.
metadata.Filename = rawMetadata.AbsoluteFilePath;
[metadata.FileModDate, metadata.FileSize] = getFileDetails(metadata.Filename);
metadata.Format = 'DPX';
metadata.FormatVersion = getFormatVersion(rawMetadata.FormatVersion);
metadata.Width = rawMetadata.PixelsPerLine;
metadata.Height = rawMetadata.LinesPerImageElement;
metadata.BitDepth = computeBitDepth(rawMetadata);
metadata.ColorType = getColorTypeString(rawMetadata);
metadata.FormatSignature = rawMetadata.FormatSignature;
metadata.ByteOrder = getByteOrder(rawMetadata);

% DPX-specific fields.
metadata.Orientation = getOrientation(rawMetadata);
metadata.NumberOfImageElements = rawMetadata.NumberOfImageElements;
metadata.DataSign = unpackDataSign(rawMetadata);
metadata.AmplitudeTransferFunction = unpackTransferCharacteristics(rawMetadata);
metadata.Colorimetry = unpackColorimetricSpecifications(rawMetadata);
metadata.ChannelBitDepths = unpackBitDepths(rawMetadata);
metadata.PackingMethod = unpackPackingMethods(rawMetadata);
metadata.Encoding = unpackEncodings(rawMetadata);

end


function [fileModDate, fileSize] = getFileDetails(filename)

d = dir(filename);
fileModDate = d.date;
fileSize = d.bytes;

end


function formatVersionString = getFormatVersion(formatVersionData)

% The result of reading 0xFF padding bytes is platform dependent. They
% should be removed from the output.
formatVersionData(formatVersionData == char(255)) = char(0);
formatVersionData(formatVersionData == char(65533)) = char(0); % UTF-16 replacement char

idx = strfind(formatVersionData, char(0));

if ~isempty(idx)
    formatVersionData(idx:end) = '';
end

formatVersionString = deblank(formatVersionData);

end


function bitDepth = computeBitDepth(rawMetadata)

bitDepth = rawMetadata.NumberOfChannels * rawMetadata.ImageElementMetadata(1).BitDepth;

end


function colorType = getColorTypeString(rawMetadata)

colorType = '';

persistent imageDescriptorTable
if isempty(imageDescriptorTable)
    
    % See Table 1 in SMPTE 268M-2003.
    imageDescriptorTable = cell(256,1); % Descriptor numbering starts at 0.
    imageDescriptorTable{0 + 1} = 'U1';
    imageDescriptorTable([1 2 3 4 6 7 8 9] + 1) = {'R', 'G', 'B', 'A', 'Y', 'Cb,Cr', 'Z', 'Video'};
    imageDescriptorTable{50 + 1} = 'R,G,B';
    imageDescriptorTable{51 + 1} = 'R,G,B,A';
    imageDescriptorTable{52 + 1} = 'A,B,G,R';
    imageDescriptorTable{100 + 1} = 'Cb,Y,Cr,Y (4:2:2)';
    imageDescriptorTable{101 + 1} = 'Cb,Y,A,Cr,Y,A (4:2:2:4)';
    imageDescriptorTable{102 + 1} = 'Cb,Y,Cr (4:4:4)';
    imageDescriptorTable{103 + 1} = 'Cb,Y,Cr,A (4:4:4:4)';
    imageDescriptorTable{150 + 1} = 'U2';
    imageDescriptorTable{151 + 1} = 'U3';
    imageDescriptorTable{152 + 1} = 'U4';
    imageDescriptorTable{153 + 1} = 'U5';
    imageDescriptorTable{154 + 1} = 'U6';
    imageDescriptorTable{155 + 1} = 'U7';
    imageDescriptorTable{156 + 1} = 'U8';
    
end

for channel = 1:rawMetadata.NumberOfImageElements
    
    descriptor = rawMetadata.ImageElementMetadata(channel).Descriptor;
    thisChannel = imageDescriptorTable{descriptor + 1};
    
    if isempty(thisChannel)
        thisChannel = '?';
    end
    
    colorType = sprintf('%s,%s', colorType, thisChannel);
end

% Remove leading comma.
colorType(1) = '';

end


function byteOrder = getByteOrder(rawMetadata)

switch (rawMetadata.FileEndian)
case 'ieee-le'
    byteOrder = 'Little-endian';
case 'ieee-be'
    byteOrder = 'Big-endian';
end
end


function orientation = getOrientation(rawMetadata)

% See SMPTE 268M-2003 Table 2 "Image orientation code".
switch (rawMetadata.ImageOrientation)
case 0
    orientation = 'Left-to-right, Top-to-bottom';
case 1
    orientation = 'Right-to-left, Top-to-bottom';
case 2
    orientation = 'Left-to-right, Bottom-to-top';
case 3
    orientation = 'Right-to-left, Bottom-to-top';
case 4
    orientation = 'Top-to-bottom, Left-to-right';
case 5
    orientation = 'Top-to-bottom, Right-to-left';
case 6
    orientation = 'Bottom-to-top, Left-to-right';
case 7
    orientation = 'Bottom-to-top, Right-to-left';
otherwise
    orientation = 'Unknown';
end

end


function dataSignCell = unpackDataSign(rawMetadata)

dataSigns = {'Unsigned', 'Signed'}; % 0-based in the file.
zeroBasedIndices = [rawMetadata.ImageElementMetadata.DataSign];
dataSignCell = dataSigns(zeroBasedIndices + 1);

end


function transferCell = unpackTransferCharacteristics(rawMetadata)

% See SMPTE 268M-2003 Table 5A.
transferCharacteristics = {... % 0-based in the file.
    'User defined'
    'Printing density'
    'Linear'
    'Logarithmic'
    'Unspecified video'
    'SMPTE 274M'
    'ITU-R 709-4'
    'ITU-R 601-5 system B or G (625)'
    'ITU-R 601-5 system M (525)'
    'Composite video (NTSC)'
    'Composite video (PAL)'
    'Z (depth) - linear'
    'Z (depth) - homogenous'
    'Unknown'}';

zeroBasedIndices = [rawMetadata.ImageElementMetadata.TransferCharacteristic];
zeroBasedIndices(zeroBasedIndices > 12) = 13;
transferCell = transferCharacteristics(zeroBasedIndices + 1);

end


function colorimetryCell = unpackColorimetricSpecifications(rawMetadata)

% See SMPTE 268M-2003 Table 5B.
colorimetricSpecifications = {... % 0-based in the file.
    'User defined'
    'Printing density'
    'N/A'
    'N/A'
    'Unspecified video'
    'SMPTE 274M'
    'ITU-R 709-4'
    'ITU-R 601-5 system B or G (625)'
    'ITU-R 601-5 system M (525)'
    'Composite video (NTSC)'
    'Composite video (PAL)'
    'N/A'
    'N/A'
    'Unknown'}';

zeroBasedIndices = [rawMetadata.ImageElementMetadata.ColorimetricSpecification];
zeroBasedIndices(zeroBasedIndices > 12) = 13;
colorimetryCell = colorimetricSpecifications(zeroBasedIndices + 1);

end


function channelBitDepths = unpackBitDepths(rawMetadata)

channelBitDepths = [rawMetadata.ImageElementMetadata.BitDepth];

end


function packingMethods = unpackPackingMethods(rawMetadata)

% See SMPTE 268M-2003 Table 3B.
packingMethods = [rawMetadata.ImageElementMetadata.Packing];

end


function encodingCell = unpackEncodings(rawMetadata)

% See SMPTE 268M-2003 Table 3C.
encodings = {'None', 'RLE', 'Unknown'};
zeroBasedIndices = [rawMetadata.ImageElementMetadata.Encoding];
zeroBasedIndices(zeroBasedIndices > 1) = 2;
encodingCell = encodings(zeroBasedIndices + 1);

end
