classdef (Hidden) IProfile < matlab.mixin.Heterogeneous & handle
    %IProfile Base class for all VideoWriter profiles.
    %   Profiles are the mechanism used by VideoWriter to define a how data
    %   will be written to disk in certain situations.  Profiles contain a
    %   plugins, which are responsible for actually writing data to disk in
    %   the specified format, as well as properties which define any user
    %   customizable features of the plugin.
    %
    %   Profiles can be created to reflect different file types, such as
    %   avi or mov files, different codecs used to encode the data such as
    %   Motion JPEG or H.264, the default settings for compression, or a
    %   combination of all of these.
    %
    %   See also VideoWriter.

    % Copyright 2009-2013 The MathWorks, Inc.
    
    properties (Abstract, SetAccess=protected)
        %VideoProperties The properties object for the profile.
        %   The VideoProperties property is expected to contain an instance
        %   of an audiovideo.writer.properties.VideoProperties object or a
        %   subclass of that class.
        VideoProperties
        %Name The name of the profile
        Name
        %Description A very brief description of the purpose of the %profile.
        Description
    end
    
    properties (Abstract, Constant)
        %FileExtensions A cell array of the valid file extensions.
        %   This is a cell array of the valid file extensions for the
        %   profile.  The extension should contain the '.' character.
        %
        %   Example:
        %      FileExtensions = {'.avi'};
        FileExtensions
    end
    
    properties (Abstract, Constant, Hidden)
        %FileFormat A brief description of the file format.
        FileFormat
    end

    properties (Hidden, SetAccess=protected)
        %PreferredDataType The data type used by the profile.
        %   The PreferredDataType property is a string representing the
        %   class that the profile expects for input data.  Most profiles
        %   will accept uint8 data since most video files are uint8.  The
        %   VideoWriter object will convert data to this type before calling
        %   the writeVideoFrame method of the plugin.
        PreferredDataType = {'uint8'};
    end
    
    properties(Access=protected)
        %PLUGIN Object responsible for actually writing data to the disk.
        %   The Plugin object is the object that is responsible for writing
        %   data to the disk.  It must be an instance of an object
        %   implementing the audiovideo.internal.writer.plugin.IPlugin
        %   interface.
        Plugin
        
    end
    
    properties(Access=protected, Transient)
        % Handle the FrameWrittenEvent published by the plugin.
        FrameWrittenEventListener
    end
    
    methods
        function prof = IProfile()
        end
        
        function writeVideoFrame(obj, frame)
            % WRITEVIDEOFRAME Write a single frame to the plugin.
            
            % Check if there was any error received when writing any of the
            % previous frames and then throw this error.
            throwErrorIfWriteFailed(obj);
            
            obj.Plugin.writeVideoFrame(frame);
        end
        
        function open(obj)
            
            % Need to check if the frame written event listener is empty.
            % This could happen, for example, if the object was loaded from
            % disk since listeners are not saved.
            if isempty(obj.FrameWrittenEventListener)
                obj.createFrameWrittenEventListener();
            end
        end
        
        function close(obj)
            % CLOSE Close the object and finalize the file.
            
            obj.Plugin.close();
            obj.VideoProperties.close();
        end
        
        function setBufferSize(obj, value)
            % Sets the buffer size on the plugin.  This method can not be
            % called while the VideoWriter object is open and should not be
            % called by users.
            obj.Plugin.BufferSize = value;
        end
        
        function isValid = validateFrameSize( obj, width, height )
            % Tests that the specified width and height are valid.
            % By default "valid" means that these values match
            % the Profiles.VideoProperties width and height.
            % 
            % Subclasses can override this method to apply further
            % constraints on the frame size
            
            isValid = width  == obj.VideoProperties.Width && ...
                      height == obj.VideoProperties.Height;
        end
        
        function pluginPath = getPluginPath(obj)
            % Return the base path of the plugin's underlying asyncio
            % plugin, converter, and fitler 
            pluginPath = obj.Plugin.PluginPath;
        end
        
        function [pluginName, mlConverterName, slConverterName, options] = ...
                                                    getPluginInitOptions(obj)
            % Get the Plugins underlying asyncio plugin, converer, and
            % initialization options.  Used for clients 
            % (like system objects or Simulink blocks) who wish to 
            % create an asyncio channel themselves.
            [pluginName, mlConverterName, slConverterName, options] = obj.Plugin.getChannelInitOptions();
        end
        
        function [filterName, options] = getPluginFilterInitOptions(obj)
            % Get the Plugins underlying asyncio filter and initialization
            % options. Used for clients (like system objects or Simulink 
            % blocks) who wish to create an asyncio channel themselves.
           [filterName, options] = obj.Plugin.getFilterInitOptions();
        end
        
        function throwErrorIfWriteFailed(obj)
            if isWriteError(obj)
                ME = obj.Plugin.AsyncWriteException;
                obj.Plugin.AsyncWriteException = [];
                throwAsCaller(ME);
            end
        end
        
        function waitAndCheckForError(obj)
            while obj.VideoProperties.FrameCount == 0 && ...
                                    isempty(obj.Plugin.AsyncWriteException)
                drawnow('limitrate');
            end
            
            throwErrorIfWriteFailed(obj)
        end
        
        function tf = isWriteError(obj)
            tf = ~isempty(obj.Plugin.AsyncWriteException);
        end
       
    end
    
    methods (Abstract)
        % Overrided by subclasses to return options to be passed to an 
        % asyncio channel for the device plugin returned in
        % getPluginOpenOptions@IProfile.
        options = getPluginOpenOptions(obj);
    end
    
    methods (Static, Hidden)
        function valid = isValid()
            % Return true if a given profile is valid or not.
            %
            % As a Profile subclass, override this method if you need
            % to determine at runtime if the profile is valid or
            % not based upon platform, properties, etc.
            valid = true;
        end
    end

    methods (Hidden)
        % Public methods that are not generally useful to the end user of a
        % profile object.
        
        function colorspace = getPreferredColorSpace(~)
            % Returns the color space that the profile requires in order to
            % write out the data correctly.
            colorspace = audiovideo.internal.writer.profile.OutputColorFormat.RGB;
        end
    end
      
    
    methods (Hidden)
        % Methods inherited from the base class.  These are implemented by
        % delegating the base class but are hidden to simplify the
        % interface.
        
        function res= addlistener(obj, varargin)
            res = addlistener@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= eq(obj, varargin)
            res = eq@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= findobj(obj, varargin)
            res = findobj@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= findprop(obj, varargin)
            res = findprop@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= ge(obj, varargin)
            res = ge@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= gt(obj, varargin)
            res = gt@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= le(obj, varargin)
            res = le@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= lt(obj, varargin)
            res = lt@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= ne(obj, varargin)
            res = ne@matlab.mixin.Heterogeneous(obj, varargin);
        end
        function res= notify(obj, varargin)
            res = notify@matlab.mixin.Heterogeneous(obj, varargin);
        end
    end
    
    methods (Access=protected)
        function createPlugin(obj, pluginName, varargin)
            % Creates the plugin and attaches a listener to the plugin's
            % FrameWrittenEvent.
            obj.Plugin = audiovideo.internal.writer.plugin.(pluginName)(varargin{:});
            obj.createFrameWrittenEventListener();
        end
        
        function onFrameWritten(obj, data)
            % When a frame has been written to disk, notify the
            % VideoProperties object so that the FrameCount can be updated.
            obj.VideoProperties.frameWritten(data);
        end
        
        function createFrameWrittenEventListener(obj)
            obj.FrameWrittenEventListener = event.listener(obj.Plugin, 'FrameWrittenEvent', ...
                @(source, data) obj.onFrameWritten(data));
        end
    end
    
    methods (Static, Sealed, Access=protected)
        function obj = getDefaultScalarElement()
            % getDefaultScalarElement Return a base object of the class type.
            %
            %   This method is used internally to satisfy the requirements for
            %   use of heterogeneous arrays. Since empty profile objects
            %   are not allowed, this method errors.
            error(message('MATLAB:audiovideo:VideoWriter:emptyProfiles'));
        end
    end
    
end

