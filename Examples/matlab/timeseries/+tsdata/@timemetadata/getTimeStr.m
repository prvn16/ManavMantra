function dispmsg = getTimeStr(timeInfo)

% Copyright 2005-2011 The MathWorks, Inc.
 
%% Generates a string describing the time vector

%% Create the current time vector string
if ~isempty(timeInfo.StartDate)
    if tsIsDateFormat(timeInfo.Format)
        try
            startstr = datestr(datenum(timeInfo.StartDate,timeInfo.Format)+timeInfo.Start*tsunitconv('days',...
                timeInfo.Units),timeInfo.Format);
            endstr = datestr(datenum(timeInfo.StartDate,timeInfo.Format)+timeInfo.End*tsunitconv('days',...
                 timeInfo.Units),timeInfo.Format);
        catch me %#ok<NASGU>
             startstr = datestr(datenum(timeInfo.StartDate)+timeInfo.Start*tsunitconv('days',...
                timeInfo.Units));
             endstr = datestr(datenum(timeInfo.StartDate)+timeInfo.End*tsunitconv('days',...
                timeInfo.Units));
        end
    else
        startstr = datestr(datenum(timeInfo.StartDate)+timeInfo.Start*tsunitconv('days',...
            timeInfo.Units),'dd-mmm-yyyy HH:MM:SS');
        endstr = datestr(datenum(timeInfo.StartDate)+timeInfo.End*tsunitconv('days',...
            timeInfo.Units),'dd-mmm-yyyy HH:MM:SS');
    end
    
    dispmsg = sprintf(getString(message('MATLAB:tsdata:timemetadata:getTimeStr:CurrentTime',startstr,endstr)));
else
    unitStr = timeInfo.getUnitsDisplayStr();
    if isnan(timeInfo.Increment)
        dispmsg = getString(message('MATLAB:tsdata:timemetadata:getTimeStr:CurrentTimeNonuniform',...
            sprintf('%.4g',timeInfo.Start),sprintf('%.4g',timeInfo.End),unitStr));

    else
        dispmsg = getString(message('MATLAB:tsdata:timemetadata:getTimeStr:CurrentTimeUniform',...
            sprintf('%.4g',timeInfo.Start),sprintf('%.4g',timeInfo.End),unitStr));
    end
end