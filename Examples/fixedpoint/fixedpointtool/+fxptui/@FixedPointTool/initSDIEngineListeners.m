function initSDIEngineListeners(this)
%INITSDIENGINELISTENERS Attach listeners to the global SDI to capture
%signal logs

% Copyright 2015-2017 The MathWorks, Inc.

% Add listener on the global SDI engine for time-series data.
sdiEngine = Simulink.sdi.Instance.engine();
this.SDIListeners = event.listener(sdiEngine,'runAddedEvent',@(s,e) updateForTimeSeriesData(this, e));

end
