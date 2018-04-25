classdef  MoreThanZeroItems < internal.matlab.variableeditor.datatype.Items
    % This class is for the items that will more than 0.
    % Copyright 2017 The MathWorks, Inc.

    properties(Constant)
        MinNumber = 0;
        MaxNumber = [];
        DefaultNameKey = 'defaultItemName';
    end
end