function addResultToChangeset(this, result)
%% ADDRESULTTOCHANGESET function adds result to curScopingChangeset datastructure
% Function takes in result and adds it to curScopignChangeset cell array. 
% This cell array is processed, converted to fxptds.ScopingTableRecord and
% added as table rows to ScopingTable.
%
% result is an instance of fxptds.AbstractResult

%   Copyright 2016 The MathWorks, Inc.

    this.CurScopingChangeset{end+1} = result;
end