classdef (Hidden) FrameWrittenEventData < event.EventData
    %FRAMEWRITTENEVENTDATA Event data for the plugin's FrameWrittenEvent
    % event.

    % Copyright 2010-2013 The MathWorks, Inc.
    
    properties
        Width;  % The width of the frame that was written.
        Height; % The height of the frame that was written.
        BitsPerPixel; % The number of bits per pixel.
        ColorChannels; % The number of color channels.
        IsSigned; % True if the data is signed.
    end
    
    methods
        function obj = FrameWrittenEventData(width, height, bpp, colorChannels, signed)
            obj.Width = width;
            obj.Height = height;
            obj.BitsPerPixel = bpp;
            obj.ColorChannels = colorChannels;
            obj.IsSigned = signed;
        end
    end    
end

