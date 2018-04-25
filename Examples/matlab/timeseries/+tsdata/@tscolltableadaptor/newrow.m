function newrow(h,newrow,~)
%NEWROW adds new data row to the timeseries when the table entries for a
%new row are completed. This is a callback triggered by the (java) table.

%   Copyright 2005-2017 The MathWorks, Inc.

%% Callback from java TableModel at completion of editing a new table row
%% Note that this method is an enhanced version of tsguis.ArrayEditorNewRow
%% which records data changes and implements undo/redo
%% Get new time
time = [];
if h.TableModel.getCache.getAbsTimeFlag
    try %#ok<TRYNC>
        if ~isempty(h.Timeseries.TimeInfo.Format)
            time = (datenum(newrow{1},h.Timeseries.TimeInfo.Format)-...
                datenum(h.Timeseries.TimeInfo.StartDate))*...
                tsunitconv(h.Timeseries.TimeInfo.Units,'days');
        else
            time = (datenum(newrow{1})-...
                datenum(h.Timeseries.TimeInfo.StartDate))*...
                tsunitconv(h.Timeseries.TimeInfo.Units,'days');
        end
    end
else
    try
        time = real(eval(newrow{1}));
    catch me %#ok<NASGU>
        time = [];
    end
end
if isempty(time) || ~isscalar(time) || ~isfinite(time)
    h.TableModel.resetEdit;
    h.Timeseries.notify('datachange')
    return
end

try
    M = h.Timeseries.gettimeseriesnames;
    h.TableModel.resetEdit;
    % Now add sample for time = "time", assuming quality values for
    % timeseries members would bet assigned to new time sample
    % automatically.
    h.Timeseries.addsampletocollection('Time', time, 'OverwriteFlag', true);
    h.Timeseries.notify('datachange');
    
    if ~isempty(M)
        drawnow
        msg = sprintf(getString(message('MATLAB:tsdata:tscolltableadaptor:newrow:NaNsInsertedDataRowsTimeInfo',...
            num2str(time))));
        msgbox(msg,getString(message('MATLAB:tsdata:tscolltableadaptor:newrow:TimeSeriesTools')),'modal')
    end
catch me  %#ok<NASGU>
    h.TableModel.resetEdit;
end