function newrow(h,newrow,varargin)
%NEWROW adds new data row to the timeseries when the table entries for a
%new row are completed. This is a callback triggered by the (java) table.

%   Copyright 2005-2017 The MathWorks, Inc.

%% Callback from java TableModel at completion of editing a new table row

%% Get new time
if h.TableModel.getCache.getAbsTimeFlag
    dateFormat = h.Timeseries.TimeInfo.Format;
    if ~isempty(dateFormat) && tsIsDateFormat(dateFormat)
        time = (datenum(newrow{1},dateFormat)-...
            datenum(h.Timeseries.TimeInfo.StartDate))*...
            tsunitconv(h.Timeseries.TimeInfo.Units,'days');
    else
        time = (datenum(newrow{1})-...
            datenum(h.Timeseries.TimeInfo.StartDate))*...
            tsunitconv(h.Timeseries.TimeInfo.Units,'days');
    end
else
    time = real(eval(newrow{1}));
end
qualFlag = h.TableModel.getCache.getQualFlag;
data = zeros(1,length(newrow)-1-qualFlag); % Exclude time and qual

%% Get new data
for k=2:length(newrow)-qualFlag
    try
        newdata = real(eval(newrow{k}));
    catch me %#ok<NASGU>
        newdata = [];
    end
    if isempty(newdata) || ~isscalar(newdata)
        uiwait(errordlg(getString(message('MATLAB:tsdata:tstableadaptor:newrow:InvalidTableEntryDataNumericTimesScalar')),...
            getString(message('MATLAB:tsdata:tstableadaptor:newrow:TimeSeriesTools')),'modal'));
        h.TableModel.resetEdit;
        h.Timeseries.notify('datachange')
        return
    end
    data(k-1) = newdata;
end

%% Get new quality
if qualFlag
    ind =  strcmp(h.Timeseries.QualityInfo.Description,newrow{end});
    qual = h.Timeseries.QualityInfo.Code(ind);
end

TSVIEWER = tsguis.tsviewer;
currentnode = TSVIEWER.TreeManager.getselectednode; %handle to current tsnode
if isa(currentnode.up,'tsguis.tscollectionNode')
    iscoll = true;
    Tsc = currentnode.up.Tscollection;
else
    iscoll = false;
end

%% Try to add the new row to the timeseries
try
    % Record this transaction
    recorder = tsguis.recorder;
    T = tsguis.transaction;
    if iscoll
        T.ObjectsCell = {h.Timeseries, Tsc};
    else
        T.ObjectsCell = {h.Timeseries};
    end
    % Add the new samples
    if qualFlag
        h.Timeseries.addsample('Time',time,'Data',data,...
            'Quality',qual,'OverwriteFlag',true);
        if strcmp(recorder.Recording,'on')
            T.addbuffer(sprintf('%% Add a new row to timeseries ''%s''',localGenVarName(h.Timeseries.Name)));
            T.addbuffer(sprintf('%s = addsample(%s, ''Time'',[%s], ''Data'',[%s], ''Quality'',[%s], ''OverwriteFlag'',true);',...
                localGenVarName(h.Timeseries.Name), localGenVarName(h.Timeseries.Name), num2str(time), num2str(data(:).'),...
                num2str(qual)),h.Timeseries);
        end
        
    else %no qualFlag
        h.Timeseries.addsample('Time',time,'Data',data,'OverwriteFlag',true);
        if strcmp(recorder.Recording,'on')
            T.addbuffer(sprintf('%% Add a new row to timeseries ''%s''',localGenVarName(h.Timeseries.Name)));
            T.addbuffer(sprintf('%s = addsample(%s, ''Time'',[%s], ''Data'',[%s], ''OverwriteFlag'',true);',...
                localGenVarName(h.Timeseries.Name), localGenVarName(h.Timeseries.Name), num2str(time), num2str(data(:)')),h.Timeseries);
        end
    end
    
    % Clear the new row editing buffer
    h.TableModel.resetEdit;
    % Commit the transaction
    T.commit;
    recorder.pushundo(T);
catch me
    h.Timeseries.DataChangeEventsEnabled = true;
    rethrow(me);
end
end

%--------------------------------------------------------------------------
function varName = localGenVarName(S)
varName = matlab.lang.makeUniqueStrings(...
    matlab.lang.makeValidName(S), {}, namelengthmax);
end
