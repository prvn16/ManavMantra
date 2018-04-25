classdef GenericColorEncoder < images.color.ColorEncoder
    % GenericColorEncoder Encode and decode color values
    %
    % A generic color encoder can encode floating-point color values into uint8 values. The
    % floating-point values are multiplied by 255.0, rounded, and converted to uint8. A generic
    % color encoder can also decode uint8 values to produce floating-point, unencoded color values.
    %
    % A generic color encoder can encode floating-point color values into uint16 values. The
    % floating-point values are multiplied by 65535.0, rounded, and converted to uint16. A generic
    % color encoder can also decode uint16 values to produce floating-point, unencoded color values.
    
    % Copyright 2014 The MathWorks, Inc,
    
    properties (Constant)
        EncoderFunctionTable = struct( ...
            'uint8', @encodeToUint8, ...
            'uint16', @encodeToUint16, ...
            'single', @single, ...
            'double', @double)
            
        DecoderFunctionTable = struct( ...
            'uint8', @decodeFromUint8, ...
            'uint16', @decodeFromUint16, ...
            'single', @identity, ...
            'double', @identity)
    end
end

function out = decodeFromUint8(in)
out = double(in) / 255;
end

function out = decodeFromUint16(in)
out = double(in) / 65535;
end

function out = identity(in)
out = in;
end

function out = encodeToUint8(in)
out = uint8(255 * in);
end

function out = encodeToUint16(in)
out = uint16(65535 * in);
end