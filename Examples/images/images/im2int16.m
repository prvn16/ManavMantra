function J = im2int16(I)
%IM2INT16 Convert image to 16-bit signed integers.    
%   IM2INT16 takes an image I as input, and returns an image J of class int16.
%   If I is int16, then J is identical to it.  If I is not int16 then IM2INT16
%   returns the equivalent image J of class int16, rescaling the data as
%   necessary.
%
%   I2 = IM2INT16(I1) converts the intensity image I1 to int16,
%   rescaling the data if necessary.
%
%   RGB2 = IM2INT16(RGB1) converts the truecolor image RGB1 to
%   int16, rescaling the data if necessary.
%
%   I = IM2INT16(BW) converts the binary image BW to an int16 intensity image,
%   changing false-valued elements to -32768 and true-valued elements to 32767.
% 
%   Class Support
%   -------------  
%   Intensity and truecolor images can be uint8, uint16, double, logical,
%   single, or int16. Binary input images must be logical. The output image is
%   int16.
%
%   Example
%   -------
%       I1 = reshape(linspace(0,1,20),[5 4])
%       I2 = im2int16(I1)
%
%   See also IM2DOUBLE, IM2SINGLE, IM2UINT8, IM2UINT16, INT16.  
  
%   Copyright 1993-2013 The MathWorks, Inc.  

validateattributes(I,{'int16','uint16','uint8','double','single','logical'}, ...
              {'nonsparse'}, mfilename, 'I', 1)

if(~isreal(I))
    warning(message('images:im2int16:ignoringImaginaryPartOfInput'));
    I = real(I);
end
          
if isa(I,'int16')
  J = I; 

elseif islogical(I)
  J = int16(I);
  J(I) = 32767;
  J(~I) = -32768;

else
  % double, single, uint8, or uint16
  if ~isa(I, 'uint16')
    % call MEX-file
    J = grayto16mex(I);
  else
    J = I;
  end
  
  % call MEX-file to convert uint16 to int16.
  J = uint16toint16mex(J);
end
