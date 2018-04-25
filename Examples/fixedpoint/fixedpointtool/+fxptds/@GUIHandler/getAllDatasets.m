function allDatasets = getAllDatasets(~)
%% GETALLDATASETS function queries current fixed point tool instance for 
% all datasets involved in top model context

%   Copyright 2016 The MathWorks, Inc.

    allDatasets = [];
    
    % get current instance of fixed point tool
    me = fxptui.getexplorer;
    
    % if instance found, query for all datasets
    if ~isempty(me)
        allDatasets = me.getAllDatasets;
    end
end