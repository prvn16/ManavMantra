
%   Copyright 2016 The MathWorks, Inc.

classdef FPTGUIScopingAdapter < handle
%% FPTGUISCOPINGADAPTER class is responsible for getting rows for ScopingTable in fxptds.FPTGUIScopingEngine
%
    methods(Static)
       s = getScopingTableRecord(result, runObject); % returns an instance of fxptds.FPTGUIScopingTableRecord
       sfieldNames = getFieldNames(); % returns the field names of fxptds.FPTGUIScopingTableRecord
       cArray = getCellArrayFromScopingTableRecord(scopingTableRecord); % converts fxptds.FPTGUIScopingTableRecord to cellArray
        id = getScopingId(scopingTableRecord);
    end
end