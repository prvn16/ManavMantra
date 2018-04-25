classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        audiorecorder < hgsetget
%audiorecorder Audio recorder object.
%   audiorecorder creates an 8000 Hz, 8-bit, 1 channel audiorecorder object.
%   A handle to the object is returned.
%
%   audiorecorder(Fs, NBITS, NCHANS) creates an audiorecorder object with 
%   sample rate Fs in Hertz, number of bits NBITS, and number of channels NCHANS. 
%   Common sample rates are 8000, 11025, 22050, 44100, 48000, and 96000 Hz.
%   The number of bits must be 8, 16, or 24. The number of channels must
%   be 1 or 2 (mono or stereo).
%
%   audiorecorder(Fs, NBITS, NCHANS, ID) creates an audiorecorder object using 
%   audio device identifier ID for input.  If ID equals -1 the default input 
%   device will be used.
%   
% audiorecorder Methods:
%   get            - Query properties of audiorecorder object.
%   getaudiodata   - Create an array that stores the recorded signal values.
%   getplayer      - Create an audioplayer object.
%   isrecording    - Query whether recording is in progress: returns true or false.
%   pause          - Pause recording.
%   play           - Play recorded audio. This method returns an audioplayer object.
%   record         - Start recording.
%   recordblocking - Record, and do not return control until recording completes. 
%                    This method requires a second input for the length of the recording in seconds:
%                    recordblocking(recorder,length)
%   resume         - Restart recording from paused position.
%   set            - Set properties of audiorecorder object.
%   stop           - Stop recording.
%
% audiorecorder Properties:
%   BitsPerSample    - Number of bits per sample. (Read-only)
%   CurrentSample    - Current sample that the audio input device is recording. 
%                      If the device is not recording, CurrentSample is the next 
%                      sample to record with record or resume. (Read-only)
%   DeviceID         - Identifier for audio device. (Read-only)
%   NumberOfChannels - Number of audio channels. (Read-only)
%   Running          - Status of the audio recorder: 'on' or 'off'. (Read-only)
%   SampleRate       - Sampling frequency in Hz. (Read-only)
%   TotalSamples     - Total length of the audio data in samples. (Read-only)
%   Tag              - String that labels the object.
%   Type             - Name of the class: 'audiorecorder'. (Read-only)
%   UserData         - Any type of additional data to store with the object.
%   StartFcn         - Function to execute one time when recording starts.
%   StopFcn          - Function to execute one time when recording stops.
%   TimerFcn         - Function to execute repeatedly during recording. To specify 
%                      time intervals for the repetitions, use the TimerPeriod property.
%   TimerPeriod      - Time in seconds between TimerFcn callbacks.
%   
% audiorecorder Properties (Deprecated):
%   NOTE: audiorecorder ignores any specified values for these properties, 
%         which will be removed in a future release:
%   
%   BufferLength     - Length of buffer in seconds.
%   NumberOfBuffers  - Number of buffers
%
% Example:  
%     Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
%     16 bits, and one channel.  Speak into the microphone, then 
%     pause the recording.  Play back what you've recorded so far.
%     Record some more, then stop the recording. Finally, return
%     the recorded data to MATLAB as an int16 array.
%
%     r = audiorecorder(22050, 16, 1);
%     record(r);     % speak into microphone...
%     pause(r);
%     p = play(r);   % listen
%     resume(r);     % speak again
%     stop(r);
%     p = play(r);   % listen to complete recording
%     mySpeech = getaudiodata(r, 'int16'); % get data as int16 array
%
% See also AUDIOPLAYER, AUDIODEVINFO,  
%          AUDIORECORDER/GET, AUDIORECORDER/SET. 

