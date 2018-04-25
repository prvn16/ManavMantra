function J = im2int16(I)
%IM2INT16 Convert gpuArray image to 16-bit signed integers.
%   IM2INT16 takes a gpuArray image I as input, and returns a gpuArray
%   image J of underlying class int16. If I is int16, then J is identical
%   to it.  If I is not int16 then IM2INT16 returns the equivalent gpuArray
%   image J of underlying class int16, rescaling the data as necessary.
%
%   I2 = IM2INT16(I1) converts the gpuArray intensity image I1 to int16,
%   rescaling the data if necessary.
%
%   RGB2 = IM2INT16(RGB1) converts the truecolor image RGB1 to
%   int16, rescaling the data if necessary.
%
%   I = IM2INT16(BW) converts the binary gpuArray image BW to an int16
%   gpuArray intensity image, changing false-valued elements to -32768 and
%   true-valued elements to 32767.
%
%   Class Support
%   -------------
%   Intensity and truecolor gpuArray images can be uint8, uint16, double,
%   logical, single, or int16. Binary input gpuArray images must be
%   logical. The output image is a gpuArray with underlying class int16.
%
%   Example
%   -------
%       I1 = gpuArray(reshape(linspace(0,1,20),[5 4]))
%       I2 = im2int16(I1)
%
%   See also GPUARRAY/IM2DOUBLE, GPUARRAY/IM2SINGLE, GPUARRAY/IM2UINT8,
%            GPUARRAY/IM2UINT16, GPUARRAY/INT16, GPUARRAY.

%   Copyright 2013-2015 The MathWorks, Inc.

classIn = classUnderlying(I);
hValidateAttributes(I,...
    {'int16','uint16','uint8','double','single','logical'}, ...
    {'nonsparse'},mfilename,'I',1);

if(~isreal(I))
    warning(message('images:im2int16:ignoringImaginaryPartOfInput'));
    I = real(I);
end
%% process

if strcmp(classIn,'int16')
    J = I;
    
elseif islogical(I)

    J = arrayfun(@scaleLogicalToint16,I);
    
else
    % double, single, uint8, or uint16
    if ~strcmp(classIn, 'uint16')
        if strcmp(classIn, 'double')
            J = arrayfun(@grayto16double,I);
        elseif strcmp(classIn, 'single')
            J = arrayfun(@grayto16single,I);
        elseif strcmp(classIn, 'uint8')
            J = arrayfun(@grayto16uint8,I);
        end
    else
        J = I;
    end
    
    % Convert uint16 to int16.
    J = arrayfun(@uint16toint16,J);
end



function pixout = scaleLogicalToint16(pixin)
%     J     = int16(I)*int16(32767) + int16(~I)*int16(-32768);
      pixout  = int16(pixin)*int16(32767) + int16(pixin==0)*int16(-32768);
      


function b = grayto16uint8(img)
%GRAYTO16 Scale and convert grayscale image to uint16.
%   B = GRAYTO16(A) converts the uint8 array A by scaling the
%   elements of A by 257 and then casting to uint8.

b = bitor(bitshift(uint16(img),8),uint16(img));

function b = grayto16double(img)
%GRAYTO16 Scale and convert grayscale image to uint16.
%   B = GRAYTO16(A) converts the double array A to uint16 by
%   scaling A by 65535 and then rounding.  NaN's in A are converted
%   to 0.  Values in A greater than 1.0 are converted to 65535;
%   values less than 0.0 are converted to 0.

if isnan(img)
    b = uint16(0);
else
    % uint16() rounds DOUBLE and SINGLE values. No need to add 0.5 as in
    % grayto16 MEX code
    img = img * 65535;
    if img > 65535
        img = 65535;
    elseif img < 0
        img = 0;
    end
    b = uint16(img);
    
end


function b = grayto16single(img)
%GRAYTO16 Scale and convert grayscale image to uint16.
%   B = GRAYTO16(A) converts the double array A to uint16 by
%   scaling A by 65535 and then rounding.  NaN's in A are converted
%   to 0.  Values in A greater than 1.0 are converted to 65535;
%   values less than 0.0 are converted to 0.

if isnan(img)
    b = uint16(0);
else
    % uint16() rounds DOUBLE and SINGLE values. No need to add 0.5 as in
    % grayto16 MEX code
    maxVal = single(65535);
    minVal = single(0);
    img = img * maxVal;
    if img > maxVal
        img = maxVal;
    elseif img < minVal
        img = minVal;
    end
    b = uint16(img);
    
end

function z = uint16toint16(img)
%UINT16TOINT16 converts uint16 to int16
%   Z = UINT16TOINT16(I) converts uint16 data (range = 0 to 65535) to int16
%   data (range = -32768 to 32767).

z = int16(int32(img)-int32(32768));
