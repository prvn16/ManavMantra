classdef MPEG4VideoProperties < audiovideo.writer.properties.VideoProperties
   %MPEG4VideoProperties Properties for a MPEG-4 H.254  based profile.
   %   MPEG4VideoProperties contains all the properties of a 
   %   VideoProperties object as well as MPEG-4 H.266 specific properties.
   %
   %   MPEG4VideoProperties Specific Properties:
   %     Quality - Integer from 0 through 100.  
   %               Higher quality numbers result in higher video quality 
   %               and larger file sizes. Lower quality numbers result 
   %               in lower video quality and smaller file sizes.  
   %   
   %   See also VideoWriter, audiovideo.writer.profile.IProfile.
   %   Copyright 2011-2013 The MathWorks, Inc.
    
    properties (Access=public)
        % MPEG-4 H.264 specific properties
        Quality % Quality of Compressed Video
    end
    
    methods(Access=public)
        function obj = MPEG4VideoProperties(colorFormat, colorChannels, bitsPerPixel, quality)
            obj@audiovideo.writer.properties.VideoProperties(colorFormat, colorChannels, bitsPerPixel);
            obj.Quality = quality;
            obj.VideoCompressionMethod = 'H.264';
        end
    end
    
     % Property getters and setters
    methods
        function set.Quality(obj,value)
            obj.errorIfOpen('Quality');
            validateattributes(value, {'numeric'}, ...
                {'integer', 'finite', 'scalar' ...
                 '>=', 0, '<=', 100}, ...
                'set', 'Quality');
            obj.Quality = value;
        end
    end
    
end

