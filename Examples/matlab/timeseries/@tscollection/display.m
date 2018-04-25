function display(h)
%DISPLAY  Overloaded DISPLAY

%   Copyright 2005-2011 The MathWorks, Inc.

strTimeSeriesCollectionObj = getString(message('MATLAB:tscollection:display:TimeSeriesCollectionObject',h.Name));
fprintf('\n%s\n\n', strTimeSeriesCollectionObj);

% Check for empty time
if isempty(h.Time)
    strEmpty = getString(message('MATLAB:tscollection:display:Empty'));
    fprintf(1,'      %s\n\n', strEmpty);
    return
end

strTimeVectorCharacteristics = getString(message('MATLAB:tscollection:display:TimeVectorCharacteristics'));
fprintf(1,'%s\n\n', strTimeVectorCharacteristics); % Time vector characteristics
if ~isempty(h.TimeInfo.Startdate)
    % time is in absolute date/time format
    formatstr = '      %s%s%s\n';
    strStartTime = getString(message('MATLAB:tscollection:display:StartDate'));
    strEndTime = getString(message('MATLAB:tscollection:display:EndDate'));
    % determine the display format
    if tsIsDateFormat(h.TimeInfo.Format)
        % display format has been specified and the format is supported by tstool
        fprintf(1,formatstr, strStartTime, blanks(22-length(strStartTime)), ...
            datestr(tsunitconv('days',h.TimeInfo.Units)*h.TimeInfo.Start+...
            datenum(h.TimeInfo.Startdate),h.TimeInfo.Format));
        fprintf(1,formatstr, strEndTime, blanks(22-length(strEndTime)), ...
            datestr(tsunitconv('days',h.TimeInfo.Units)*h.TimeInfo.End+...
            datenum(h.TimeInfo.StartDate),h.TimeInfo.Format));   
    else
        % use default display format 0: 'dd-mmm-yyyy HH:MM:SS'
        fprintf(1,formatstr, strStartTime, blanks(22-length(strStartTime)), ...
            datestr(tsunitconv('days',h.TimeInfo.Units)*h.TimeInfo.Start+...
            datenum(h.TimeInfo.Startdate),'dd-mmm-yyyy HH:MM:SS'));
        fprintf(1,formatstr, strEndTime, blanks(22-length(strEndTime)), ...
            datestr(tsunitconv('days',h.TimeInfo.Units)*h.TimeInfo.End+...
            datenum(h.TimeInfo.Startdate),'dd-mmm-yyyy HH:MM:SS'));   
    end           
else
    if ~isempty(h.TimeInfo.Startdate)
        startdatestr = getString(message('MATLAB:tscollection:display:ReferenceStartDate'));
        fprintf(1,'      %s%s%s\n', startdatestr, ...
            blanks(22-length(startdatestr)),h.TimeInfo.Startdate);
    end
    strStartTime = getString(message('MATLAB:tscollection:display:StartTime'));
    strEndTime = getString(message('MATLAB:tscollection:display:EndTime'));
    formatstr = '      %s%s%d %s\n';
    fprintf(1,formatstr, strStartTime, blanks(22-length(strStartTime)), h.TimeInfo.Start, h.TimeInfo.Units);
    fprintf(1,formatstr, strEndTime, blanks(22-length(strEndTime)), h.TimeInfo.End, h.TimeInfo.Units);
end    

memberVars = gettimeseriesnames(h);
strMemberTimeSeriesObj = getString(message('MATLAB:tscollection:display:MemberTimeSeriesObj'));
fprintf(1,'\n%s:\n\n', strMemberTimeSeriesObj);
for k=1:length(memberVars)
    fprintf(1,'      %s\n', memberVars{k});
end
fprintf(1,'\n\n');
