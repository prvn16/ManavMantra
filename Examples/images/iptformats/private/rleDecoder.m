function [decodedData, decodedBytes] = rleDecoder(encodedData, ...
                                              scanlineWidth)
%rleDecoder   Decompress data using HDR adaptive run-length encoding.
%   [decodedData, decodedBytes] = rleCoder(encodedData, scanlineWidth)
%   decompresses the RLE-compressed values in encodedData and places the
%   result in decodedData.  At most scanlineWidth values are decoded,
%   and decodedBytes contains the number of values in encodedData that
%   were used during decompression.

%   Copyright 2007-2013 The MathWorks, Inc.

% Unlike the description in Graphics Gems II.8 (p.89), code values greater
% than 128 correspond to repeated runs, while smaller code values are
% literal dumps. See the following web site for more details: 
% <http://www.andrew.cmu.edu/user/yihuang/radiance_pic/rgbe.html#syntax>.
% The adaptive RLE used by HDR also does not shift code values by one.

if (isempty(encodedData) || (scanlineWidth == 0))
    decodedData = [];
    decodedBytes = 0;
    return
end

% Create a temporary buffer for the decoded data.
decodedData = zeros(1, scanlineWidth, class(encodedData));

% Loop over the compressed data until this part of the scanline is full.
inputPtr = 1;
outputPtr = 1;
while (outputPtr <= scanlineWidth)
    if (encodedData(inputPtr) > 128) 
        
        % A run of the same value.
        runLength = double(encodedData(inputPtr)) - 128;
        
        if ((runLength - 1) > (scanlineWidth - outputPtr))
            
            warning(message('images:rleDecoder:badRunLength'));
            
        end
        
        decodedData(outputPtr:(outputPtr + runLength - 1)) = ...
            encodedData(inputPtr + 1);
        
        inputPtr = inputPtr + 2;
        outputPtr = outputPtr + runLength;
        
    else 
        
        % A run of literal data.
        runLength = double(encodedData(inputPtr));
        inputPtr = inputPtr + 1;
        
        if ((runLength == 0) || ...
            ((runLength - 1) > (scanlineWidth - outputPtr)))
            
            warning(message('images:rleDecoder:badRunLength'));
        
        end
        
        if ((inputPtr + runLength - 1) > numel(encodedData))
            error(message('images:rleDecoder:notEnoughEncodedData'))
        end
        
        decodedData(outputPtr:(outputPtr + runLength - 1)) = ...
            encodedData(inputPtr:(inputPtr + runLength - 1));
        
        inputPtr = inputPtr + runLength;
        outputPtr = outputPtr + runLength;
        
    end
end

decodedBytes = inputPtr - 1;
