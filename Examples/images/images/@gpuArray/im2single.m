function J = im2single(I, varargin)
%IM2SINGLE Convert gpuArray image to single precision.     
%   IM2SINGLE takes the gpuArray image I as input, and returns a gpuArray
%   image of underlying class single. If I is single, then J is identical
%   to it.  If I is not single, then IM2SINGLE returns the equivalent
%   gpuArray image J of underlying class single, rescaling or offsetting
%   the data as necessary.
%
%   I2 = IM2SINGLE(I1) converts the gpuArray intensity image I1 to single
%   precision, rescaling the data if necessary.
%
%   RGB2 = IM2SINGLE(RGB1) converts the truecolor gpuArray image RGB1 to
%   single precision, rescaling the data if necessary.
%
%   I = IM2SINGLE(BW) converts the binary gpuArray image BW to a single-
%   precision intensity image.
%
%   X2 = IM2SINGLE(X1,'indexed') converts the indexed gpuArray image X1 to
%   single precision, offsetting the data if necessary.
%
%   Class Support
%   -------------
%   Intensity and truecolor gpuArray images can be uint8, uint16, double,
%   logical, single, or int16. Indexed gpuArray images can be uint8,
%   uint16, double or logical. Binary input gpuArray images must be
%   logical. The output image is single.
% 
%   Example
%   -------
%       I1 = gpuArray(reshape(uint8(linspace(1,255,25)),[5 5]))
%       I2 = im2single(I1)
%  
%   See also GPUARRAY/IM2DOUBLE, GPUARRAY/IM2INT16, GPUARRAY/IM2UINT8,
%            GPUARRAY/IM2UINT16, GPUARRAY/SINGLE, GPUARRAY.

%   Copyright 2013-2015 The MathWorks, Inc.  

%% inputs

narginchk(1,2);

classIn = classUnderlying(I);
hValidateAttributes(I,...
    {'double','logical','uint8','uint16','int16','single'}, ...
    {'nonsparse'},mfilename,'I',1);


if nargin == 2
  validatestring(varargin{1}, {'indexed'}, mfilename, 'type', 2);
end

%% process

if strcmp(classIn, 'double') || strcmp(classIn, 'logical')
  J = single(I);
  
elseif strcmp(classIn, 'uint8') || strcmp(classIn, 'uint16')
  if nargin == 1
    range = getrangefromclass(I);
    J     = single(I) / range(2);
  elseif nargin==2
    J     = single(I) + 1;
  end
  
elseif strcmp(classIn, 'int16')
  if nargin == 1    
    J = arrayfun(@scaleSingle, I);
  else
    error(message('images:im2single:invalidIndexedImage'));
  end
  
else %single
  J = I;
end

    function pixout = scaleSingle(pixin)
        %J = (single(I) + 32768) / 65535;
        pixout = (single(pixin) + 32768)/65535;
    end

end