classdef ICCLab2Encoder < images.color.ColorEncoder
    % ICCLab2Encoder Encode and decode L*a*b* color values
    %
    % An ICC L*a*b* version 2 encoder can encode floating-point L*a*b* color values into uint8
    % values. L* values are multiplied by (255/100), rounded, and converted to uint8. a* and b*
    % values are shifted up by 128.0, rounded, and converted to uint8.
    %
    % The encoder can also encode L*a*b* color values into uint16 values. L* values are multiplied
    % by 65535/(100 + (25500/65280)), rounded, and converted to uint16. a* and b* values are shifted
    % up by 128.0, multiplied by 65535/(255 + (255/256)), rounded, and converted to uint16.
    %
    % The encoded can also decode uint8 and uint16 values to produce floating-point, unencoded
    % L*a*b* values.
    %
    % Reference: ICC.1:2001-04 (File Format for Color Profiles), tables 81 and 82, p. 67.
    
    % Copyright 2014 The MathWorks, Inc.
    
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
out = double(in);
out(:,1) = 100 * (out(:,1) / 255);
out(:,2) = out(:,2) - 128;
out(:,3) = out(:,3) - 128;
end

function out = decodeFromUint16(in)
out = double(in);
out(:,1) = (out(:,1) * (100 + (25500/65280))) / 65535;
out(:,2) = ((out(:,2) * (255 + (255/256))) / 65535) - 128;
out(:,3) = ((out(:,3) * (255 + (255/256))) / 65535) - 128;
end

function out = encodeToUint8(in)
out = uint8([(255 * (in(:,1)/100)) in(:,2)+128 in(:,3)+128]);
end

function out = encodeToUint16(in)
out = in;
out(:,1) = 65535 * out(:,1) / (100 + (25500/65280));
out(:,2) = 65535 * ((128 + out(:,2)) / (255 + (255/256)));
out(:,3) = 65535 * ((128 + out(:,3)) / (255 + (255/256)));
out = uint16(out);
end

function out = identity(in)
out = in;
end

