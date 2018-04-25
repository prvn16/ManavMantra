function scopingTableObj = getScopingTableRecord(result, runObject)
%% GETSCOPINGTABLERECORD function create a cell array representing row entries of ScopingTable
% which is a table object and a member of fxptds.FPTGUIScopingEngine

%   Copyright 2016 The MathWorks, Inc.

    fieldNames = fxptds.FPTGUIScopingAdapter.getFieldNames();
    scopingTableObj = fxptds.FPTGUIScopingTableRecord;
    for i=1:numel(fieldNames)
       field = fieldNames{i};
       switch(field)
           case 'SubsystemId'
               scopingTableObj.SubsystemId = fxptds.Utils.getSubsystemId(result);
           case 'ResultId'
                scopingTableObj.ResultId = fxptds.Utils.getResultId(result);
           case 'ResultName'
               scopingTableObj.ResultName = fxptds.Utils.getResultName(result);
           case 'DatasetSourceName'
               scopingTableObj.DatasetSourceName = fxptds.Utils.getDatasetSource(runObject);
           case 'RunName'
               scopingTableObj.RunName = fxptds.Utils.getRunName(runObject);
       end
    end
    % Fill in id after all fields are filled up
    scopingTableObj.ID = fxptds.Utils.getScopingId(result);
end