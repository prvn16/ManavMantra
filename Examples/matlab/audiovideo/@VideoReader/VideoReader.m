classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
         VideoReader < matlab.mixin.SetGet & matlab.mixin.CustomDisplay
% VIDEOREADER Create a multimedia reader object.
%
%   OBJ = VIDEOREADER(FILENAME) constructs a multimedia reader object, OBJ, that
%   can read in video data from a multimedia file.  FILENAME is a string
%   specifying the name of a multimedia file.  There are no restrictions
%   on file extensions.  By default, MATLAB looks for the file FILENAME on
%   the MATLAB path.
%
%   OBJ = VIDEOREADER(FILENAME, 'P1', V1, 'P2', V2, ...) 
%   constructs a multimedia reader object, assigning values V1, V2, etc. to
%   the specified properties P1, P2, etc. Note that the property value
%   pairs can be in any format supported by the SET function, e.g.
%   parameter-value string pairs, structures, or parameter-value cell array 
%   pairs. 
%
%   Methods:
%     readFrame         - Read the next available frame from a video file.
%     hasFrame          - Determine if there is a frame available to read
%                         from a video file. 
%     getFileFormats    - List of known supported video file formats.
%
%   Properties:
%     Name             - Name of the file to be read.
%     Path             - Path of the file to be read.
%     Duration         - Total length of file in seconds.
%     CurrentTime      - Location from the start of the file of the current
%                        frame to be read in seconds. 
%     Tag              - Generic string for the user to set.
%     UserData         - Generic field for any user-defined data.
%
%     Height           - Height of the video frame in pixels.
%     Width            - Width of the video frame in pixels.
%     BitsPerPixel     - Bits per pixel of the video data.
%     VideoFormat      - Video format as it is represented in MATLAB.
%     FrameRate        - Frame rate of the video in frames per second.
%
%   Example:
%       % Construct a multimedia reader object associated with file
%       % 'xylophone.mp4'.
%       vidObj = VideoReader('xylophone.mp4');
%
%       % Specify that reading should start at 0.5 seconds from the
%       % beginning.
%       vidObj.CurrentTime = 0.5;
%
%       % Create an axes
%       currAxes = axes;
%       
%       % Read video frames until available
%       while hasFrame(vidObj)
%           vidFrame = readFrame(vidObj);
%           image(vidFrame, 'Parent', currAxes);
%           currAxes.Visible = 'off';
%           pause(1/vidObj.FrameRate);
%       end
%  
%   See also AUDIOVIDEO, VIDEOREADER/READFRAME, VIDEOREADER/HASFRAME, MMFILEINFO.                
%

