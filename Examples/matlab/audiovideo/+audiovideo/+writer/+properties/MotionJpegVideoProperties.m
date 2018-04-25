classdef MotionJpegVideoProperties < audiovideo.writer.properties.VideoProperties
   %MotionJpegVideoProperties Properties for a Motion JPEG based profile.
   %   MotionJpegVideoProperties contains all the properties of a 
   %   VideoProperties object as well as Motion JPEG specific properties.
   %
   %   MotionJpegVideoProperties Specific Properties:
   %     Quality - Integer from 0 through 100.  
   %               Higher quality numbers result in higher video quality 
   %               and larger file sizes. Lower quality numbers result 
   %               in lower video quality and smaller file sizes.  
   %   
   %   See also VideoWriter, audiovideo.writer.profile.IProfile.
   %   Copyright 2009-2013 The MathWorks, Inc.
    
    properties (Access=public)
        % Motion JPEG specific properties
        Quality = 100 % Quality of Compressed Video
    end
    
    methods(Access=public)
        function obj = MotionJpegVideoProperties(colorFormat, colorChannels, bitsPerPixel, quality)
            obj@audiovideo.writer.properties.VideoProperties(colorFormat, colorChannels, bitsPerPixel);
            obj.Quality = quality;
            obj.VideoCompressionMethod = 'Motion JPEG';
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

