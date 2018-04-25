function updateBar(ntx,data,dataTypeObject)
% Update bars in dynamic bar plot
% Also update any text displays that depend on histogram data.
%
% updateBar(ntx,data) updates the histogram data and the display.
% updateBar(ntx) updates the display without updating the data.

%   Copyright 2010 The MathWorks, Inc.

% If data not passed,
%  - force graphical update using current data
%  - skip (and disregard) decimation
%  - useful when changing y-axis units
% If data passed,
%  - apply decimation
%  - update histogram states
%  - perform graphical histogram bar update
%

if nargin > 1
     if nargin < 3
        dataTypeObject = [];
    end
    isFirstUpdate = updateHistData(ntx,data,dataTypeObject); % update histogram states (not graphics)
   
    % Suppress resetting of data statistics on first call
    % This maintains SQNR statistics for the first-time data sent to tool,
    % which would otherwise be reset due to a change in data type that is
    % almost inevitable on the first update
    allowReset = ~isFirstUpdate;
else
    allowReset = true;
end

updateSNRForNumericTypeChange(ntx,allowReset);% xxx clears out initial SSQE, etc
                                              %updateNumericTypesAndSigns(ntx,allowReset);% xxx clears out initial SSQE, etc

performAutoBA(ntx); % Perform automatic bit allocation

