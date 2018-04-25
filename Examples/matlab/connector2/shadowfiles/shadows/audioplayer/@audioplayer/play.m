function play(obj, varargin)
%PLAY Plays audio samples in audioplayer object.
%
%   PLAY(OBJ) plays the audio samples from the beginning.
%
%   PLAY(OBJ, START) plays the audio samples from the START sample.
%
%   PLAY(OBJ, [START STOP]) plays the audio samples from the START sample
%   until the STOP sample.
%
%   Use the PLAYBLOCKING method for synchronous playback.
%
% Example:  Load snippet of Handel's Hallelujah Chorus and play back
%           only the first three seconds.
%
%   load handel;
%   p = audioplayer(y, Fs);
%   play(p, [1 (get(p, 'SampleRate') * 3)]);
%
% See also AUDIOPLAYER, AUDIODEVINFO, AUDIOPLAYER/GET,
%          AUDIOPLAYER/SET, AUDIOPLAYER/PLAYBLOCKING.

% SM
% Copyright 2003-2013 The MathWorks, Inc.

import audiovideo.internal.audio.Converter;

% Added by sprabhal
audiowrite(fullfile(connector.internal.userdir, 'audio.wav'), obj.AudioData, obj.SampleRate);

if obj.hasNoAudioHardware()
    return;
end

% If more than two arguments are specified, error is thrown
error(nargchk(1, 2, nargin, 'struct'));

% Return if the player is 'On'
if obj.isplaying()
    return;
end

obj.StartIndex = 1;
obj.EndIndex = obj.TotalSamples;

if ~isempty(varargin)
    % Check there are at most two arguments in Index vector and they are
    % numeric
    if (nargin == 2) && ...
            (~isnumeric(varargin{1}) || ...
            (numel(varargin{1}) > 2 ) || ...
            (isempty(varargin{1})))
        error(message('MATLAB:audiovideo:audioplayer:invalidIndex'));
    end
    % Second elements of the vector specifies the upper bound of the
    % sample being played.
    if size(varargin{1}, 2) == 2
        obj.StartIndex = varargin{1}(1);
        obj.EndIndex = varargin{1}(2);

    else % Play from the indexed position to the end of the file.
        obj.StartIndex = varargin{1}(1);
        obj.EndIndex = obj.TotalSamples;
    end

    if (obj.StartIndex <= 0 ||  ...
            obj.StartIndex >= obj.EndIndex || ...
            obj.EndIndex > obj.TotalSamples)
        warning(message('MATLAB:audiovideo:audioplayer:invalidselection'));
        obj.StartIndex = 1;
        obj.EndIndex = obj.TotalSamples;
    end

end
bufferSize = double(Converter.secondsToSamples(obj.DesiredLatency,...
    obj.SampleRate));

% Any buffered data from previous play session should be cleaned
% before sending the new data.
obj.Channel.OutputStream.flush();



% Feed Data to the asyncio Channel in chunks
% Note: This is done instead of one call to OutputStream.write
% to avoid extra memory usage while the OutputStream is segmenting
% the audio and sending it to the device.
curPos = obj.StartIndex;
chunkSize = bufferSize * 100; % send 100 'buffers' at a time
while(curPos <= obj.EndIndex)
    endChunk = curPos + chunkSize - 1;
    if (endChunk > obj.EndIndex)
        endChunk = obj.EndIndex;
    end

    obj.Channel.OutputStream.write( ...
        obj.Audiodata(curPos:endChunk,1:obj.NumberOfChannels), ...
        bufferSize);

    curPos = endChunk + 1;
end

obj.resume();

end