%    Author(s): BJW, JCS, NCH
%    Copyright 1984-2014 The MathWorks, Inc.
%       

    % --------------------------------------------------------------------
    % General properties 
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private')
        SampleRate       = 8000;  % Sampling Frequency in Hz
        BitsPerSample    = 8;     % Number of Bits per audio Sample
        NumberOfChannels = 1;     % Number of audio channels recording
        DeviceID                  % Identifier for audio device in use.
    end

    properties(GetAccess='public', SetAccess='private', Dependent)
        CurrentSample           % Current sample that the audio input device is recording
        TotalSamples            % Total length of the audio data in samples.
        Running                 % Status of the audio recorder: 'on' or 'off'.
    end

    % --------------------------------------------------------------------
    % Callback Properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='public')
        StartFcn                % Handle to a user-specified callback function that is executed once when playback stops.
        StopFcn                 % Handle to a user-specified callback function that is executed once when playback stops.
        TimerFcn                % Handle to a user-specified callback function that is executed repeatedly (at TimerPeriod intervals) during playback.
        TimerPeriod= 0.05       % Time, in seconds, between TimerFcn callbacks.   
        Tag = '';               % User-specified object label string.
        UserData                % Some user defined data.
    end

    properties(GetAccess='public', SetAccess='private', Transient)
        Type = 'audiorecorder'  % For Backward compatibility
    end
    
    % --------------------------------------------------------------------
    % Unused Legacy Properties
    % These Properties are unused the current audiorecorder
    % But remain for backward compatibility.  These will be removed 
    % in a future release.
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='public', Hidden)
        BufferLength   = [];   % To be removed in a future release
        NumberOfBuffers = [];  % To be removed in a future release
    end

    % --------------------------------------------------------------------
    % Persistent internal properties
    % --------------------------------------------------------------------
    properties(GetAccess='private', SetAccess='private')
        HostApiID               % API ID for a particular driver model
        AudioData               % Audio data recorded.
    end
    
    properties(GetAccess='private', SetAccess='private', Dependent)
        AudioDataType           % Type of the audio signal specified in Matlab type. e.g. 'double', 'single' 'int16', 'int8' etc.
    end
 

    % --------------------------------------------------------------------
    % Non persistent, internal properties
    % --------------------------------------------------------------------
    properties(GetAccess='private', SetAccess='private', Transient)
        Channel                 % Source for the audiorecorder
        ChannelListener         % Listener for Channel events
        Timer                   % Timer object created by the user
        TimerListener           % listen to the Timers ExecuteFcn event
        SamplesToRead           % Number of samples to read during record
        StopCalled    = true;   % Has stopped been called
        IsInitialized = false;  % Has the object been correctly initialized
    end

    % --------------------------------------------------------------------
    % Non persistent, internal, dependent
    % --------------------------------------------------------------------
    properties(GetAccess='private', SetAccess='private', Dependent)
        Options                 % Options Structure to pass to obj.Channel
    end

    % --------------------------------------------------------------------
    % Constants
    % --------------------------------------------------------------------
    properties(GetAccess='private', Constant)
        MinimumSampleRate  = 80;
        MaximumSampleRate  = 1e6;
        MinimumTimerPeriod = .001;
        MaximumNumChannels = 2
        DesiredLatency     = 0.025;            % The Desired Latency (in seconds) we want the audio device to run at.
        MaxSamplesToRead   = intmax('uint64'); % The maximum number of samples that can be read in a given recording session
        DefaultDeviceID    = -1;
    end

    % --------------------------------------------------------------------
    % Lifetime
    % --------------------------------------------------------------------
    methods(Access='public')
        function obj = audiorecorder(sampleRate,numBits,numChannels,deviceID)
            narginchk(0,4);

            obj.DeviceID = obj.DefaultDeviceID;

            if nargin == 1 || nargin == 2
                error(message('MATLAB:audiovideo:audiorecorder:incorrectnumberinputs'));
            end
            
            if nargin >= 3
                obj.SampleRate = sampleRate;
                obj.BitsPerSample = numBits;
                obj.NumberOfChannels = numChannels;
            end
            
            if nargin == 4,
                obj.DeviceID = deviceID;
            end
            
            obj.initialize();
            
            % No audio data recorded yet
            obj.AudioData = [];
        end

        function delete(obj)
            if ~obj.IsInitialized
                % obj may be partially initialized
                % during loadobj or if an error occurs
                % in the audiorecorder constructor
                return; 
            end
            
            stop(obj);
   
            obj.uninitialize();
        end

    end

    methods(Static, Hidden)
        %------------------------------------------------------------------
        % Persistence. Forward Declaration.
        %------------------------------------------------------------------        
        obj = loadobj(B)
    end

    methods(Access='private')
        function initialize(obj)
            % Initialize other un-documented properties.
            obj.SamplesToRead = obj.MaxSamplesToRead;

            % Grab the default device.
            obj.HostApiID = multimedia.internal.audio.device.HostApi.Default;
                                   
            % Grab the directory where Converter plugin and device plugin
            % is present. toolboxdir() prefixes correctly if deployed.
            pluginDir = toolboxdir(fullfile('shared','multimedia','bin',...
                computer('arch')));
                                                    
            % Create Channel object and give it
            try
                obj.Channel = asyncio.Channel( ...
                    fullfile(pluginDir, 'audiodeviceplugin'),...
                    fullfile(pluginDir, 'audiomlconverter'),...
                    obj.Options, [Inf, 0]);
            catch exception
                throw(obj.createDeviceException(exception));
            end
            
            
            obj.ChannelListener = event.listener(obj.Channel,'Custom', ...
                 @(src,event)(obj.onCustomEvent(event)));
            
            obj.initializeTimer();

            obj.IsInitialized = true;
        end
        
        function uninitialize(obj)
            obj.uninitializeTimer();    
            
            delete(obj.ChannelListener);
            obj.Channel.close();

            obj.IsInitialized = false;
        end
        
    end

    %----------------------------------------------------------------------
    % Custom Getters/Setters
    %----------------------------------------------------------------------
    methods
        function set.BitsPerSample(obj, value)
            if value ~= 8 && value ~= 16 && value ~= 24,
                error(message('MATLAB:audiovideo:audiorecorder:bitsupport'));
            end

            obj.BitsPerSample = value;
        end

        function set.DeviceID(obj, value)
            if ~(isscalar(value) && ~isinf(value))
                error(message('MATLAB:audiovideo:audiorecorder:NonscalarDeviceID'));
            end
            
            % Get the list of input devices
            devices = multimedia.internal.audio.device.DeviceInfo.getDevicesForDefaultHostApi;
            inputs = devices([devices.NumberOfInputs] > 0);
            
            if (isempty(inputs))
                error(message('MATLAB:audiovideo:audiorecorder:noAudioInputDevice'));
            end
            
            if ~(value==obj.DefaultDeviceID || ismember(value, [inputs.ID]))
                error(message('MATLAB:audiovideo:audiorecorder:InvalidDeviceID'));
            end
            
            obj.DeviceID = value;
        end

        function set.SampleRate(obj, value)
            if value <= obj.MinimumSampleRate || value > obj.MaximumSampleRate
                error(message('MATLAB:audiovideo:audiorecorder:invalidSampleRate', obj.MinimumSampleRate, obj.MaximumSampleRate));
            end

            if ~(isscalar(value) && ~isinf(value))
                error(message('MATLAB:audiovideo:audiorecorder:NonscalarSampleRate'));
            end

            obj.SampleRate = value;
        end

        function set.NumberOfChannels(obj, value)
           if ~isscalar(value) || ~(value > 0 && value <= obj.MaximumNumChannels),
               error(message('MATLAB:audiovideo:audiorecorder:numchannelsupport'));
           end

           obj.NumberOfChannels = value;
        end
        
        function value  = get.CurrentSample(obj)
            if ~obj.isrecording() && obj.StopCalled 
                % stop(obj) was called, reset the current sample
                value = 1; 
            else
                % pause(obj) was called, set to the next sample
                value = obj.TotalSamples + 1;
            end
        end
        
        function value = get.TotalSamples(obj)
            if isempty(obj.Channel)
                value = 0;
            else
                % Initial samples are the total acquired so far
                % plus what is in the Channel's input stream
                value = size(obj.AudioData, 1) + obj.Channel.InputStream.DataAvailable; 

                % If the user has requested a certain number of samples, return the 
                % up to that value (SamplesToRead)
                value = min(value, obj.SamplesToRead);

                value = double(value);
            end
        end
        
        function value = get.AudioDataType(obj)
            switch obj.BitsPerSample
                case 8
                    value = 'uint8';
                case 16
                    value = 'int16';
                case 24
                    value = 'double';
                otherwise
                    error(message('MATLAB:audiovideo:audiorecorder:bitsupport'));
            end                    
        end
        
        function value = get.Running(obj)
            if obj.isrecording()
                value = 'on';
            else
                value = 'off';
            end
        end
        
        function set.StartFcn(obj, value)
            obj.validateFcn(value);                                 
            obj.StartFcn = value;
        end
        
        function set.StopFcn(obj, value)
            obj.validateFcn(value);
            obj.StopFcn = value;
        end
        
        function set.TimerFcn(obj, value)
            obj.validateFcn(value);
            obj.TimerFcn = value;
        end
        
        function set.TimerPeriod(obj, value)
            validateattributes(value, {'numeric'}, {'positive', 'scalar'});
            if(value < obj.MinimumTimerPeriod) 
                 error(message('MATLAB:audiovideo:audiorecorder:invalidtimerperiod'));
            end
            
            obj.TimerPeriod = value;
            obj.Timer.Period = value; %#ok<MCSUP>
         end
        
        function set.Tag(obj, value)
            if ~(ischar(value))
                error(message('MATLAB:audiovideo:audiorecorder:TagMustBeString'));
            end
            obj.Tag = value;
        end

        function value = get.Options(obj)
            import multimedia.internal.audio.device.DeviceInfo;
            import audiovideo.internal.audio.*;
            value.HostApiID = int32(obj.HostApiID);

            if obj.DeviceID == obj.DefaultDeviceID
                value.DeviceID = int32(DeviceInfo.getDefaultInputDeviceID(obj.HostApiID));
            else
                value.DeviceID = int32(obj.DeviceID);
            end

            % InputChannels is a vector of channel indices to record
            value.InputChannels = int32(1:obj.NumberOfChannels);
            value.SampleRate = uint32(obj.SampleRate);
            value.BitsPerSample = uint32(obj.BitsPerSample);
            value.BufferSize = uint32(Converter.secondsToSamples(...
                obj.DesiredLatency, obj.SampleRate));
            value.QueueDuration = uint32(computeQueueDuration(value.BufferSize));
            value.AudioDataType = obj.AudioDataType;
            value.SamplesUntilDone = obj.SamplesToRead - obj.TotalSamples;
        end
    end
    
    %----------------------------------------------------------------------
    % Function Callbacks/Helper Functions
    %----------------------------------------------------------------------
    methods(Access='private')  
        
        function executeTimerCallback(obj, ~, ~)  
            internal.Callback.execute(obj.TimerFcn, obj);
        end
        
        function onCustomEvent(obj, event)
            % Process any custom events from the Channel
            switch event.Type
                case 'StartEvent'
                    obj.startTimer();
                case 'DoneEvent'
                    stop(obj); % stop if we are done
            end
        end
        
    end
    
    
    %----------------------------------------------------------------------
    % Timer related functionality
    %----------------------------------------------------------------------
    methods(Access='private')  
        function initializeTimer(obj)
            obj.Timer = internal.IntervalTimer(obj.TimerPeriod);

            obj.TimerListener = event.listener(obj.Timer, 'Executing', ...
                @obj.executeTimerCallback);
        end
        
        function uninitializeTimer(obj)
            if(isempty(obj.Timer) || ~isvalid(obj.Timer))
                return;
            end
            
            delete(obj.TimerListener);
        end
        
        function startTimer(obj)
            if isempty(obj.TimerFcn)
                return;
            end
            
            start(obj.Timer);
        end
        
        function stopTimer(obj)
            if isempty(obj.TimerFcn)
                return;
            end
            
            stop(obj.Timer);
        end
    end
    
    %----------------------------------------------------------------------        
    % Helper Functions
    %----------------------------------------------------------------------
    methods(Access='private', Static)
        function validateFcn(fcn)
            if ~internal.Callback.validate(fcn)
                error(message('MATLAB:audiovideo:audiorecorder:invalidfunctionhandle'));
            end
        end
  
        function exp = createDeviceException(exception)
            msg = strrep(exception.message, 'PortAudio', 'Device');
            exp = MException('MATLAB:audiovideo:audiorecorder:DeviceError', msg);
        end
    end
    
    methods(Access='private')
   
        function settableProps = getSettableProperties(obj)
            % Returns a list of publicly settable properties.
            % TODO: Reduce to fields(set(obj)) when g449420 is done.
            settableProps = {};
            props = fieldnames(obj);
            for ii=1:length(props)
                p = findprop(obj, props{ii});
                if strcmpi(p.SetAccess,'public')
                    settableProps{end+1} = props{ii}; %#ok<AGROW>
                end
            end
        end
        
    end
    
    %----------------------------------------------------------------------        
    % audiorecorder Functions
    %----------------------------------------------------------------------
    methods(Access='public')
        function c = horzcat(varargin)
            %HORZCAT Horizontal concatenation of audiorecorder objects.
            
            if (nargin == 1)
                c = varargin{1};
            else
                error(message('MATLAB:audiovideo:audiorecorder:noconcatenation'));
            end
        end
        
        function c = vertcat(varargin)
            %VERTCAT Vertical concatenation of audiorecorder objects.
            
            if (nargin == 1)
                c = varargin{1};
            else
                error(message('MATLAB:audiovideo:audiorecorder:noconcatenation'));
            end
        end
        
        function status = isrecording(obj)
            %ISRECORDING Indicates if recording is in progress.
            %
            %    STATUS = ISRECORDING(OBJ) returns true or false, indicating
            %    whether recording is or is not in progress.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET,
            %             AUDIORECORDER/SET.

            status = ~isempty(obj.Channel) && obj.Channel.isOpen();
        end
        
        function stop(obj)
            %STOP Stops recording in progress.
            %
            %    STOP(OBJ) stops the current recording.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET,
            %             AUDIORECORDER/SET, AUDIORECORDER/RECORD,
            %             AUDIORECORDER/RECORDBLOCKING, AUDIORECORDER/PAUSE,
            %             AUDIORECORDER/RESUME

            obj.StopCalled = true;
            pause(obj);
        end
        
        function pause(obj)
            %PAUSE Pauses recording in progress.
            %
            %    PAUSE(OBJ) pauses recording.  Use RESUME or RECORD to resume
            %    recording.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET,
            %             AUDIORECORDER/SET, AUDIORECORDER/RESUME,
            %             AUDIORECORDER/RECORD.
            
            %    JCS
            %    Copyright 2003-2014 The MathWorks, Inc.
            
            
            if ~isrecording(obj)
                return;
            end
            
            obj.Channel.close();
            obj.stopTimer();
            
            internal.Callback.execute(obj.StopFcn, obj);
        end
        
        function resume(obj)
            %RESUME Resumes paused recording.
            %
            %    RESUME(OBJ) continues recording from paused location.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET,
            %             AUDIORECORDER/SET, AUDIORECORDER/PAUSE.
            
            if (obj.isrecording())
                return;
            end

            if (obj.StopCalled)
                obj.StopCalled = false;
                
                % Remove any buffered data from a previous call to record
                obj.AudioData = [];
                obj.Channel.InputStream.flush();
            end
            
            %Execute StartFcn
            internal.Callback.execute(obj.StartFcn, obj);
            
            try
                obj.Channel.open(obj.Options);
            catch exception
                throw(obj.createDeviceException(exception));
            end
        end
        
        function record(obj, numSeconds)
            %RECORD Record from audio device.
            %
            %    RECORD(OBJ) begins recording from the audio input device.
            %
            %    RECORD(OBJ, T) records for length of time, T, in seconds.
            %
            %    Use the RECORDBLOCKING method for synchronous recording.
            %
            %    Example:  Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
            %              16 bits, and one channel.  Speak into the microphone, then
            %              stop the recording.  Play back what you've recorded so far.
            %
            %       r = audiorecorder(22050, 16, 1);
            %       record(r);     % speak into microphone...
            %       stop(r);
            %       p = play(r);   % listen to complete recording
            %
            %    See also AUDIORECORDER, AUDIORECORDER/PAUSE,
            %             AUDIORECORDER/STOP, AUDIORECORDER/RECORDBLOCKING.
            %             AUDIORECORDER/PLAY, AUDIORECORDER/RESUME.
            
            if isrecording(obj)
                return;
            end
            
            narginchk(1,2);

            if nargin == 2
                if isempty(numSeconds) || ~isnumeric(numSeconds) || (numSeconds <= 0)
                       error(message('MATLAB:audiovideo:audiorecorder:recordTimeInvalid'));
                end
                obj.SamplesToRead = uint64(numSeconds * obj.SampleRate);
                if (~obj.StopCalled)
                     obj.SamplesToRead = obj.SamplesToRead + obj.TotalSamples;
                end
            else
                obj.SamplesToRead = obj.MaxSamplesToRead;
            end
         
            resume(obj);
        end
        
        function recordblocking(obj, numSeconds)
            %RECORDBLOCKING Synchronous recording from audio device.
            %
            %    RECORDBLOCKING(OBJ, T) records for length of time, T, in seconds;
            %                           does not return until recording is finished.
            %
            %    Use the RECORD method for asynchronous recording.
            %
            %    Example:  Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
            %              16 bits, and one channel.  Speak into the microphone, then
            %              stop the recording.  Play back what you've recorded so far.
            %
            %       r = audiorecorder(22050, 16, 1);
            %       recordblocking(r, 5);     % speak into microphone...
            %       p = play(r);   % listen to complete recording
            %
            %    See also AUDIORECORDER, AUDIORECORDER/PAUSE,
            %             AUDIORECORDER/STOP, AUDIORECORDER/RECORD.
            %             AUDIORECORDER/PLAY, AUDIORECORDER/RESUME.
            
            %    Copyright 2003-2014 The MathWorks, Inc.
            %      
            
            % Error checking.
            if ~isa(obj, 'audiorecorder')
                error(message('MATLAB:audiovideo:audiorecorder:noAudiorecorderObj'));
            end
            
            narginchk(2,2);
            
            try
                record(obj, numSeconds);
            catch exception
                throwAsCaller(exception);
            end
            
            pause(numSeconds);
            
            % Wait until recorder is really stopped
            while obj.isrecording()
                pause(0.01);
            end    
        end
        
        function data = getaudiodata(obj, dataType)
            %GETAUDIODATA Gets recorded audio data in audiorecorder object.
            %
            %    GETAUDIODATA(OBJ) returns the recorded audio data as a double array
            %
            %    GETAUDIODATA(OBJ, DATATYPE) returns the recorded audio data in
            %    the data type as requested in string DATATYPE.  Valid data types
            %    are 'double', 'single', 'int16', 'uint8', and 'int8'.
            %
            %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/RECORD.
            
            narginchk(1,2);
            
            if nargin == 1
                dataType = 'double';
            end
            
            if ~ischar(dataType)
                error(message('MATLAB:audiovideo:audiorecorder:unsupportedtype'));
            end
            
            % First, check to see that the datatype requested is supported.
            if ~any(strcmp(dataType, {'double', 'single', 'int16', 'uint8', 'int8'}))
                error(message('MATLAB:audiovideo:audiorecorder:unsupportedtype'));        
            end
            
            % Read all data from the input stream and append it to
            % obj.AudioData
            [newData, countRead, err] = obj.Channel.InputStream.read();
            if ~isempty(err)
                error(message('MATLAB:audiovideo:audiorecorder:ChannelReadError'));
            end
            
            if (countRead~=0)
                % Append new data to our internal data array
                obj.AudioData = [obj.AudioData; newData];
            end
            
            if size(obj.AudioData, 1) > obj.SamplesToRead
                % More data has come in than requested
                % Truncate the data to the size requested
                obj.AudioData = obj.AudioData(1:double(obj.SamplesToRead), :);
            end
            
            if (isempty(obj.AudioData))
                error(message('MATLAB:audiovideo:audiorecorder:recorderempty'));
            end
            
            % Convert data to requested dataType.
            % Conversion function is the capitalized datatype ('Double','Single',etc)
            % prepended by 'to'.
            % Example: 'double' becomes 'toDouble'
            convertFcn = ['to' upper(dataType(1)) dataType(2:end)];
            
            data = audiovideo.internal.audio.Converter.(convertFcn)(obj.AudioData);
        end
        
        function ap = getplayer(obj)
            %GETPLAYER Gets associated audioplayer object.
            %
            %    GETPLAYER(OBJ) returns the audioplayer object associated with
            %    this audiorecorder object.
            %
            %    See also AUDIORECORDER, AUDIOPLAYER.

            ap = audioplayer(obj);
        end

        function player = play(obj, varargin)
        %PLAY Plays recorded audio samples in audiorecorder object.
        %
        %    P = PLAY(OBJ) plays the recorded audio samples at the beginning and
        %    returns an audioplayer object.
        %
        %    P = PLAY(OBJ, START) plays the audio samples from the START sample and
        %    returns an audioplayer object.
        %
        %    P = PLAY(OBJ, [START STOP]) plays the audio samples from the START
        %    sample until the STOP sample and returns an audioplayer object.
        %
        %    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/GET, 
        %             AUDIORECORDER/SET, AUDIORECORDER/RECORD.

            narginchk(1,2);
            
            player = obj.getplayer();
            play(player, varargin{:})
        end
        
    end
end
