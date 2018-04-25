function [groupedResults, group] = getGroupResults(result)
%% GETGROUPRESULTS function returns all results that belong to a dt group of a result
% 
% result is an instance of fxptds.AbstractResult
% groupedResults is a cell array of results that belong the same group as that
% of input result 

% Copyright 2016 The MathWorks, Inc.

    % get result's run object 
    runObj = result.getRunObject;
    
    % get the group that the result is registered to
    group = runObj.dataTypeGroupInterface.getGroupForResult(result);
    
    % get all results the belong to the group
    groupedResults = group.getGroupMembers();
end