function thisTs = ArrayEditorNewRow(thisTs,newrow)

%NEWROW adds new data row to the timeseries when the table entries for a
%new row are completed. This is a callback triggered by the (java) table.

%   Copyright 2006-2017 The MathWorks, Inc.


%% Callback from java TableModel at completion of editing a new table row

%% Get new time
time = [];
if ~isempty(thisTs.TimeInfo.StartDate)
    thisFormat = thisTs.TimeInfo.Format;
    if ~isempty(thisFormat) && tsIsDateFormat(thisFormat)
        time = (datenum(newrow{1},thisFormat)-...
            datenum(thisTs.TimeInfo.StartDate))*...
            tsunitconv(thisTs.TimeInfo.Units,'days');
    else
        time = (datenum(newrow{1})-...
            datenum(thisTs.TimeInfo.StartDate))*...
            tsunitconv(thisTs.TimeInfo.Units,'days');
    end
else
    if ischar(newrow{1})
        time = real(eval(newrow{1},'[]'));
    else
        time = newrow{1};
    end
end
if isempty(time) || ~isscalar(time) || ~isfinite(time)
    return
end

%% Get new data
qualFlag = ~isempty(thisTs.Quality) && ~isempty(thisTs.QualityInfo.Code) && ...
    ~isempty(thisTs.QualityInfo.Description);
data = zeros(1,length(newrow)-1-qualFlag); % Exclude time and qual
for k=2:length(newrow)-qualFlag % Last col is always qual
    if ischar(newrow{k})
        newdata = real(eval(newrow{k},'[]'));
    else
        newdata = newrow{k};
    end
    if isempty(newdata) || ~isscalar(newdata) || ~isfinite(newdata)
        return
    end
    data(k-1) = newdata;
end

%% Get new quality
if qualFlag
    ind =  find(strcmp(thisTs.QualityInfo.Description,newrow{end}));
    qual = thisTs.QualityInfo.Code(ind);
end

%% Try to add the new row to the timeseries
if qualFlag
    thisTs = addsample(thisTs,'Time',time,'Data',data,'Quality',qual,'OverwriteFlag',true);
else %no qualFlag
    thisTs = addsample(thisTs,'Time',time,'Data',data,'OverwriteFlag',true);
end