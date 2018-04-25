function thisCache = UpdateArrayEditorTableCache(thisTs,row,col)

% Copyright 2006-2017 The MathWorks, Inc.

%   This function is unsupported and might change or be removed without
%   notice in a future version.

import com.mathworks.toolbox.timeseries.*;
import com.mathworks.widgets.spreadsheet.data.*;

% thisTs may be a timeseries, tsdata.timeseries, or tsdata.tscollection
% object.

if ~isprop(thisTs,'Data')
    data = [];
else
    data = thisTs.Data;
end
if ~ismatrix(data) || (isprop(thisTs,'IsTimeFirst') && ~thisTs.IsTimeFirst) ...
        || numel(thisTs)~=1
    thisCache = [];
    return
end

% Refresh the table cache centered on the table row, row
% Get timeseries data and parameters
absTimeFlag = ~isempty(thisTs.TimeInfo.StartDate);

% Calculate cache params
if row>thisTs.TimeInfo.Length
    row = 0;
end
cacheRowStart = max(row-100,0);
cacheColumnStart = max(col-20,0);
cacheLength = min(thisTs.TimeInfo.Length-cacheRowStart,200);
cacheWidth = min(size(data,2)-cacheColumnStart,40);

% Obtain a list of events which have the same absTime status as
% absTimeFlag and their numeric times
evTimes = [];
evList = [];
if isprop(thisTs,'Events')
    allEvents = thisTs.Events;
    for k=1:length(allEvents)
        if absTimeFlag==~isempty(allEvents(k).StartDate)
            evList = [evList;allEvents(k)]; %#ok<AGROW>
            if ~absTimeFlag
                evTimes = [evTimes; allEvents(k).Time*...
                    tsunitconv(thisTs.TimeInfo.Units,allEvents(k).Units)]; %#ok<AGROW>
            else
                deltaStartDate = tsunitconv(thisTs.TimeInfo.Units,'days') * ...
                    (datenum(allEvents(k).StartDate)-datenum(thisTs.TimeInfo.StartDate));
                evTimes = [evTimes; deltaStartDate+allEvents(k).Time*...
                    tsunitconv(thisTs.TimeInfo.Units,allEvents(k).Units)]; %#ok<AGROW>
            end
        end
    end
end

% Find times,row numbers, events, and event times within the cache range
cacheLength = cacheLength+length(evTimes); % Extend the cache to accommodate valid events
eventIndexes = [zeros(thisTs.TimeInfo.Length,1); (1:length(evTimes))'];
tsRowNumbers = [(1:thisTs.TimeInfo.Length)'; zeros(length(evTimes),1)];
if ~isempty(evTimes)
    tableTimes  = [thisTs.Time; evTimes];
    [tableTimes,I] = sort(tableTimes);
    eventIndexes = eventIndexes(I);
    tsRowNumbers = tsRowNumbers(I);
else
    tableTimes  = thisTs.Time;
end

numrows = length(tableTimes);
tableTimes = tableTimes(cacheRowStart+1:cacheRowStart+cacheLength);
tsRowNumbers = tsRowNumbers(cacheRowStart+1:cacheRowStart+cacheLength);
eventIndexes = eventIndexes(cacheRowStart+1:cacheRowStart+cacheLength);


% Create the new cache
thisCache = TimeSeriesArrayEditorTableCache(cacheRowStart,cacheLength,...
    cacheColumnStart,cacheWidth);

% Evaluate repeated access variables
if absTimeFlag
    dayConvFactor = tsunitconv('days',thisTs.TimeInfo.Units);
    dayOffset = datenum(thisTs.TimeInfo.StartDate);
end

qualFlag = isprop(thisTs,'Quality') && ~isempty(thisTs.Quality) && ~isempty(thisTs.QualityInfo.Code) && ...
    ~isempty(thisTs.QualityInfo.Description);
if qualFlag
    qual = thisTs.Quality;
    qualCodes = thisTs.QualityInfo.Code;
    qualDesc = thisTs.QualityInfo.Description;
end
numcols = 1+size(data,2)+qualFlag;
realFlag = isreal(data);

% Add data to the cache within its range
format = 0;
if absTimeFlag && tsIsDateFormat(thisTs.timeInfo.Format)
    format = thisTs.timeInfo.Format;
end
for row=1:cacheLength
    tsRowNumber = tsRowNumbers(row);
    if tsRowNumber==0
        e = evList(eventIndexes(row));
        if ~isempty(e.StartDate)
            thisCache.addEvent(e.Name,getTimeStr(e));
        else
            thisCache.addEvent(e.Name,e.Time);
        end
    else
        % Package the row as a real or compex array
        if isempty(data)
            rowData = [];
        else
            rowData = workspacefunc('createComplexVector',data(tsRowNumber,...
                cacheColumnStart+1:cacheColumnStart+cacheWidth),realFlag);
        end
        
        tsRowNumber = tsRowNumbers(row);
        if ~qualFlag
            if absTimeFlag
                thisCache.addTimedData(tsRowNumber,...
                    datestr(dayOffset+dayConvFactor*tableTimes(row),format),...
                    rowData,[]);
            else
                thisCache.addTimedData(tsRowNumber,...
                    tableTimes(row),rowData,[]);
            end
        else
            I = find(qualCodes == qual(tsRowNumber));
            if ~isempty(I)
                qualName = qualDesc{I(1)};
            else
                qualName = qualDesc{1};
            end
            if absTimeFlag
                thisCache.addTimedData(tsRowNumber,...
                    datestr(dayOffset+dayConvFactor*tableTimes(row),format),...
                    rowData,...
                    qualName);
            else
                thisCache.addTimedData(tsRowNumber,...
                    tableTimes(row),rowData,...
                    qualName);
            end
        end
    end
end

% Update the table model
thisCache.numTableRows = numrows;
thisCache.numTableColumns = numcols;

% thisCache.qualStrings are used to control the editor for the
% last column so make sure they are empty if quality is not displayed
if qualFlag
    thisCache.qualStrings = thisTs.QualityInfo.Description;
else
    thisCache.qualStrings = {};
end