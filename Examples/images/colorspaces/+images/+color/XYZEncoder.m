classdef XYZEncoder < images.color.ColorEncoder
    % XYZEncoder Encode and decode XYZ color values
    %
    % An XYZ encoder can encode floating-point XYZ color values into uint16 values as specified by
    % ICC.1:2010 (Profile version 4.3.0.0). In this encoding, XYZ values are scaled to form uint16
    % values so that 0.0 maps to 0, 1.0 maps to 32768, and 1.0 + (32767/32768) maps to 65535.
    %
    % An XYZ encoder can also decode uint16 values to produce floating-point, unencoded XYZ values.
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties (Constant)
        EncoderFunctionTable = struct( ...
            'uint16', @encodeToUint16, ...
            'single', @single, ...
            'double', @double)
        
        DecoderFunctionTable = struct( ...
            'uint16', @decodeFromUint16, ...
            'single', @identity, ...
            'double', @identity)
    end
end

function out = encodeToUint16(in)
out = uint16(65535 * (in / (1 + (32767/32768))));
end

function out = decodeFromUint16(in)
out = (double(in)/65535) * (1 + (32767/32768));
end

function out = identity(in)
out = in;
end
