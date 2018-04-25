function im = imcomplement(im)
%IMCOMPLEMENT Complement image.
%   IM2 = IMCOMPLEMENT(IM) computes the complement of the gpuArray image
%   IM.  IM can be a binary, intensity, or truecolor image.  IM2 has the
%   same underlying class and size as IM.
%
%   In the complement of a binary image, black becomes white and white
%   becomes black.  For example, the complement of this binary image,
%   true(3), is false(3).  In the case of a grayscale or truecolor image,
%   dark areas become lighter and light areas become darker.
%
%   Note
%   ----
%   If the underlying class of IM is double or single, you can use the
%   expression 1-IM instead of this function.  If IM is logical, you can
%   use the expression ~IM instead of this function.
%
%   Example
%   -------
%       I = gpuArray(imread('glass.png'));
%       J = imcomplement(I);
%       figure, imshow(I), figure, imshow(J)
%
%   See also GPUARRAY/IMABSDIFF, GPUARRAY/IMLINCOMB.

%   Copyright 2013-2015 The MathWorks, Inc.

hValidateAttributes(im,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'}, ...
    {'nonsparse'},...
    'imcomplement');

className = classUnderlying(im);

if(~isreal(im) && ~(strcmp(className,'double')))
    % Only double valued complex images are supported for backwards
    % compatibility.
    error(message('images:imcomplement:complexInput'));
end

switch className
    case 'logical'
        im = ~im;
    case {'uint8','uint16','uint32'}
        im = intmax(className) - im;
    case {'int8','int16','int32'}
        im = -1-im;
    otherwise
        % should be floating point
        im = 1-im;
end
end
