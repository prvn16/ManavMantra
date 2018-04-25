function sleep(h)
%SLEEP    put explorer to sleep if it isn't already

%   Copyright 2007-2008 The MathWorks, Inc.

%turn property change listeners off while we update the properties of
%displayed data. (prevent flickering)
ed = DAStudio.EventDispatcher;
% Maintain a count of the number of SleepEvents we have introduced.
h.SleepCntr = h.SleepCntr+1;
ed.broadcastEvent('MESleepEvent');

% [EOF]
