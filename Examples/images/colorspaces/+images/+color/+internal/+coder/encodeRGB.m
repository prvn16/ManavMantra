function [encodedR,encodedG,encodedB] = encodeRGB( ...
    unencodedR,unencodedG,unencodedB,outputType_) %#codegen
%encodeRGB Encode unencoded RGB values into single, double, uint8 or uint16

%   Copyright 2015 The MathWorks, Inc.

coder.internal.prefer_const(outputType_);

validateattributes(unencodedR,{'single','double'}, ...
    {'real'},mfilename,'encodedR',1);
validateattributes(unencodedG,{'single','double'}, ...
    {'real'},mfilename,'encodedG',2);
validateattributes(unencodedB,{'single','double'}, ...
    {'real'},mfilename,'encodedB',3);

outputType = validatestring(outputType_, ...
    {'single','double','uint8','uint16'},mfilename);

if ~strcmp(outputType(1),'u')
    % input is single or double
    encodedR = cast(unencodedR,outputType);
    encodedG = cast(unencodedG,outputType);
    encodedB = cast(unencodedB,outputType);
else
    % outputType is uint8 or uint16
    encodedR = cast(unencodedR * cast(intmax(outputType),'like',unencodedR),outputType);
    encodedG = cast(unencodedG * cast(intmax(outputType),'like',unencodedR),outputType);
    encodedB = cast(unencodedB * cast(intmax(outputType),'like',unencodedR),outputType);
end