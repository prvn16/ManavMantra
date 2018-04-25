classdef VideoProperties < handle
    %VideoProperties Default set of properties for an VideoWriter profile.
    %   The VideoProperties class provides a default set of properties for
    %   an VideoWriter profile.  It contains the minimum set of properties
    %   that a profile must expose, as well as default values for those
    %   properties.  Profiles will generally use an extended version of the
    %   VideoProperties class in order to add properties specific to that
    %   profile.
    %    
    %   VideoProperties objects are created automatically by the VideoWriter
    %   class.  User will normally not need to create a VideoProperties
    %   object explicitly.
    %
    %   VideoProperties properties:
    %     BitsPerPixel - Bits per pixel of the output video data
    %     ColorFormat - Color format of the output video data
    %     ColorChannels - Number of color channels in each video frame
    %     Compression - Video Compression Type
    %     Height - Height of the video being created
    %     Width - Width of the video being created
    %     FrameCount - The total number of frames written to the file
    %     FrameRate - Frame rate in frames per second
    %
    %   See also VideoWriter, audiovideo.writer.profile.IProfile.
 
    %   Copyright 2009-2013 The MathWorks, Inc.
    
    %------------------------------------------------------------------
    % Video Properties (in display order)
    %------------------------------------------------------------------
    
    properties(SetAccess=protected)
        ColorChannels % Number of color channels in each video frame
    end
    
    properties (SetAccess=protected, Transient)
        Height = []; % Height of the video being created
        Width = []; % Width of the video being created
        FrameCount = 0; % The total number of frames written to the file
    end        
    
    properties
        FrameRate = 30; % Frame rate in frames per second
    end
 
    properties(SetAccess=protected)
        VideoBitsPerPixel % Bits per pixel of the output video data
        VideoFormat % Color format of the output video data       
        VideoCompressionMethod = 'None'; % Video Compression Type
    end 
    
    properties(Access=protected, Transient)
        IsOpen = false; % Indicate if open has been called yet.
    end
    
    methods(Access=public)
        function obj = VideoProperties(colorFormat, colorChannels, bitsPerPixel)
            %VideoProperties Construct a VideoProperties object.
            %   obj = VideoProperties(format, numChannels, bpp) where
            %   format is the initial value for the ColorFormat property,
            %   numChannels is the number of ColorChannels, and bpp is the
            %   BitsPerPixel property creates a VideoProperties object.
            
            narginchk(3,3);
            
            obj.ColorChannels = colorChannels;
            obj.VideoBitsPerPixel = bitsPerPixel;
            obj.VideoFormat = colorFormat;
        end
    end   
    
    % Property getters and setters
    methods
        function set.FrameRate(obj,value)
            obj.errorIfOpen('FrameRate');            
            validateattributes(value, {'numeric'}, {'positive', 'real', ...
                        'finite', 'scalar', '<=', 1e6}, 'set', 'FrameRate');
            obj.FrameRate = value;
        end
    end
    
    methods (Access=protected)
        function errorIfOpen(obj, propName)
            %errorIfOpen Check if the object is open, and error if it is.
            %   This method is intended to be used from property setters to
            %   throw the correct error if a property is set while the
            %   object is open.
            %
            %   Usage:
            %     obj.errorIfOpen(propertyName);
            
            if (obj.IsOpen)
                error(message('MATLAB:audiovideo:VideoWriter:propertySetAfterOpen', propName, class( obj )));
            end
        end
    end
    
    methods (Access=public, Hidden=true)
        function display(obj)
            % DISPLAY Overload of the display method.
            %    See also display.
            disp(obj);
        end
        function disp(obj)
            % DISP Overload of the disp method.
            %    See also disp.
            getdisp(obj);
        end
        function getdisp(obj)
            % GETDISP Overload of the getdisp method.
            %    See also hgsetget.getdisp.
            fprintf(internal.DisplayFormatter.getDisplayHeader(obj));
            
             % Prints VideoWriter properties
            fprintf(...
               internal.DisplayFormatter.getDisplayCategories(obj,...
                getString(message('MATLAB:audiovideo:VideoWriter:TitleProperties')), ...
                obj.getPropertyNamesForDisp));
            
            fprintf(internal.DisplayFormatter.getDisplayFooter(obj));
        end
        
        function propertyNames = getPropertyNamesForDisp(obj)
            
            % Get the properties of a base VideoProperties object in case we
            % are dealing with a subclass.
            baseVideoProps = properties('audiovideo.writer.properties.VideoProperties');
            
            % Get the properties of the current object.
            currentVideoProps = properties(obj);
            
            % Identify all of the properties that are specific to this
            % object.
            specificProps = setdiff(currentVideoProps, baseVideoProps);
            
            % Put the base class properties first, followed by the subclass
            % properties.
            propertyNames = [baseVideoProps; specificProps]';
        end
        
        function frameWritten(obj, frameData)
            %frameWritten Method called by VideoWriter whenever a frame is written.
            %   This method is intended to be called by the owning VideoWriter
            %   object whenever a frame is written.  The VideoProperties
            %   object will perform whatever updates are necessary at this
            %   time.
            
            if (obj.FrameCount == 0)
                % When the first frame is written, store the height and
                % width.
                obj.Height = frameData.Height;
                obj.Width = frameData.Width;
            end
            obj.FrameCount = obj.FrameCount + 1;
        end
        
        function open(obj)
            
            if (obj.IsOpen) 
                return;
            end
            obj.FrameCount = 0;
            obj.Height = [];
            obj.Width = [];
            
            obj.IsOpen = true;
            
        end
        
        function close(obj)
            obj.IsOpen = false;
        end
    end    
end

