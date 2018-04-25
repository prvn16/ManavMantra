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
% Copyright 2003-2016 The MathWorks, Inc.

import audiovideo.internal.audio.Converter;

if obj.hasNoAudioHardware()
    return;
end

% If more than two arguments are specified, error is thrown
narginchk(1,2);

% Return if the player is 'On'
if obj.isplaying()
    return;
end

% Track the start and end indices of the current playback.
startIndex = 1;
endIndex = obj.TotalSamples;

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
        % Syntax used is play(obj, [start stop])
        startIndex = varargin{1}(1);
        endIndex = varargin{1}(2);
    else
        % Play from the indexed position to the end of the file.
        % Syntax used is play(obj, start)
        startIndex = varargin{1}(1);
        endIndex = obj.TotalSamples;
    end
    
    if startIndex <= 0 ||  startIndex >= endIndex || endIndex > obj.TotalSamples
        warning(message('MATLAB:audiovideo:audioplayer:invalidselection'));
        startIndex = 1;
        endIndex = obj.TotalSamples;
    end    
end

% Any buffered data from previous play session should be cleaned
% before sending the new data.
obj.Channel.OutputStream.flush();

% The number of samples sent to the audio device must be an exact multiple
% of the buffer size. See g1130462 for details. 
bufferSize = double(Converter.secondsToSamples( obj.DesiredLatency,...
                                                obj.SampleRate ));                                         
samplesUntilDone = endIndex - startIndex + 1;
extraSamples = rem(samplesUntilDone, bufferSize);
actEndIndex = endIndex + bufferSize - extraSamples;

obj.StartIndex = startIndex;

% Due to the zero-padding being done, the number of samples played back is
% more that what the user has requested. This is reflected in the EndIndex
% property. Hence, obj.EndIndex - obj.StartIndex + 1 reflects the number of
% samples in the signal + zero-padding samples (if any) that is played
% back.
obj.EndIndex = actEndIndex;

% Feed Data to the asyncio Channel in chunks
% Note: This is done instead of one call to OutputStream.write
% to avoid extra memory usage while the OutputStream is segmenting
% the audio and sending it to the device.
curPos = obj.StartIndex;
chunkSize = bufferSize * 100; % send 100 'buffers' at a time
while(curPos <= obj.EndIndex)
    endChunk = curPos + chunkSize - 1;
    if endChunk > endIndex
        % This code path is hit for the last chunk or buffer being played
        % back.
        % As the EndIndex property includes the padding to ensure a full
        % buffer, copy only the suitable amount of data from that supplied
        % by the user.
        endChunk = obj.EndIndex;
        dataToWrite = zeros( endChunk - curPos + 1, ...
                             obj.NumberOfChannels, ...
                             class(obj.AudioData) );
        dataToWrite(1:endIndex - curPos + 1, 1:obj.NumberOfChannels) = ...
                            obj.Audiodata(curPos:endIndex,1:obj.NumberOfChannels);
                        
        obj.Channel.OutputStream.write(dataToWrite, bufferSize);
    else
        obj.Channel.OutputStream.write( ...
            obj.Audiodata(curPos:endChunk,1:obj.NumberOfChannels), ...
            bufferSize);
    end
    
    curPos = endChunk + 1;
end

obj.resume();

end
