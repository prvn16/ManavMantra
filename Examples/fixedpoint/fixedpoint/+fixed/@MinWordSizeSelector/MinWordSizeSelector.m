%% MinWordSizeSelector    
% Sub class inheriting +fixed/DataTypeSelector class.
% This class is used to create DataTypes to suit the following
% DataTypeSelector constraints
% WordLength = 'Auto' and Scaling = 'Lock'

% Copyright 2013-2016 The MathWorks, Inc.
classdef MinWordSizeSelector < fixed.DataTypeSelector
    properties
        Parent;
    end
    methods
        %% MinWordSize Constructor
        function mws = MinWordSizeSelector()
        end
        %% Set Parent
        function set.Parent(mws, value)
            mws.Parent = value;
        end
        %% Propose
        % propose output numerictype given input values, numerictype and
        % scaling factory
        %
        % Arguments:
        %            values: input data values
        %         inputType: input numeric type
        %    scalingFactory: scaling factory based on inputType scaling
        % Returns:
        %  proposedDataType: output numeric type of inputType scaling
        %
        function proposedDataType = propose(~, values, inputType, scalingFactory)
            proposedDataType = inputType;
            proposedDataType = scalingFactory.getWordLength(values, proposedDataType);
        end
    end
end