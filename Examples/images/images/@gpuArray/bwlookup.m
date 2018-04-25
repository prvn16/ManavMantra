function B = bwlookup(A, lut)
%bwlookup Neighborhood operations using lookup tables.
%   A = bwlookup(BW,LUT) performs a 2-by-2 or 3-by-3 nonlinear neighborhood
%   filtering operation on the gpuArray BW containing a binary image. LUT
%   can be a numeric or gpuArray vector containing the 16-element or
%   512-element lookup table.
%
%   Example:
%   --------
%   lut = makelut('sum(x(:)) == 4', 2);
%   BW1 = gpuArray(imread('text.png'));
%   BW2 = bwlookup(BW1,lut);
%   figure, imshow(BW2)
%
%   See also BWLOOKUP, GPUARRAY.

%   Copyright 2012-2016 The MathWorks, Inc.


%% input argument checks
A   = gpuArray(A);
lut = gpuArray(lut);

hValidateAttributes(A,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','2d','nonsparse'},mfilename,'A',1);
hValidateAttributes(lut,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','vector','nonsparse'},mfilename,'LUT',2);


%% 2x2 or 3x3
if(numel(lut)~=16 && numel(lut)~=512)
    error(message('images:bwlookup:invalidLUTLength'));
end

gpuDataType = classUnderlying(lut);

if (isempty(A))
    B = gpuArray(cast([], gpuDataType));
    return;
end

%%
if(numel(lut)==512)
    if(~strcmp(classUnderlying(A), 'logical'))
        A = A~=0;
    end
    B = images.internal.gpu.bwlookup(A,lut);
    
else
    if numel(lut) == 16
        indexKernel = gpuArray([8 2;4 1]);
    elseif numel(lut) == 512
        indexKernel = gpuArray([256 32 4; 128 16 2; 64 8 1]);
    end
    
    % conv needs single
    A = single(A ~= 0);

    indexKernel = single(indexKernel);
    convResult  = conv2(A, indexKernel,'same')+1;
    
    B = arrayfun(@lookupIndex, convResult);
end

    function B = lookupIndex(convResult)
        B = lut(convResult);
    end

end
