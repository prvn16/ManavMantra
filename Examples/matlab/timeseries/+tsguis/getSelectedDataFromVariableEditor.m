function selectedData = getSelectedDataFromVariableEditor(ts,rowSelection,columnSelection)
% This undocumented function may be removed in a future release.

% Copyright 2014-2017 The MathWorks, Inc.

% Create an array combining time vector and 2-d data array
if ~isempty(ts.TimeInfo.StartDate)
    combinedTimeDataArray = [ts.getabstime  num2cell(ts.Data)];
else
    if ~isequal(class(ts.Time),class(ts.Data))
        % if the precision is different create a
        % combined array with the highest precision
        
        tData = ts.Data;
        tTime = ts.Time;
        if isa(ts.Time,'float')
            tData = cast(tData,'like',ts.Time);
        else
            try
                tTime = cast(tTime,'like',ts.Data);
            catch
                tTime = double(tTime);
                tData = double(tData);
            end
            
        end
        combinedTimeDataArray = [tTime tData];
    else
        combinedTimeDataArray = [ts.Time ts.Data];
    end
    
end

% Index into the combined array
if nargin<=1
    selectedData = combinedTimeDataArray;
else
    selectedData = combinedTimeDataArray(rowSelection,columnSelection);
end