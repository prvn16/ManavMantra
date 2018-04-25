classdef sRGBLinearEncoder < images.color.ColorEncoder
    % sRGBLinearEncoder Decode linear sRGB values
    
    % Encoder table is not implemented. This class is used for optimizing
    % the decoder computation in rgb2xyz.
    
    % Copyright 2015 The MathWorks, Inc,
    
    properties (Constant)
        EncoderFunctionTable = struct( ...
            'uint8', @notImplemented, ...
            'uint16', @notImplemented, ...
            'single', @notImplemented, ...
            'double', @notImplemented)
            
        DecoderFunctionTable = struct( ...
            'uint8', @decodeFromUint8, ...
            'uint16', @decodeFromUint16, ...
            'single', @linearize, ...
            'double', @linearize)
    end
end

function out = linearize(in)
gamma = 2.4;
a = 1/1.055;
b = 0.055/1.055;
c = 1/12.92;
d = 0.04045;

out = images.color.parametricCurveA(in,gamma,a,b,c,d);

end

function lut = computeUint8LUT
persistent lutOut
if isempty(lutOut)
    lutOut = linearize((0:255)/255);
end
lut = lutOut;
end

function out = decodeFromUint8(in)
out = images.color.internal.uint8ToDoubleLUT(in,computeUint8LUT());
end

function out = decodeFromUint16(in)
out = linearize(double(in) / 65535);
end

function out = notImplemented(~) %#ok<STOUT>
assert(false,'Encoder function is not implemented for sRGB linear encoder.')
end
