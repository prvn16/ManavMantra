function [unencodedR,unencodedG,unencodedB] = decodeRGB( ...
    encodedR,encodedG,encodedB,outputType_) %#codegen
%decodeRGB Decode encoded RGB values into floating-point (unencoded) values

%   Copyright 2015 The MathWorks, Inc.

coder.internal.prefer_const(outputType_);

validateattributes(encodedR,{'single','double','uint8','uint16'}, ...
    {'real'},mfilename,'encodedR',1);
validateattributes(encodedG,{'single','double','uint8','uint16'}, ...
    {'real'},mfilename,'encodedG',2);
validateattributes(encodedB,{'single','double','uint8','uint16'}, ...
    {'real'},mfilename,'encodedB',3);

outputType = validatestring(outputType_,{'single','double'},mfilename);

% outputType should be single if the input is single and double otherwise,
% but the implementation below works for any output type

if isfloat(encodedR)
    % input is single or double
    unencodedR = cast(encodedR,outputType);
    unencodedG = cast(encodedG,outputType);
    unencodedB = cast(encodedB,outputType);
else
    % input is uint8 or uint16
    unencodedR = cast(encodedR,outputType)/cast(intmax(class(encodedR)),outputType);
    unencodedG = cast(encodedG,outputType)/cast(intmax(class(encodedR)),outputType);
    unencodedB = cast(encodedB,outputType)/cast(intmax(class(encodedR)),outputType);
end