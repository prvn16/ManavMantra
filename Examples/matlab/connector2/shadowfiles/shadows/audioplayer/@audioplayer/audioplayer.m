classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) ...
        audioplayer < hgsetget
    %audioplayer Audio player object.
    %
    %   audioplayer(Y, Fs) creates an audioplayer object for signal Y, using
    %   sample rate Fs.  A handle to the object is returned.
    %
    %   audioplayer(Y, Fs, NBITS) creates an audioplayer object and uses NBITS
    %   bits per sample for floating point signal Y.  Valid values for NBITS
    %   are 8, 16, and 24.  The default number of bits per sample for floating
    %   point signals is 16.
    %
    %   audioplayer(Y, Fs, NBITS, ID) creates an audioplayer object using
    %   audio device identifier ID for output.  If ID equals -1 the default
    %   output device will be used.
    %
    %   audioplayer(R) creates an audioplayer object from AUDIORECORDER object R.
    %
    %   audioplayer(R, ID) creates an audioplayer object from AUDIORECORDER
    %   object R using audio device identifier ID for output.
    %
    % audioplayer Methods:
    %   get          - Query properties of audioplayer object.
    %   isplaying    - Query whether playback is in progress.
    %   pause        - Pause playback.
    %   play         - Play audio from beginning to end.
    %   playblocking - Play, and do not return control until playback
    %                  completes.
    %   resume       - Restart playback from paused position.
    %   set          - set properties of audioplayer object.
    %   stop         - stop playback.
    %
    % audioplayer Properties:
    %   BitsPerSample    - Number of bits per sample. (Read-only)
    %   CurrentSample    - Current sample that the audio output device
    %                      is playing. If the device is not playing,
    %                      CurrentSample is the next sample to play with
    %                      play or resume. (Read-only)
    %   DeviceID         - Identifier for audio device. (Read-only)
    %   NumberOfChannels - Number of audio channels. (Read-only)
    %   Running          - Status of the audio player: 'on' or 'off'.
    %                      (Read-only)
    %   SampleRate       - Sampling frequency in Hz.
    %   TotalSamples     - Total length of the audio data in samples.
    %                      (Read-only)
    %   Tag              - String that labels the object.
    %   Type             - Name of the class: 'audioplayer'. (Read-only)
    %   UserData         - Any type of additional data to store with
    %                      the object.
    %   StartFcn         - Function to execute one time when playback starts.
    %   StopFcn          - Function to execute one time when playback stops.
    %   TimerFcn         - Function to execute repeatedly during playback.
    %                      To specify time intervals for the repetitions,
    %                      use the TimerPeriod property.
    %   TimerPeriod      - Time in seconds between TimerFcn callbacks.
    %
    % Example:
    %
    %       % Load snippet of Handel's Hallelujah Chorus and play back
    %       % only the first three seconds.
    %       load handel;
    %       p = audioplayer(y, Fs);
    %       play(p, [1 (get(p, 'SampleRate') * 3)]);
    %
    % See also AUDIORECORDER, AUDIODEVINFO, AUDIOPLAYER/GET,
    %          AUDIOPLAYER/SET.

    % Author(s): SM NH DTL
    % Copyright 1984-2013 The MathWorks, Inc.
    %

    % --------------------------------------------------------------------
    % General properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='public')
        SampleRate              % Sampling frequency in Hz.
    end

    properties(GetAccess='public', SetAccess='private')
        BitsPerSample           % Number of bits per audio Sample
        NumberOfChannels        % Number of channels of the device
        DeviceID                % ID of the Device to be used for playback
    end

    % --------------------------------------------------------------------
    % Playback properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Dependent)
        CurrentSample           % Current sample number being played
        TotalSamples            % Total number of samples being played
        Running                 % Is the player in running state
    end

    % --------------------------------------------------------------------
    % Callback Properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='public')
        StartFcn                % Handle to a user-specified callback function executed once when playback starts.
        StopFcn                 % Handle to a user-specified callback function executed once when playback stops.
        TimerFcn                % Handle to a user-specified callback function executed repeatedly (at TimerPeriod intervals) during playback.
        TimerPeriod = 0.05      % Time, in seconds, between TimerFcn callbacks.
        Tag = ''                % User-specified object label string.
        UserData                % Some user defined data.
    end

    properties(GetAccess='public', SetAccess='private', Transient)
        Type = 'audioplayer'    % For backward compatibility
    end

    % --------------------------------------------------------------------
    % Persistent internal properties
    % --------------------------------------------------------------------
    properties(GetAccess='private', SetAccess='private')
        AudioDataType           % Type of the audio signal specified in Matlab type. e.g. 'double', 'single' 'int16', 'int8' etc.
        AudioData               % Audio data to playback.
        HostApiID               % API ID for a particular driver model
    end

    % --------------------------------------------------------------------
    % Non persistent, internal properties
    % --------------------------------------------------------------------
    properties(GetAccess='private', SetAccess='private', Transient)
        Channel                 % Sink for the audioplayer
        ChannelListener         % Listener for Channel events
        StartIndex              % Starting point of the Audio Sample being played
        EndIndex                % Ending point of the Audio Sample being played
        SamplesPlayed           % Number of samples sent to the Device
        Timer                   % Timer object created by the user
        TimerListener           % listener for Timer's ExecuteFcn event
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
    properties(Constant, GetAccess='private')
        MinimumSampleRate  = 80
        MaximumSampleRate  = 1e6
        MinimumTimerPeriod = .001
        MaximumNumChannels = 2
        DesiredLatency     = 0.025 % Set the Latency (in seconds) we want the audio device to run at.
        DefaultDeviceID    = -1
    end

    % --------------------------------------------------------------------
    % Lifetime
    % --------------------------------------------------------------------
    methods(Access='public')
        % External Method Declaration
        play(obj, varargin)

        function obj = audioplayer(varargin)
            narginchk(1,4);
            obj.DeviceID = obj.DefaultDeviceID;

            fromaudiorecorder = isa(varargin{1}, 'audiorecorder');

            % If the Argument 1 is an audiorecorder object.
            if fromaudiorecorder
                % Audioplayer constructor with recorder taken at most 2
                % arguments.
                if(nargin > 2)
                    error(message('MATLAB:audiovideo:audioplayer:numericinputs'));
                end

                recorder = varargin{1};

                obj.BitsPerSample = get(recorder, 'BitsPerSample');
                % In case recorder is empty, use a try-catch.
                try
                    switch obj.BitsPerSample
                        case 8
                            signal = getaudiodata(recorder, 'uint8');
                        case 16
                            signal = getaudiodata(recorder, 'int16');
                        case 24
                            signal = getaudiodata(recorder, 'double');
                        otherwise
                            error(message('MATLAB:audiovideo:audioplayer:invalidbitpersample'));
                    end

                    obj.SampleRate = get(recorder, 'SampleRate');

                catch exception
                    throw(exception);
                end

                if(nargin == 2)
                    % Second argument should be DeviceID
                    % TODO: Yet to decide the DeviceID shift logic
                    if isnumeric(varargin{2})
                        obj.DeviceID = varargin{2};
                    else
                        error(message('MATLAB:audiovideo:audioplayer:invaliddeviceID'));
                    end
                end

            else % Signal doesn't come from audiorecorder.
                if(nargin == 1)
                    error(message('MATLAB:audiovideo:audioplayer:mustbeaudiorecorder'));
                end

                try
                    audioplayer.checkNumericArgument(varargin{:});
                    signal = varargin{1};
                    obj.SampleRate = varargin{2};
                    if(nargin >= 3)
                        obj.BitsPerSample = varargin{3};
                    else
                        obj.BitsPerSample = audioplayer.getBitsPerSampleForThisSignal(signal);
                    end

                    if(nargin == 4)
                        obj.DeviceID = varargin{4};
                    end
                catch exception
                    throw(exception);
                end
            end
            obj.AudioData = signal;
            obj.initialize();
        end

        function delete(obj)
            if isempty(obj.Channel)
                % obj may be partially initialized during loadbobj,
                % or during an error in the constructor
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

    methods(Access='public', Hidden)
        function clearAudioData(obj)
            if obj.isplaying
                return; % disallowed during playback
            end

            % Remove all audio data
            obj.AudioData = [1 1];
        end
    end

    methods(Access='private')
        function initialize(obj)
            if obj.hasNoAudioHardware()
                return;
            end
            % Dont create a real device

            % Initialize other un-documented properties.

            % Grab the default device.
            obj.HostApiID = multimedia.internal.audio.device.HostApi.Default;

            obj.AudioDataType = class(obj.AudioData);

            % Initialize other documented/Hidden properties
            obj.NumberOfChannels = size(obj.AudioData,2);
            obj.StartIndex = 1;
            obj.EndIndex = obj.TotalSamples;

            % Grab the directory where Converter plugin and device plugin
            % is present.
            pluginDir = fullfile(matlabroot,'toolbox','shared','multimedia','bin',...
                computer('arch'));

            % Create Channel object and give it
            try
                obj.Channel = asyncio.Channel( ...
                    fullfile(pluginDir, 'audiodeviceplugin'),...
                    fullfile(pluginDir, 'audiomlconverter'),...
                    obj.Options, [0, Inf]);

            catch exception
                throw(obj.createDeviceException(exception));
            end


            obj.ChannelListener = event.listener(obj.Channel,'Custom', ...
               @(src,event)(obj.onCustomEvent(event)));

            % Never timout when waiting on the output stream
            obj.Channel.OutputStream.Timeout = Inf;

        end

        function uninitialize(obj)
            obj.uninitializeTimer(); %make sure timer object is cleaned up

            obj.Channel.close();

            delete(obj.ChannelListener);
            obj.ChannelListener = [];
        end
    end

    %----------------------------------------------------------------------
    % Custom Getters/Setters
    %----------------------------------------------------------------------
    methods
        function set.BitsPerSample(obj, value)
            % Check for valid BitsPerSample
            if ~isscalar(value)
                error(message('MATLAB:audiovideo:audioplayer:nonscalarBitsPerSample'));
            end

            if value ~= 8 && value ~= 16 && value ~= 24
                error(message('MATLAB:audiovideo:audioplayer:bitsupport'));
            end

            obj.BitsPerSample = value;
        end

        function set.DeviceID(obj, value)
            if ~(isscalar(value) && ~isinf(value))
                error(message('MATLAB:audiovideo:audioplayer:nonscalarDeviceID'));
            end

            % Get the list of output devices
            deviceInfos = multimedia.internal.audio.device.DeviceInfo.getDevicesForDefaultHostApi;
            outputInfos = deviceInfos([deviceInfos.NumberOfOutputs] > 0);

            if ~(value==obj.DefaultDeviceID || ismember(value, [outputInfos.ID]))
                error(message('MATLAB:audiovideo:audioplayer:invaliddeviceID'));
            end

            obj.DeviceID = value;
        end

        function set.SampleRate(obj, value)
            % check for valid sample rate
            if value < obj.MinimumSampleRate || value > obj.MaximumSampleRate
                error(message('MATLAB:audiovideo:audioplayer:invalidSampleRate', obj.MinimumSampleRate, obj.MaximumSampleRate));
            end

            if ~(isscalar(value) && ~isinf(value))
                error(message('MATLAB:audiovideo:audioplayer:nonscalarSampleRate'));
            end

            sampleRateChanged = obj.SampleRate ~= value;
            obj.SampleRate = value;

            if obj.isplaying() && sampleRateChanged
                % Player is already playing. Stop it and restart it so
                % that new rate is passed down the channel to the device.
                pause(obj);

                % Get the Current Sample Before calling stop
                startPosition = obj.CurrentSample; %#ok<MCSUP>

                stop(obj);
                play(obj, [startPosition obj.EndIndex]); %#ok<MCSUP>
            end
        end

        function set.NumberOfChannels(obj, value)
            if ~(value > 0 && value <= obj.MaximumNumChannels)
                error(message('MATLAB:audiovideo:audioplayer:invalidnumberofchannels'));
            end
            obj.NumberOfChannels = value;
        end

        function set.AudioData(obj, value)
            if ~isnumeric(value)
                error(message('MATLAB:audiovideo:audioplayer:invalidsignal'));
            end

            if isempty(value)
                error(message('MATLAB:audiovideo:audioplayer:nonemptysignal'));
            end

            % transpose row vectors
            [rows, cols] = size(value);
            if cols > rows
                value = value';
            end

            % convert int8 to uint8 to preserve
            % backward compatibility.
            if(isa(value, 'int8'))
                obj.AudioData = uint8(int32(value) + 128);
            else
                obj.AudioData = value;
            end
        end

        function value = get.CurrentSample(obj)
            totalSamplesQueued = obj.EndIndex - obj.StartIndex + 1;

            if isempty(obj.Channel)
                % channel in the process of being initialized
                % (in initializeChannel function)
                dataSent = totalSamplesQueued;
            else
                dataSent = totalSamplesQueued - obj.Channel.OutputStream.DataToSend;
            end

            if(dataSent >= totalSamplesQueued)
                % We always point to the next sample to be played. When we
                % are done playing, the next sample to be played is the 1st
                % sample.
                value = 1;
            else
                value = obj.StartIndex + dataSent;
            end
        end

        function value = get.TotalSamples(obj)
            value = size(obj.AudioData, 1);
        end

        function value = get.Running(obj)
            if obj.isplaying()
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
                error(message('MATLAB:audiovideo:audioplayer:invalidtimerperiod'));
            end

            obj.TimerPeriod = value;

            if isTimerValid(obj)
                obj.Timer.Period = value;  %#ok<MCSUP>
            end
        end

        function set.Tag(obj, value)
            if ~ischar(value) && ~isstring(value)
                error(message('MATLAB:audiovideo:audioplayer:TagMustBeString'));
            end
            obj.Tag = value;
        end


        function value = get.Options(obj)
            import audiovideo.internal.audio.Converter;
            import multimedia.internal.audio.device.DeviceInfo;
            value.HostApiID = int32(obj.HostApiID);

            if obj.DeviceID == obj.DefaultDeviceID
                value.DeviceID = int32(DeviceInfo.getDefaultOutputDeviceID(obj.HostApiID));
            else
                value.DeviceID = int32(obj.DeviceID);
            end

            value.IOType = 'Output';
            value.NumberOfChannels = uint32(obj.NumberOfChannels);
            value.SampleRate = uint32(obj.SampleRate);
            value.BufferSize = uint32(Converter.secondsToSamples(obj.DesiredLatency, obj.SampleRate));
            value.AudioDataType = obj.AudioDataType;
            value.BitsPerSample = uint32(obj.BitsPerSample);
            value.SamplesUntilDone = uint64(obj.EndIndex - obj.CurrentSample + 1);
        end
    end

    %----------------------------------------------------------------------
    % Function Callbacks/Helper Functions
    %----------------------------------------------------------------------
    methods(Access='private')

        function executeTimerCallback(obj)
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
    % Timer related functionalities
    %----------------------------------------------------------------------
    methods(Access='private')
        function initializeTimer(obj)
            if isempty(obj.TimerFcn)
                % Initialize the timer only if there only if there is a valid
                % TimerFcn.
                return;
            end

            obj.Timer = internal.IntervalTimer(obj.TimerPeriod);
            obj.TimerListener = event.listener(obj.Timer, 'Executing', ...
                @(~,~)(obj.executeTimerCallback));
        end

        function uninitializeTimer(obj)
            if ~isTimerValid(obj)
                return;
            end
            delete(obj.TimerListener);
            obj.TimerListener = [];
        end

        function startTimer(obj)
            if ~isTimerValid(obj)
                return;
            end

            start(obj.Timer);
        end

        function stopTimer(obj)
            if ~isTimerValid(obj)
                return;
            end

            stop(obj.Timer);
        end

        function valid = isTimerValid(obj)
            valid = ~isempty(obj.Timer) && isvalid(obj.Timer);
        end
    end

    %----------------------------------------------------------------------
    % Helper Functions
    %----------------------------------------------------------------------
    methods(Access='private', Static)

        function checkNumericArgument(varargin)
            sz = size(varargin, 2);
            for i = 1:sz
                if(~isnumeric(varargin{i}))
                    error(message('MATLAB:audiovideo:audioplayer:numericinputs'));
                end
            end
        end

        function bits = getBitsPerSampleForThisSignal(thesignal)
            switch class(thesignal)
                case {'double', 'single', 'int16'}
                    bits = 16;
                case {'int8', 'uint8'}
                    bits = 8;
                otherwise
                    error(message('MATLAB:audiovideo:audioplayer:unsupportedtype'));
            end
        end

        function validateFcn(fcn)
            if ~internal.Callback.validate(fcn)
                error(message('MATLAB:audiovideo:audioplayer:invalidfunctionhandle'));
            end
        end

        function noAudio = hasNoAudioHardware()
            persistent hasNoAudio;
            hasNoAudio = true;
            if ~isempty(hasNoAudio)
                noAudio = hasNoAudio;
            else
                % are there any audio outputs?
                deviceInfos = multimedia.internal.audio.device.DeviceInfo.getDevicesForDefaultHostApi;
                outputInfos = deviceInfos([deviceInfos.NumberOfOutputs] > 0);

                % Enumerating devices is expensive,
                % Cache the value here to make subsequent calls faster.
                hasNoAudio = isempty(outputInfos);

                noAudio = hasNoAudio;
            end

            if (noAudio)
                % Channel is not initialized, warn here instead of erring
                % to support running on systems with no audio outputs
                warning(message('MATLAB:audiovideo:audioplayer:noAudioOutputDevice'));
                return;
            end
        end

        function exceptionObj = createDeviceException(exception)
            msg = strrep(exception.message, 'PortAudio', 'Device');
            exceptionObj = MException('MATLAB:audiovideo:audioplayer:DeviceError', msg);
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
    % audioplayer Functions
    %----------------------------------------------------------------------
    methods(Access='public')

        function c = horzcat(varargin)
            %HORZCAT Horizontal concatenation of audioplayer objects.

            if (nargin == 1)
                c = varargin{1};
            else
                error(message('MATLAB:audiovideo:audioplayer:noconcatenation'));
            end
        end

        function c = vertcat(varargin)
            %VERTCAT Vertical concatenation of audioplayer objects.

            if (nargin == 1)
                c = varargin{1};
            else
                error(message('MATLAB:audiovideo:audioplayer:noconcatenation'));
            end
        end

        function status = isplaying(obj)
            %ISPLAYING Indicates if playback is in progress.
            %
            %    STATUS = ISPLAYING(OBJ) returns true or false, indicating
            %    whether playback is or is not in progress.
            %
            %    See also AUDIOPLAYER, AUDIODEVINFO, AUDIOPLAYER/GET,
            %             AUDIOPLAYER/SET.

            status = ~isempty(obj.Channel) && obj.Channel.isOpen();
        end

        function stop(obj)
            %STOP Stops playback in progress.
            %
            %    STOP(OBJ) stops the current playback.
            %
            %    See also AUDIOPLAYER, AUDIODEVINFO, AUDIOPLAYER/GET,
            %             AUDIOPLAYER/SET, AUDIOPLAYER/PLAY, AUDIOPLAYER/PLAYBLOCKING,
            %             AUDIOPLAYER/PAUSE, AUDIOPLAYER/RESUME
            if obj.hasNoAudioHardware()
                return;
            end

            obj.Channel.OutputStream.flush();
            obj.pause();
        end

        function pause(obj)
            %PAUSE Pauses playback in progress.
            %
            %    PAUSE(OBJ) pauses the current playback.  Use RESUME
            %    or PLAY to resume playback.
            %
            %    See also AUDIOPLAYER, AUDIODEVINFO, AUDIOPLAYER/GET,
            %             AUDIOPLAYER/SET, AUDIOPLAYER/RESUME,
            %             AUDIOPLAYER/PLAY.
            if obj.hasNoAudioHardware()
                return;
            end

            if ~obj.isplaying()
                return;
            end

            obj.Channel.close();

            % Stop and uninitialize the timer if needed
            obj.stopTimer();
            obj.uninitializeTimer();


            internal.Callback.execute(obj.StopFcn, obj);

         end

        function resume(obj)
            %RESUME Resumes paused playback.
            %
            %    RESUME(OBJ) continues playback from paused location.
            %
            %    See also AUDIOPLAYER, AUDIODEVINFO, AUDIOPLAYER/GET,
            %             AUDIOPLAYER/SET, AUDIOPLAYER/PAUSE.
            if obj.hasNoAudioHardware()
                return;
            end

            if obj.isplaying()
                return;
            end

            % If there is no data to send resume
            % from the beginning
            if (obj.Channel.OutputStream.DataToSend == 0)
                obj.play();
                return;
            end

            % initialize the Timer if needed
            % (timer will be started in onCustomEvent)
            obj.initializeTimer();


            % Execute StartFcn
            internal.Callback.execute(obj.StartFcn, obj);

            try
                obj.Channel.open(obj.Options);
            catch exception
                throw(obj.createDeviceException(exception));
            end

        end


        function playblocking(obj, varargin)
            %PLAYBLOCKING Synchronous playback of audio samples in audioplayer object.
            %
            %    PLAYBLOCKING(OBJ) plays from beginning; does not return until
            %                      playback completes.
            %
            %    PLAYBLOCKING(OBJ, START) plays from START sample; does not return until
            %                      playback completes.
            %
            %    PLAYBLOCKING(OBJ, [START STOP]) plays from START sample until STOP sample;
            %                      does not return until playback completes.
            %
            %    Use the PLAY method for asynchronous playback.
            %
            %    See also AUDIOPLAYER, AUDIODEVINFO, AUDIOPLAYER/GET,
            %             AUDIOPLAYER/SET, AUDIOPLAYER/PLAY.


            % Modified by sprabhal
            obj.play(varargin{:});

            %if obj.hasNoAudioHardware()
            %   return;
            %end

            %obj.Channel.OutputStream.drain();
            % Wait till the last buffer has played till the end.
            %while isplaying(obj)
            %    pause(0.01);
            %end
            %stop(obj);

        end

    end
end
