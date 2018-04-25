classdef MotionJpegAVI < audiovideo.writer.profile.IProfile
    %UncompressedAVI Write uncompressed AVI files.
    
    % Copyright 2009-2017 The MathWorks, Inc.
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        
        Name = 'Motion JPEG AVI';
        Description = getString(message('MATLAB:audiovideo:VideoWriter:MotionJPEGCompression'));
    end
    

    properties (Constant)
        % Properties inherited from IProfile

        FileExtensions = {'.avi'};
    end
    
    properties (Constant, Hidden)
        % Properties inherited from IProfile

        FileFormat = 'avi';
    end
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile

        VideoProperties
    end
    
    methods
        
        function prof = MotionJpegAVI(fileName)
            if nargin == 0
                fileName = '';
            end
            
            prof = prof@audiovideo.writer.profile.IProfile();
            prof.createPlugin('MotionJpegAviFilePlugin', fileName);
            prof.VideoProperties = audiovideo.writer.properties.MotionJpegVideoProperties(...
                prof.Plugin.ColorFormat, ...
                prof.Plugin.ColorChannels, ...
                prof.Plugin.BitsPerPixel, ...
                75);
        end
        
        function open(obj)
            % OPEN Open the object for writing.
            obj.open@audiovideo.writer.profile.IProfile();
            
            obj.VideoProperties.open();
 
            obj.Plugin.open(obj.getPluginOpenOptions);
        end
        
        function options = getPluginOpenOptions(obj)
            % Create an asyncio Channel options structure
            % with format specific properties to be used during
            % open@asyncio.Channel
   
            options.FrameRate = obj.VideoProperties.FrameRate;
            options.Quality = obj.VideoProperties.Quality;
        end
        
    end
end