%   Authors: NH DL NV
%   Copyright 2005-2017 The MathWorks, Inc.

    %------------------------------------------------------------------
    % General properties (in alphabetic order)
    %------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Dependent)
        Duration        % Total length of file in seconds.
        Name            % Name of the file to be read.
        Path            % Path of the file to be read.
    end
    
    properties(GetAccess='public', SetAccess='public')
        Tag = '';       % Generic string for the user to set.
        UserData        % Generic field for any user-defined data.
    end
    
    %------------------------------------------------------------------
    % Video properties (in alphabetic order)
    %------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Dependent)
        BitsPerPixel    % Bits per pixel of the video data.
        FrameRate       % Frame rate of the video in frames per second.
        Height          % Height of the video frame in pixels.
        VideoFormat     % Video format as it is represented in MATLAB.
        Width           % Width of the video frame in pixels.
    end
    
    properties(GetAccess='public', SetAccess='public', Dependent)
        CurrentTime     % Location, in seconds, from the start of the 
                        % file of the current frame to be read.
    end
    
    %------------------------------------------------------------------
    % Undocumented properties
    %------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Dependent, Hidden)
        AudioCompression
        NumberOfAudioChannels
        VideoCompression
        % NUMBEROFFRAMES property will be removed in a future release. Use
        % CURRENTTIME property instead. 
        NumberOfFrames      % Total number of frames in the video stream.
    end
       
    %------------------------------------------------------------------
    % Private properties
    %------------------------------------------------------------------
    properties(Access='private')
        % To handle construction on load.
        LoadArgs
        
        % Stores the CurrentTime.
        % This applies to time-based reading only. This reflects the
        % CurrentTime value that was explicitly set by the user.
        InternalCurrentTime = [];
        
        % Next frame index to read
        % This applies to frame-based reading.
        NextFrameIndexToRead = 1;        
        
        StoredFrame = [];
        
        ReadAheadException = [];
    end    
    
    properties(Access='private', Hidden, Transient)
        % Underlying implementation object.
        VideoReaderImpl

        % Flag to determine if frame-based operations are being performed
        % on the file.
        % Once frame-based operations have been enabled, time-based
        % operations are not permitted.
        IsFrameBased = false;
        
        % Flag to determine if time-based operations are being performed
        % on the file.
        % Once time-based operations have been enabled, frame-based
        % operations are not permitted.
        IsStreamingBased = false;
    end
    
    properties(Access='private', Constant)
        % To help support future forward compatibility.
        SchemaVersion = 8.3;
        
        ErrorWarnPrefix = 'MATLAB:audiovideo';
    end
    
    
    %------------------------------------------------------------------
    % Documented methods
    %------------------------------------------------------------------    
    methods(Access='public')
    
        %------------------------------------------------------------------
        % Lifetime
        %------------------------------------------------------------------
        function obj = VideoReader(fileName, varargin)

            % If no file name provided.
            if nargin == 0
                error(message('MATLAB:audiovideo:VideoReader:noFile'));
            end
                        
            % Initialize the object.
            % The duration of the file needs to be determined before the
            % CurrentTime can be set.
            obj.init(fileName);
         
            % Set properties that user passed in.
            if nargin > 1
                set(obj, varargin{:});
            end
        end

        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------        
        inspect(obj)
        
        varargout = readFrame(obj, varargin)
        eof = hasFrame(obj)
        
        %------------------------------------------------------------------        
        % Overrides of builtins
        %------------------------------------------------------------------ 
        c = horzcat(varargin)
        c = vertcat(varargin)
        c = cat(varargin)
    end
    
    methods(Access='public', Hidden)
        varargout = read(obj, varargin)
    end
    
    methods(Static)
        
        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------
        
        function formats = getFileFormats()
            % GETFILEFORMATS
            %
            %    FORMATS = VIDEOREADER.GETFILEFORMATS() returns an object
            %    array of audiovideo.FileFormatInfo objects which are the
            %    formats VIDEOREADER is known to support on the current
            %    platform.
            %
            %    The properties of an audiovideo.FileFormatInfo object are:
            %
            %    Extension   - The file extension for this file format
            %    Description - A text description of the file format
            %    ContainsVideo - The File Format can hold video data
            %    ContainsAudio - The File Format can hold audio data
            %
            
            import matlab.internal.video.PluginManager;
            extensions = PluginManager.getInstance().ReadableFileTypes;
            
            formats = audiovideo.FileFormatInfo.empty();
            for ii=1:length(extensions)
                formats(ii) = audiovideo.FileFormatInfo( extensions{ii}, ...
                                                         VideoReader.translateDescToLocale(extensions{ii}), ...
                                                         true, ...
                                                         false );
            end
            
            % sort file extension
            [~, sortedIndex] = sort({formats.Extension});
            formats = formats(sortedIndex);
        end
    end

    methods(Static, Hidden)
        %------------------------------------------------------------------
        % Persistence
        %------------------------------------------------------------------        
        obj = loadobj(B)
    end

    %------------------------------------------------------------------
    % Custom Getters/Setters
    %------------------------------------------------------------------
    methods
        % Properties that are not dependent on underlying object.
        function set.Tag(obj, value)
            validateattributes( value, {'char'}, {}, 'set', 'Tag');
            obj.Tag = value;
        end
        
        % Properties that are dependent on underlying object.
        function value = get.Duration(obj)
            try
                value = seconds(obj.getImplValue('Duration'));
            catch exception
                VideoReader.handleImplException(exception);
            end
            
            % Duration property is set to empty if it cannot be determined
            % from the video. Generate a warning to indicate this.
            if isempty(value)
                warnState=warning('off','backtrace');
                c = onCleanup(@()warning(warnState));
                warning(message('multimedia:videofile:unknownDuration'));
            end
        end
        function set.Duration(obj, value)
            obj.errorAsNotSettable('Duration', value);
        end
                
        function value = get.Name(obj)
            value = obj.getImplValue('Name');
        end
        function set.Name(obj, value)
            obj.errorAsNotSettable('Name', value);
        end
                
        function value = get.Path(obj)
            value = obj.getImplValue('Path');
        end
        function set.Path(obj, value)
            obj.errorAsNotSettable('Path', value);
        end
                
        function value = get.BitsPerPixel(obj)
            value = obj.getImplValue('BitsPerPixel');
        end
        function set.BitsPerPixel(obj, value)
            obj.errorAsNotSettable('BitsPerPixel', value);
        end
                
        function value = get.FrameRate(obj)
            value = obj.getImplValue('FrameRate');
        end
        function set.FrameRate(obj, value)
            obj.errorAsNotSettable('FrameRate', value);
        end
                
        function value = get.Height(obj)
            value = obj.getImplValue('Height');
        end
        function set.Height(obj, value)
            obj.errorAsNotSettable('Height', value);
        end
        
        function value = get.NumberOfFrames(obj)
            if obj.IsStreamingBased
                error( message('MATLAB:audiovideo:VideoReader:GetNumFramesNotAllowed') );
            end
            
            obj.IsFrameBased = true;
                        
            % Query the infrastructure for the number of frames present in
            % the video file.
            value = obj.getImplValue('NumFrames');
        end
        
        function set.NumberOfFrames(obj, value)
            obj.errorAsNotSettable('NumberOfFrames', value);
        end
                
        function value = get.VideoFormat(obj)
            value = obj.getImplValue('VideoFormat');
        end
        function set.VideoFormat(obj, value)
            obj.errorAsNotSettable('VideoFormat', value);
        end
                
        function value = get.Width(obj)
            value = obj.getImplValue('Width');
        end
        function set.Width(obj, value)
            obj.errorAsNotSettable('Width', value);
        end
                
        function value = get.AudioCompression(obj)
            value = obj.getImplValue('AudioCompression');
        end
        
        function set.AudioCompression(obj, value)
            obj.errorAsNotSettable('AudioCompression', value);
        end
                
        function value = get.NumberOfAudioChannels(obj)
            value = obj.getImplValue('NumAudioChannels');
        end
        
        function set.NumberOfAudioChannels(obj, value)
            obj.errorAsNotSettable('NumberOfAudioChannels', value);
        end
                
        function value = get.VideoCompression(obj)
            value = obj.getImplValue('VideoCompression');
        end
        function set.VideoCompression(obj, value)
            obj.errorAsNotSettable('VideoCompression', value);
        end
        
        function value = get.CurrentTime(obj)
            % This is needed to ensure that the CurrentTime is reported
            % exactly as the value set by the user on all platforms for all
            % file formats. This is to account for the difference in
            % seeking behaviour across platforms and frameworks.
            if ~isempty(obj.InternalCurrentTime)
                value = obj.InternalCurrentTime;
                return;
            end
            
            % After object creation, StoredFrame can be empty only if
            % end-of-file has been reached
            if isempty(obj.StoredFrame)
                value = obj.Duration;
                return;
            end
            
            value = seconds(obj.StoredFrame.Timestamp);
        end
        
        function set.CurrentTime(obj, value)
            if obj.IsFrameBased
                error( message('MATLAB:audiovideo:VideoReader:SetCurrentTimeNotAllowed') );
            end
            
            % If the Duration of the video file is known, then check that
            % the time being seeked to is within the duration.
            if ~isempty(obj.Duration)
                try
                    validateattributes( value, {'double'}, ...
                        {'scalar', 'nonnegative', '<=', obj.Duration}, ...
                        'set', 'CurrentTime');
                catch ME
                    throwAsCaller(ME);
                end
            end          
            
            currentTimeOC = onCleanup( @() set(obj, 'IsStreamingBased', 'true') );
            
            seekToTime(obj, value);
            
            obj.InternalCurrentTime = value;
        end
    end
    
    %------------------------------------------------------------------
    % Overrides for Custom Display
    %------------------------------------------------------------------
    methods (Access='protected')
        function propGroups = getPropertyGroups(~)
            import matlab.mixin.util.PropertyGroup;
            
            propGroups(1) = PropertyGroup( {'Name', 'Path', 'Duration', 'CurrentTime', 'Tag', 'UserData'}, ...
                                           getString( message('multimedia:videofile:GeneralProperties') ) );
                                       
            propGroups(2) = PropertyGroup( {'Width', 'Height', 'FrameRate', 'BitsPerPixel', 'VideoFormat'}, ...
                                           getString( message('multimedia:videofile:VideoProperties') ) );
        end
    end
    
    %------------------------------------------------------------------
    % Overrides for Custom Display when calling get(vidObj)
    %------------------------------------------------------------------
    methods (Hidden)
        function getdisp(obj)
            display(obj);
        end
    end
    
    %------------------------------------------------------------------        
    % Undocumented methods
    %------------------------------------------------------------------
    methods (Access='public', Hidden)
        
        %------------------------------------------------------------------
        % Lifetime
        %------------------------------------------------------------------
        function delete(obj)
            % Delete VideoReader object.
            try
                delete(obj.getImpl());
            catch exception
                VideoReader.handleImplException( exception );
            end
        end
   
        %------------------------------------------------------------------
        % Operations
        %------------------------------------------------------------------
        function result = hasAudio(obj)
            try
                result = obj.getImplValue('HasAudio');
            catch exception
                VideoReader.handleImplException( exception );
            end
        end
        
        function result = hasVideo(obj)
            try
                result = obj.getImplValue('HasVideo');
            catch exception 
                VideoReader.handleImplException( exception );
            end
        end
    end
    
    methods (Static, Access='private')
        
        function handleImplException(implException)
            
            errorID = implException.identifier;
            
            if ~startsWith(errorID, 'multimedia:')
                throwAsCaller(implException);
            end
            
            errorID = replace(errorID, 'multimedia', VideoReader.ErrorWarnPrefix);
            
            throwAsCaller(MException(errorID, implException.message));
        end
        
    end
    
    methods (Static, Access='private', Hidden)
        function fileDesc = translateDescToLocale(fileExtension)
            switch upper(fileExtension)
                case 'M4V'
                    fileDesc = getString(message('MATLAB:audiovideo:VideoReader:formatM4V'));
                case 'MJ2'
                    fileDesc = getString(message('MATLAB:audiovideo:VideoReader:formatMJ2'));
                case 'MOV'
                    fileDesc = getString(message('MATLAB:audiovideo:VideoReader:formatMOV'));
                case 'MP4'
                    fileDesc = getString(message('MATLAB:audiovideo:VideoReader:formatMP4'));
                case 'MPG'
                    fileDesc = getString(message('MATLAB:audiovideo:VideoReader:formatMPG'));
                case 'OGV'
                    fileDesc = getString(message('MATLAB:audiovideo:VideoReader:formatOGV'));
                case 'WMV'
                    fileDesc = getString(message('MATLAB:audiovideo:VideoReader:formatWMV'));
                otherwise
                    % This includes formats such as AVI, ASF, ASX.
                    fileDesc = getString(message('MATLAB:audiovideo:VideoReader:formatGeneric', upper(fileExtension)));
            end
        end
        
        function outputFormat = validateOutputFormat(outputFormat, callerFcn)
            validFormats = {'native', 'default'};
            outputFormat = validatestring( outputFormat, validFormats, callerFcn,'outputformat');
        end
        
        function outputFrames = convertToOutputFormat( inputFrames, inputFormat, outputFormat, colormap)
            switch outputFormat
                case 'default'
                    outputFrames = VideoReader.convertToDefault(inputFrames, inputFormat, colormap);
                case 'native'
                    outputFrames = VideoReader.convertToNative(inputFrames, inputFormat, colormap);
                otherwise
                    assert(false, 'Unexpected outputFormat %s', outputFormat);
            end
        end

        function outputFrames = convertToDefault(inputFrames, inputFormat, colormap)
            if ~ismember(inputFormat, {'Indexed', 'Grayscale'})
                % No conversion necessary, return the native data
                outputFrames = inputFrames;
                return;
            end

            % Return 'Indexed' data as RGB24 when asking for 
            % the 'Default' output.  This is done to preserve 
            % RGB24 compatibility for customers using versions of 
            % VideoReader prior to R2013a.
            outputFrames = zeros(size(inputFrames), 'uint8');

            if strcmp(inputFormat, 'Grayscale')
                for ii=1:size(inputFrames, 4)
                    % Indexed to Grayscale Image conversion (ind2gray) is part of IPT
                    % and not base-MATLAB.
                    tempFrame = ind2rgb( inputFrames(:,:,:,ii), colormap);
                    outputFrames(:,:,ii) = tempFrame(:, :, 1);
                end
            else
                outputFrames = repmat(outputFrames, [1, 1, 3, 1]);
                for ii=1:size(inputFrames, 4)
                    outputFrames(:,:,:,ii) = ind2rgb( inputFrames(:,:,:,ii), colormap);
                end
            end
        end

        function outputFrames = convertToNative(inputFrames, inputFormat, colormap)
            if ~ismember(inputFormat, {'Indexed', 'Grayscale'})
                % No conversion necessary, return the native data
                outputFrames = inputFrames;
                return;
            end

            % normalize the colormap
            colormap = double(colormap)/255;

            numFrames = size(inputFrames, 4);
            outputFrames(1:numFrames) = struct;
            for ii = 1:numFrames
                outputFrames(ii).cdata = inputFrames(:,:,:,ii);
                outputFrames(ii).colormap = colormap;
            end
        end
    end
    
    %------------------------------------------------------------------
    % Helpers
    %------------------------------------------------------------------
    methods (Access='private', Hidden)

        function init(obj, fileName, varargin)
            % Properly initialize the object on construction or load.
                        
            currentTime = [];
            if nargin == 3
                assert( isa(varargin{1}, 'double') && isscalar(varargin{1}), 'Last input argument is the current time');
                currentTime = varargin{1};
            end
                
            % Create underlying implementation.
            try
                % On Linux, computation of timestamps results in frame
                % decoding which might lead to performance regression in
                % few cases. See geck g1643379 for more details. We defer
                % this computation until timestamps are needed. On Windows
                % and Mac, timestamp generation does not affect performance
                % as no frame decoding is done. Based on platform, we pass
                % the appropriate value of 'ComputeTimestampsOnFirstUse'
                % Name-Value option to matlab.internal.VideoReader
                % constructor
                computeTimestampsOnFirstUse = ispc || ismac;
                obj.VideoReaderImpl = matlab.internal.VideoReader(fileName, ...
                                                                  'ComputeTimestampsOnFirstUse', computeTimestampsOnFirstUse);               
            catch exception
                VideoReader.handleImplException( exception );
            end
           
            % Seek to the time location specified
            if ~isempty(currentTime)
                obj.CurrentTime = currentTime;
            else
                % If no time location is specified, pre-roll to the start
                % of the video.
                prerollVideo(obj);
            end
        end
        
        function seekToTime(obj, timeInSecs)
            % As a seek is being performed, the StoredFrame is no longer
            % valid and must be discarded.
            obj.StoredFrame = [];
            
            % Clear any saved exceptions as they are no longer valid
            obj.ReadAheadException = [];
            
            % Store the frame at the location specified
            try
                obj.StoredFrame = readFrameAtPosition(getImpl(obj), seconds(timeInSecs));                   
            catch ME
                % Keep track of the exception generated. This must be
                % thrown, as approprate, when the user attempts to read a
                % frame.
                obj.ReadAheadException = ME;
            end
            obj.InternalCurrentTime = timeInSecs;
        end
        
        function prerollVideo(obj)
            % This method must be called only during object construction.
            % The StoredFrame and ReadAheadException properties are empty
            % at this time.
            
            % Read the next frame in the video stream.
            try
                obj.StoredFrame = readNextFrame(obj.VideoReaderImpl);
            catch ME
                % Keep track of the exception generated. This must be
                % thrown, as approprate, when the user attempts to read a
                % frame.
                obj.ReadAheadException = ME;
            end
        end
        
        function tf = isEofException(obj)
            % Check if the exception generated when reading ahead was due
            % to EOF or a genuine read failure.
            tf = strcmp(obj.ReadAheadException.identifier, 'multimedia:VideoReader:EndOfFile');
        end
        
        function throwNonEofException(obj)
            if ~isempty(obj.ReadAheadException) && ~isEofException(obj)
                ME = obj.ReadAheadException;
                obj.ReadAheadException = [];
                VideoReader.handleImplException(ME);
            end
        end
        
        function flag = hasFrameLite(obj)
            % More frames are available for reading if:
            % a. Cached frame is non-empty AND
            % b. Any exception generated due to caching is not due to EOF
            flag = ~( isempty(obj.StoredFrame) && ...
                      ( isempty(obj.ReadAheadException) || isEofException(obj) ) );
        end
        
        function impl = getImpl(obj)
            impl = obj.VideoReaderImpl;
        end
        
        function value = getImplValue(obj, propName)
            value = obj.getImpl().(propName);
        end
        
        function errorAsNotSettable(obj, propName, value) %#ok<INUSD>
            % All underlying properties are read only. Make the error 
            % the same as a standard MATLAB error when setting externally.
            % TODO: Remove when g449420 is done and used when calling 
            % set() in the constructor.
            err = MException('MATLAB:class:SetProhibited',...
                             'Setting the ''%s'' property of the ''%s'' class is not allowed.',...
                             propName, class(obj));
            throwAsCaller(err);
        end
        
        function [headings, indices] = getCategoryInfo(obj, propNames)
            % Returns headings and property indices for each category.
            headings = {'General Settings' 'Video Settings', 'Audio Settings'};
            indices = {[] [] []};
            for pi=1:length(propNames)
                propInfo = findprop(getImpl(obj), propNames{pi});
                if isempty(propInfo) || strcmpi(propInfo.Category, 'none')
                    category = 'general';
                else
                    category = propInfo.Category;
                end
                switch category
                    case 'general'
                        indices{1}(end+1) = pi;
                    case 'video'
                        indices{2}(end+1) = pi;
                    case 'audio'
                        indices{3}(end+1) = pi;
                end
            end
        end
    end
end
