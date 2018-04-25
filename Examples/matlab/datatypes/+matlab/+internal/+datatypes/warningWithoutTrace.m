function warningWithoutTrace(msg)
%WARNWITHOUTTRACE warns without displaying the back trace

%   Copyright 2014 The MathWorks, Inc.

% store the warning state
warnState = warning('off', 'backtrace');

% issue a warning
warning(msg);

% Restore the warning state
warning(warnState);
end