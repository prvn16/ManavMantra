function duration = computeQueueDuration(bufferSize)
% COMPUTEQUEUEDURATION Given a bufferSize, return a queue duration
% The queue duration should is for audioplayer and 
% audiorecorder, to avoid dropouts.

% Quadrouple buffer here to reduce the likely hood of dropouts.  
% We choose a conservative value here to because we never want 
% audioplayer/audiorecorder to glitch.

% Author: NH
% Copyright 2013 MathWorks, Inc.
duration = bufferSize * 4;
end