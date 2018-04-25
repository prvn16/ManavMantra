function cArray = getCellArrayFromScopingTableRecord(scopingObj) %#ok
%% GETCELLARRAYFROMSCOPINGTABLERECORD function converts fxptds.FPTGUISCOPINGADAPTER instance to cell array of property values
%
% scopingObj is an instance of fxptds.FPTGUIScopingTableRecord
% cArray is a cell

%   Copyright 2016 The MathWorks, Inc.

     fieldNames = fxptds.FPTGUIScopingAdapter.getFieldNames();
     cArray = cell(1, numel(fieldNames));
     for idx=1:numel(fieldNames)
         field = fieldNames{idx};
         cArray{idx} = eval(['scopingObj.' field]);
     end
     
end