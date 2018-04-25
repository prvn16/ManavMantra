function [x_str, y_str, xcheck, ycheck, xcolname, ycolname] = bfitdatastatselectnew(figHandle, newdataHandle)
% BFITDATASTATSELECTNEW Update data stat GUI and figure from current data to new data.

%   Copyright 1984-2010 The MathWorks, Inc.

% for new data, was it showing before?
xdatastats = getappdata(double(newdataHandle),'Data_Stats_X');

if isempty(xdatastats) % new data
    %setup appdata and compute stats: nothing plotted since new data
    [x_str, y_str, xcolname, ycolname] = bfitdatastatsetup(figHandle, newdataHandle); % data stats computed
    xcheck = false(1,6);
    ycheck = false(1,6);
else % was showing before: get stats to return, and replot
    x = struct2cell(xdatastats);
    y = struct2cell(getappdata(double(newdataHandle),'Data_Stats_Y'));
    xstats = cat(1,x{:}); ystats = cat(1,y{:});
    format = '%-12.4g';
    x_str = cellstr(num2str(xstats,format));
    y_str = cellstr(num2str(ystats,format));
    checkon = true;
    stattypes = {'min','max','mean','median','mode','std','range'};
    xcheck = getappdata(double(newdataHandle),'Data_Stats_X_Showing');
    ycheck = getappdata(double(newdataHandle),'Data_Stats_Y_Showing');
    for i=find(xcheck)
        bfitplotdatastats(newdataHandle,stattypes{i},'x',checkon)
    end
    for i=find(ycheck)
        bfitplotdatastats(newdataHandle,stattypes{i},'y',checkon)
    end
	if ~any(ycheck) && ~any(xcheck)
		axesH = ancestor(newdataHandle,'axes'); % need this in case subplots in figure
		bfitcreatelegend(axesH);
	end
	[xcolname, ycolname] = bfitdatastatsgetcolnames(newdataHandle);
end
