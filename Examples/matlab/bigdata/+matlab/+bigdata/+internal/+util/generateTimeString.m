function text = generateTimeString(numSeconds)
% Generate a nice to read string representation of the given number of
% seconds.

%   Copyright 2016 The MathWorks, Inc.

numSeconds = floor(numSeconds);
if numSeconds > 3600
    text = char(hours(numSeconds / 3600));
elseif numSeconds > 60
    text = char(minutes(numSeconds / 60));
else
    text = char(seconds(numSeconds));
end
end
