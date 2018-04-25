function setdata(h,newValue,row,~)

% Copyright 2005-2017 The MathWorks, Inc.

% Called from java as the result of a setValueAt on the table which calls
% this method via setTimeseriesDataInMatlab to modify the timeseries. The
% last input is not used for tscolltableadapter but is used in the parent
% class.

% If necessary refresh the cache first
if row<h.TableModel.fCache.getStartRow || row>h.TableModel.fCache.getEndRow
    h.updatecache(row);
end

% Find the time series row corresponding to this table row
tsrownum = h.TableModel.getCache.getTimeseriesRowNumber(row-h.TableModel.getCache.getStartRow);

if tsrownum>=0
    T = tsguis.transaction;
    T.ObjectsCell = {h.Timeseries};
    recorder = tsguis.recorder;
    thisTs = h.Timeseries;
    time = thisTs.Time;
    if h.TableModel.getCache.getAbsTimeFlag
        if tsIsDateFormat(thisTs.timeInfo.Format)
            time(tsrownum) = (datenum(newValue,thisTs.timeInfo.Format)-...
                datenum(thisTs.timeInfo.StartDate,thisTs.timeInfo.Format))*...
                tsUnitconv(thisTs.timeInfo.Units,'days');
        else
            time(tsrownum) = (datenum(newValue)-...
                datenum(thisTs.timeInfo.StartDate))*...
                tsUnitconv(thisTs.timeInfo.Units,'days');
        end
    else
        time(tsrownum) = eval(newValue);
    end
    % Reset the time vector
    if ~issorted(time)
        reSortFlag = true;
        thisTs.Time = sort(time);
    else
        reSortFlag = false;
        thisTs.Time = time;
    end
    
    % Log the changes separately for the resport case
    if strcmp(recorder.Recording,'on')
        T.addbuffer('%% Time vector modification');
        if reSortFlag
            T.addbuffer(sprintf('time = %s.Time;',thisTs.Name));
            T.addbuffer(sprintf('time(%d) = %f;',tsrownum,time(tsrownum)));
            T.addbuffer('[time,I] = sort(time);');
        else
            T.addbuffer(sprintf('%s.Time(%d) = %s;',thisTs.Name,tsrownum,...
                newValue),thisTs);
        end
    end
    
    % Store transaction
    T.commit;
    recorder.pushundo(T);
end

% refresh the Cache to refelect the new data
h.updatecache(row);