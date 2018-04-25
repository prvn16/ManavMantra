%% BestPrecisionScalingSelector      
% Sub class inheriting +fixed/DataTypeSelector class.
% This class is used to create DataTypes to suit the following
% DataTypeSelector constraints
% WordLength = 'Lock' and Scaling = 'Auto'

% Copyright 2013-2016 The MathWorks, Inc.
classdef BestPrecisionScalingSelector < fixed.DataTypeSelector & handle
    properties
        Parent;
    end
    methods
        %% BestPrecisionScaling Constructor
        function bpss = BestPrecisionScalingSelector()
        end
        %% Set Parent
        function set.Parent(bpss, value)
            bpss.Parent = value; % stores parent object as member property
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
            % proposedDataType = createUnspecifiedScalingNumericType(inputType);  is this call
            % required?
            %
            proposedDataType = inputType;
            % use scaling factory to choose the best precision scaling
            proposedDataType = scalingFactory.getBestPrecisionScaling(values, proposedDataType); 
        end
    end
end