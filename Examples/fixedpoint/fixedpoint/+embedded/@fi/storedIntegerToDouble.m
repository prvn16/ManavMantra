function y = storedIntegerToDouble(this)
%storedIntegerToDouble  Convert the stored integer value of a fi object to built-in double
%   storedIntegerToDouble(A) converts the stored integer value of fixed-point number A to
%   double-precision floating point. 
%
% Note: When the word length is greater than 52 bits, the return value 
%       might have quantization error. Inf is returned when the stored 
%       integer value outside the representable range of built-in double
%
%   See also EMBEDDED.FI/storedInteger

%   Copyright 2011-2012 The MathWorks, Inc.

if isscaleddouble(this)
    y = (double(this)-this.Bias)/this.Slope;
else %isfixed, double, single, boolean
    y = double(stripscaling(this));
end

