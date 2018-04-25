classdef  MoreThanZeroOptions < internal.matlab.variableeditor.datatype.Items
    % This class is for the options that will more than 0. 
    % Copyright 2017 The MathWorks, Inc.

    properties(Constant)
        MinNumber = 0;
        MaxNumber = [];
        DefaultNameKey = 'defaultOptionName';
    end
end