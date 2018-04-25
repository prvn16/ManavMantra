function J = im2int16(img) %#codegen

% Copyright 2013-2014 The MathWorks, Inc.

validateattributes(img,{'int16','uint16','uint8','double','single','logical'}, ...
    {'nonsparse'}, mfilename, 'img', 1) %#ok<*EMCA>

if ~isreal(img)
    eml_warning('images:im2int16:ignoringImaginaryPartOfInput');
    I = real(img);
else
    I = img;
end

if isa(I,'int16')
    J = I;
elseif islogical(I)
    J = int16(I);
    J(I) = 32767;
    J(~I) = -32768;
else
    if ~isa(I, 'uint16')
        % double, single or uint8
        J = uint16toint16(grayto16(I));
    else
        % uint16
        J = uint16toint16(I);
    end
end
