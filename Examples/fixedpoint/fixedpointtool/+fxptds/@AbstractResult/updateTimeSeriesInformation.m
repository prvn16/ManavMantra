function updateTimeSeriesInformation(this, sdiSignal)
% UPDATETIMESERIESINFORMATION Update the timeseries ID and the signal name information on the result

% Copyright 2013-2014 The MathWorks, Inc.

%Signal IDs from SDI are always unique. If it already exists in the
%TimeSeriesID property of the result, it means that it was already captured
%previously. This prevents the ID from being captured twice.
signalIDCaptured = any(this.TimeSeriesID == sdiSignal.id);
if ~signalIDCaptured
    if this.TimeSeriesID ~= 0
        this.TimeSeriesID = [this.TimeSeriesID sdiSignal.id];
    else
        this.TimeSeriesID = sdiSignal.id;
    end
    if ~isempty(this.SignalName)
        this.SignalName = [this.SignalName,{sdiSignal.signalLabel}];
    elseif ~isempty(sdiSignal.signalLabel) && ~strcmpi(sdiSignal.signalLabel,' ')
        this.SignalName = {sdiSignal.signalLabel};
    end
    this.IsPlottable = true;
end
end
