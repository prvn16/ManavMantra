classdef IndexedAVI < audiovideo.writer.profile.IProfile
    %IndexedAVI Write Indexed AVI Files
    
    % Copyright 2012-2017 The MathWorks, Inc.
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        
        Name = 'Indexed AVI';
        Description = getString(message('MATLAB:audiovideo:VideoWriter:IndexedVideoData'));
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
    
    properties (Access=private, Hidden)
        % Flag to indicate if the colormap was set during the first call to
        % writeVideo
        ColormapSetOnFirstFrameWrite
    end
    
    methods (Hidden)
        % Public methods that are not generally useful to the end user of a
        % profile object.
        
        function colorspace = getPreferredColorSpace(~)
            % Returns the color space that the profile requires in order to
            % write out the data correctly.
            colorspace = audiovideo.internal.writer.profile.OutputColorFormat.INDEXED;
        end
    end
    
    methods
        function prof = IndexedAVI(fileName)
            if nargin == 0
                fileName = '';
            end
            
            prof = prof@audiovideo.writer.profile.IProfile();
            prof.createPlugin('IndexedAviFilePlugin', fileName);
            prof.VideoProperties = audiovideo.writer.properties.IndexedAviVideoProperties(...
                                        prof.Plugin.ColorFormat, ...
                                        prof.Plugin.ColorChannels, ...
                                        prof.Plugin.BitsPerPixel, ...
                                        []);
            prof.ColormapSetOnFirstFrameWrite = false;
        end
        
        function open(obj)
            % OPEN Open the object for writing.
            obj.open@audiovideo.writer.profile.IProfile();
            obj.VideoProperties.open();
            obj.Plugin.open(obj.getPluginOpenOptions);
            obj.ColormapSetOnFirstFrameWrite = false;
        end
                
        function writeVideoFrame(obj, frame)
            % WRITEVIDEOFRAME Write a single frame to the plugin.
            if isempty(obj.VideoProperties.Colormap) 
                if ~isstruct(frame)
                    error(message('MATLAB:audiovideo:VideoWriter:colormapRequiredForIndexed'));
                end
                
                if isempty(frame.colormap)
                    error(message('MATLAB:audiovideo:VideoWriter:colormapRequiredForIndexed'));
                end
                
                obj.VideoProperties.forceSetColormap(frame.colormap);
                obj.Plugin.setColormap(obj.VideoProperties.Colormap);
                obj.ColormapSetOnFirstFrameWrite = true;
            else
                if isstruct(frame)
                    if isempty(frame.colormap)
                        % Do nothing
                    elseif audiovideo.internal.writer.convertColormapToUint8(obj.VideoProperties.Colormap) ...
                            == audiovideo.internal.writer.convertColormapToUint8(frame.colormap)
                        % Do nothing
                    else
                        if obj.ColormapSetOnFirstFrameWrite
                            error(message('MATLAB:audiovideo:VideoWriter:colormapVarying'));
                        else
                            error(message('MATLAB:audiovideo:VideoWriter:colormapModify'));
                        end
                    end
                end
            end
            
            % Verify that the colormap supplied is not incomplete
            % i.e. no pixel in the image has an index greater than
            % the total length of the colormap.
            if isstruct(frame)
                obj.isColormapIncomplete(frame.cdata);
                obj.Plugin.writeVideoFrame(frame.cdata);
            else
                obj.isColormapIncomplete(frame);
                obj.Plugin.writeVideoFrame(frame);
            end
        end
                
        function close(obj)
            obj.close@audiovideo.writer.profile.IProfile();
            
            obj.ColormapSetOnFirstFrameWrite = false;
        end
        
        function options = getPluginOpenOptions(obj)
            % Create an asyncio Channel options structure
            % with format specific properties to be used during
            % open@asyncio.Channel
   
            options.FrameRate = obj.VideoProperties.FrameRate;
            if ~isempty(obj.VideoProperties.Colormap)
                options.Colormap = obj.VideoProperties.Colormap;
            end
        end
    end
    
    methods(Access=private, Hidden)
        function isColormapIncomplete(obj, data)
            numColormapEntries = size(obj.VideoProperties.Colormap, 1);
            if ~isempty(find(data > numColormapEntries, 1) )
                error(message('MATLAB:audiovideo:VideoWriter:incompleteColormap', ...
                                                                numColormapEntries));
            end
        end
    end
end
