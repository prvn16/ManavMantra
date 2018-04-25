function sfieldNames = getFieldNames(~)
%% GETFIELDNAMES function gets all the field names of member property struct FPTGUIScopingTableRow
%
% sfieldNames is a cellarray containing the field names of
% FPTGUIScopingTableRow member property

%   Copyright 2016 The MathWorks, Inc.

    metaData = metaclass(fxptds.FPTGUIScopingTableRecord);
    properties = metaData.PropertyList;
    sfieldNames = {properties.Name};
end