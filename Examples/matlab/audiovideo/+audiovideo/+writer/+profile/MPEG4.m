classdef MPEG4 < audiovideo.writer.profile.IProfile
    %MPEG4 Write MPEG4/H.264 Files.
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        Name = 'MPEG-4';
        Description = getString( message('MATLAB:audiovideo:VideoWriter:MPEG4ProfileDescription'));
    end
    

    properties (Constant)
        % Properties inherited from IProfile
        FileExtensions = {'.mp4', '.m4v'};
    end
    
    properties (Constant, Hidden)
        % Properties inherited from IProfile
        FileFormat = 'mp4';
    end
    
    properties (Constant, Access=private)
        DefaultQuality = 75;
    end
    
    properties (SetAccess=protected)
        % Properties inherited from IProfile
        VideoProperties
    end
    
    properties (Constant, GetAccess=protected)
        Padding = 2 % Amount of width and height padding in pixels
    end
    
    methods (Static, Hidden)
        function valid = isValid()
            % Override IProfile.isValid to determine if MPEG4 is available on this
            % platform
            try
                audiovideo.writer.profile.MPEG4(tempname);
            catch e %#ok<NASGU>
                % This profile failed to be created because 
                % no appropriate plugin was found.  
                valid = false;
                return;
            end
            
            valid = true;
        end
    end
     
    methods
        function prof = MPEG4(fileName)
            if nargin == 0
                fileName = '';
            end
            
            prof = prof@audiovideo.writer.profile.IProfile();
            if ispc
                prof.createPlugin('MP4MediaFoundationPlugin', fileName);
            end
            if ismac
                prof.createPlugin('MP4AVFoundationPlugin', fileName);
            end
            prof.VideoProperties = audiovideo.writer.properties.MPEG4VideoProperties(...
                prof.Plugin.ColorFormat, ...
                prof.Plugin.ColorChannels, ...
                prof.Plugin.BitsPerPixel, ...
                audiovideo.writer.profile.MPEG4.DefaultQuality);
        end
        
        function writeVideoFrame(obj, frame)
            % WRITEVIDEOFRAME override writeVideoFrame to pad incoming 
            % video data.  All MPEG-4 H.264's resolution is required to be
            % an even number.
            
            % pad the incoming data both horizontally and vertically on 
            % a boundary defined by obj.Padding (in pixels)
            [height, width, planes] = size(frame);
            widthPad = rem(width,obj.Padding);
            heightPad = rem(height,obj.Padding);

            if heightPad
                frame = [frame; zeros(obj.Padding-heightPad,width,planes, class(frame))];
            end
            
            if widthPad
                frame = [frame, zeros(size(frame,1),obj.Padding-widthPad,planes, class(frame))];
            end
            
            if (heightPad || widthPad) && obj.VideoProperties.FrameCount == 0
                if  obj.VideoProperties.FrameCount == 0
                    warnstate = warning('query', 'backtrace');
                    warning('off','backtrace');
                    warnCleanup = onCleanup( @()warning(warnstate) );
                    warning(message('MATLAB:audiovideo:VideoWriter:mp4FramePadded'));
                end
            end
            
            obj.writeVideoFrame@audiovideo.writer.profile.IProfile(frame);
        end
        
        function open(obj)
            % OPEN Open the object for writing.
            obj.open@audiovideo.writer.profile.IProfile();
            obj.VideoProperties.open();
            obj.Plugin.open(obj.getPluginOpenOptions);
        end
        
        function isValid = validateFrameSize( obj, width, height )
            % Tests that the specified width and height are valid.
            % For MPEG4 "valid" means that incoming dimension are padded
            % to be a multiple of 2.
            % 
            % Subclasses can override this method to apply further
            % constraints on the frame size
            
            paddedWidth = width + mod(width, obj.Padding);
            paddedHeight = height + mod(height, obj.Padding);
            isValid = paddedWidth  == obj.VideoProperties.Width && ...
                      paddedHeight == obj.VideoProperties.Height;
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

