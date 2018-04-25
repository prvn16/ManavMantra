function wake(h)
%WAKE     wake explorer if we put it to sleep
%   Copyright 2007-2008 The MathWorks, Inc.

%turn property change listeners back on after we update the properties of
%displayed data. (prevent flickering)
ed = DAStudio.EventDispatcher;
if(h.SleepCntr > 0)
  ed.broadcastEvent('MEWakeEvent');
  % Decrement the sleep counter every time we send a WakeEvent.
  h.SleepCntr = h.SleepCntr-1;
end


% [EOF]
