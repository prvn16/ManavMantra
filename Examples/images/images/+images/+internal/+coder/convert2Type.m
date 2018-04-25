function y = convert2Type(x,outputClass) %#codegen
%convert2Type  Internal function for use in portable code generation.
%
%     y = convert2Type(x,outputClass) converts the scalar x to the class
%     defined by the string outputClass. x must be a scalar double.
%     outputClass must be one of the following strings: single, double,
%     uint8, uint16, uint32, int8, int16, int32.
%
% Notes: 
%    1. convert2Type is meant to be a MATLAB-for-codegen equivalent of the
%       function of the same name defined in typeconv.hpp.
%    2. convert2Type does not do any input checking. Use at your own risk!
%

% Copyright 2015 The MathWorks, Inc.

coder.inline('always');
coder.internal.prefer_const(x,outputClass);

switch outputClass
    case 'single'
        y = single(x);
    case 'double'
        y = x;
    otherwise
        y = saturateRoundAndCast(x,outputClass);
end

%--------------------------------------------------------------------------
function y = saturateRoundAndCast(x,outputClass)

coder.inline('always');
coder.internal.prefer_const(x,outputClass);

% outputClass is expected to be one of these strings:
%    'uint8', 'uint16', 'uint32', 'int8', 'int16', 'int32'

minVal = intmin(outputClass);
maxVal = intmax(outputClass);

if (x > maxVal)
    y = cast(maxVal,outputClass);
elseif (x < minVal)
    y = cast(minVal,outputClass);
else
    y = roundAndCast(x,outputClass);
end

%--------------------------------------------------------------------------
function y = roundAndCast(x,outputClass)

coder.inline('always');
coder.internal.prefer_const(x,outputClass);

if (x > 0)
    y = eml_cast(x + 0.5, outputClass, 'to zero', 'spill');
elseif (x < 0)
    y = eml_cast(x - 0.5, outputClass, 'to zero', 'spill');
else
    y = cast(0,outputClass);
end
