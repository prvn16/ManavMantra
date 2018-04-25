function im = imcomplement(im) %#codegen
%IMCOMPLEMENT Complement image.

% Copyright 2012 The MathWorks, Inc.

% 64 bit integers are not supported.
validateattributes(im,...
    {'logical','int8','uint8','int16','uint16','int32','uint32','single','double'},...
    {'nonsparse','real'},...
    'imcomplement');

if(islogical(im))
    im = ~im;
    
elseif(isa(im,'uint8') || isa(im,'uint16') || isa(im,'uint32'))
    im = intmax(class(im)) - im;
    
elseif(isa(im,'int8')  || isa(im,'int16')  || isa(im,'int32'))
    im = bitcmp(im);
else
    % should be a float
    im = 1 - im;
    
end

end