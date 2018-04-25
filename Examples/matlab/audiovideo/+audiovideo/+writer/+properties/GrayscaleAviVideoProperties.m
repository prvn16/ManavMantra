classdef GrayscaleAviVideoProperties < audiovideo.writer.properties.VideoProperties
    %GrayscaleAviVideoProperties Properties for an Grayscale AVI based profile
    %   GrayscaleAviVideoProperties contains all the properties of a 
    %   VideoProperties object as well as the default colormap for writing
    %   Grayscale AVI files
    
    % Copyright 2012-2013 The MathWorks, Inc.
    
    properties (SetAccess=private, GetAccess=public, Hidden)

    end
    
    methods(Access=public)
        function obj = GrayscaleAviVideoProperties(colorFormat, colorChannels, bitsPerPixel)
            obj@audiovideo.writer.properties.VideoProperties(colorFormat, colorChannels, bitsPerPixel);
        end
    end
end