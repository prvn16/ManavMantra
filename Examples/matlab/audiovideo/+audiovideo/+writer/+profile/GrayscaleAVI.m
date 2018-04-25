classdef GrayscaleAVI < audiovideo.writer.profile.IProfile
    %GrayscaleAVI Write Grayscale AVI Files. These are Indexed AVI files
    %with a Grayscale colormap.
    
    % Copyright 2012-2013 The MathWorks, Inc.
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        
        Name = 'Grayscale AVI';
        Description = getString(message('MATLAB:audiovideo:VideoWriter:GrayscaleVideoData'));
    end
    properties (Constant)
        % Properties inherited from IProfile
        
        FileExtensions = { '.avi' };
    end
    
    properties (Constant, Hidden)
        % Properties inherited from IProfile
        
        FileFormat = 'avi';
    end
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        
        VideoProperties
    end
    
    methods (Hidden)
        % Public methods that are not generally useful to the end user of a
        % profile object.
        
        function colorspace = getPreferredColorSpace(~)
            % Returns the color space that the profile requires in order to
            % write out the data correctly.
            colorspace = audiovideo.internal.writer.profile.OutputColorFormat.GRAYSCALE;
        end
    end
    
    methods
        function prof = GrayscaleAVI(fileName)
            if nargin == 0
                fileName = '';
            end
            
            prof = prof@audiovideo.writer.profile.IProfile();
            prof.createPlugin('GrayscaleAviFilePlugin', fileName);
            prof.VideoProperties = audiovideo.writer.properties.GrayscaleAviVideoProperties(...
                                        prof.Plugin.ColorFormat, ...
                                        prof.Plugin.ColorChannels, ...
                                        prof.Plugin.BitsPerPixel);
        end
        
        function open(obj)
            % OPEN Open the object for writing.
            obj.open@audiovideo.writer.profile.IProfile();
            obj.VideoProperties.open();
            obj.Plugin.open(obj.getPluginOpenOptions);
        end
        
        function writeVideoFrame(obj, frame)
            % WRITEVIDEOFRAME Write a single frame to the plugin.
            if isstruct(frame)
                obj.Plugin.writeVideoFrame(frame.cdata);
            else
                obj.Plugin.writeVideoFrame(frame);
            end
        end
        
        function options = getPluginOpenOptions(obj)
            % Create an asyncio Channel options structure
            % with format specific properties to be used during
            % open@asyncio.Channel
   
            options.FrameRate = obj.VideoProperties.FrameRate;
            options.Colormap = gray(256);
        end
        
    end
end
