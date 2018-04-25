function thisTs = ArrayEditorSetTableData(thisTs,newValue,row,col,tsrownum)

% Copyright 2006-2017 The MathWorks, Inc.

%% Utility method used by the Time Series Variable Editor when a time series
%% table entry is being edited.

if tsrownum>=0
    if col==0 % Time is being edited
        time = thisTs.Time;
        % Date values time
        if ~isempty(thisTs.TimeInfo.StartDate)
            % Convert the date to a datenum using the current format
            if tsIsDateFormat(thisTs.timeInfo.Format)
                time(tsrownum) = (datenum(newValue,thisTs.timeInfo.Format)-...
                    datenum(thisTs.timeInfo.StartDate,thisTs.timeInfo.Format))*...
                    tsUnitconv(thisTs.timeInfo.Units,'days');
            else
                time(tsrownum) = (datenum(newValue)-...
                    datenum(thisTs.timeInfo.StartDate))*...
                    tsUnitconv(thisTs.timeInfo.Units,'days');
            end
        else % Numeric time
            if ischar(newValue)
                time(tsrownum) = evalin(newValue);
            elseif isscalar(newValue)
                time(tsrownum) = newValue;
            end
        end
        % New time vector may be out of order
        if ~issorted(time)
            [thisTs.Time,I] = sort(time);
            thisTs.Data = thisTs.Data(I,:);
            if ~isempty(thisTs.Quality)
                thisTs.Quality = thisTs.Quality(I,:);
            end
        else
            thisTs.Time = time;
        end
        % Date edit
    elseif col<=size(thisTs.Data,2)
        thisTs.Data(tsrownum,col) = newValue;
        % Quality edit
    elseif col==size(thisTs.Data,2)+1
        newQual = find(strcmp(newValue,thisTs.QualityInfo.Description));
        if ~isempty(newQual)
            thisTs.Quality(tsrownum) = thisTs.QualityInfo.Code(newQual);
        end
    end
end