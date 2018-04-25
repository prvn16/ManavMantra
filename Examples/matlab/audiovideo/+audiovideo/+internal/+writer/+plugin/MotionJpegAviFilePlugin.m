classdef (Hidden) MotionJpegAviFilePlugin < audiovideo.internal.writer.plugin.AviFilePlugin
    %AviFilePlugin Extension of the IPlugin class to write uncompressed AVI files.
    
    % Copyright 2009-2017 The MathWorks, Inc.
    
    properties
        Quality = 65; % JPEG Quality. Valid values are 1 to 100
    end
        
    methods
        function obj = MotionJpegAviFilePlugin(fileName)
            %AviFilePlugin Construct a AviFilePlugin object.
            %
            %   OBJ = AviFilePlugin(FILENAME) constructs a AviFilePlugin
            %   object pointing to the file specified by FILENAME.  The file
            %   is not created until AviFilePlugin.open() is called.
            %
            %   See also AviFilePlugin/open, AviFilePlugin/close.
            
            obj = obj@audiovideo.internal.writer.plugin.AviFilePlugin(fileName);      
        end
        
         
        function open(obj, options)
            %OPEN Opens the channel for writing.
            %   AviFilePlugin objects must be open prior to calling
            %   writeVideoFrame.
            
           open@audiovideo.internal.writer.plugin.AviFilePlugin(obj, options);
        end    
        
        function writeVideoFrame(obj, data)
            %writeVideoFrame Write a single video frame to the channel.
            %   obj.writeVideoFrame(data) will write a single video frame
            %   to the channel.  

            % defer to our super class
            writeVideoFrame@audiovideo.internal.writer.plugin.AviFilePlugin(obj, data);
        end
        
        function [pluginName, mlConverterName, slConverterName, options] = ...
                                                getChannelInitOptions(obj)
            %GETCHANNELINITOPTIONS 
            %   Override base class to provide custom options.
            pluginName = 'videoaviwriterplugin';
            [mlConverterName, slConverterName] = obj.getConverterName;
            options.OutputFileName = obj.FileName;
            options.FileFormat = 'MotionJpeg';
        end
        
        function [filterName, options] = getFilterInitOptions(obj)
            filterName = 'videotransformfilter';
            options.InputFrameType = 'RGB24PlanarColumn';
            if ~isempty(obj.Channel)
                options.OutputFrameType = obj.Channel.ExpectedFrameType;
            else
                options.OutputFrameType = '';
            end
        end
    end
end

