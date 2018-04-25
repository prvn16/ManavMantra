function setdata(h,newValue,row,col)

% Copyright 2005-2017 The MathWorks, Inc.

% Called from java as the result of a setValueAt on the table which calls
% this method via setTimeseriesDataInMatlab to modify the timeseries.

% If necessary refresh the cache first
if row<h.TableModel.fCache.getStartRow || row>h.TableModel.fCache.getEndRow
    newCache = tsguis.UpdateArrayEditorTableCache(h.Timeseries,row);
    h.TableModel.setCache(newCache);
end

% Find the time series row corresponding to this table row
tsrownum = h.TableModel.getCache.getTimeseriesRowNumber(row-h.TableModel.getCache.getStartRow);

if tsrownum>=0
    T = tsguis.transaction;
    T.ObjectsCell = {h.Timeseries};
    recorder = tsguis.recorder;
    thisTs = h.Timeseries;
    if col==0 % Time vector modification
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
            cacheDataChange = thisTs.DataChangeEventsEnabled;
            thisTs.DataChangeEventsEnabled = false;
            % We need to restore the cached DataChangeEventsEnabled before
            % returning to java or DataChangeEventsEnabled will drool
            try
                [thisTs.Time,I] = sort(time);
                if ~isempty(thisTs.Quality)
                    thisTs.Quality = thisTs.Quality(I,:);
                end
            catch me
                thisTs.DataChangeEventsEnabled = cacheDataChange;
                rethrow(me);
            end
            thisTs.DataChangeEventsEnabled = cacheDataChange;
            thisTs.Data = thisTs.Data(I,:);
        else
            reSortFlag = false;
            thisTs.Time = time;
        end
        
        % Log the changes separately for the resport case
        if strcmp(recorder.Recording,'on')
            T.addbuffer('%% Time vector modification');
            if reSortFlag
                T.addbuffer(sprintf('time = %s.Time;',localGenVarName(thisTs.Name)));
                T.addbuffer(sprintf('time(%d) = %f;',tsrownum,time(tsrownum)));
                T.addbuffer('[time,I] = sort(time);');
                T.addbuffer(sprintf('%s.Data = %s.Data(I,:);',localGenVarName(thisTs.Name),...
                    localGenVarName(thisTs.Name)));
                if ~isempty(thisTs.Quality)
                    T.addbuffer(sprintf('%s.Quality = %s.Quality(I);',localGenVarName(thisTs.Name),...
                        localGenVarName(thisTs.Name)));
                end
                T.addbuffer(sprintf('%s.Time = time;',localGenVarName(thisTs.Name)),h.Timeseries);
            else
                T.addbuffer(sprintf('%s.Time(%d) = %s;',localGenVarName(thisTs.Name),tsrownum,...
                    newValue),thisTs);
            end
        end
    elseif col<=size(thisTs.Data,2) % Data column
        thisTs.Data(tsrownum,col) = eval(newValue);
        if strcmp(recorder.Recording,'on')
            T.addbuffer(sprintf('%s.Data(%d,%d) = %s;',localGenVarName(thisTs.Name),tsrownum,col,newValue),thisTs);
        end
    elseif col==size(thisTs.Data,2)+1 % Quality column
        newQual = find(strcmp(newValue,thisTs.QualityInfo.Description));
        if ~isempty(newQual)
            thisTs.Quality(tsrownum) = thisTs.QualityInfo.Code(newQual);
            if strcmp(recorder.Recording,'on')
                T.addbuffer(sprintf('%s.Quality(%d) = %d;',thisTs.Name,...
                    tsrownum,thisTs.QualityInfo.Code(newQual)),thisTs);
            end
        end
    end
    % Store transaction
    T.commit;
    recorder.pushundo(T);
end

% refresh the Cache to refelect the new data
newCache = tsguis.UpdateArrayEditorTableCache(h.Timeseries,row,col);
h.TableModel.setCache(newCache);
end

%--------------------------------------------------------------------------
function varName = localGenVarName(S)
varName = matlab.lang.makeUniqueStrings(...
    matlab.lang.makeValidName(S), {}, namelengthmax);
end