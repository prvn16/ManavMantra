function im = imcomplement(im) 
%IMCOMPLEMENT Complement image.
%   IM2 = IMCOMPLEMENT(IM) computes the complement of the image IM.  IM
%   can be a binary, intensity, or truecolor image.  IM2 has the same class and
%   size as IM.
%
%   In the complement of a binary image, black becomes white and white becomes
%   black.  For example, the complement of this binary image, true(3), is
%   false(3).  In the case of a grayscale or truecolor image, dark areas
%   become lighter and light areas become darker.
%
%   Note
%   ----
%   If IM is double or single, you can use the expression 1-IM instead of this
%   function.  If IM is logical, you can use the expression ~IM instead of
%   this function.
%
%   Example
%   -------
%       I = imread('glass.png');
%       J = imcomplement(I);
%       figure, imshow(I), figure, imshow(J)
%
%   See also IMABSDIFF, IMLINCOMB.

%   Copyright 1993-2013 The MathWorks, Inc.

validateattributes(im,...
    {'logical','numeric'},...
    {'nonsparse'},...
    'imcomplement');

if(~isreal(im) && ~isa(im,'double'))
    % Only double valued complex images are supported for backwards
    % compatibility.
    error(message('images:imcomplement:complexInput'));
end

if(islogical(im))
    im = ~im;
    
elseif(isa(im,'uint8')      || isa(im,'uint16') ...
        || isa(im,'uint32') || isa(im,'uint64'))
    im = intmax(class(im)) - im;
    
elseif(isa(im,'int8')       || isa(im,'int16') ...
        || isa(im,'int32')  || isa(im,'int64'))
    im = bitcmp(im);
    
else
    % should be a float
    im = 1 - im;
    
end
