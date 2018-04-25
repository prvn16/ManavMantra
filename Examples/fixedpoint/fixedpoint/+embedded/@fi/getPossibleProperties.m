function props = getPossibleProperties(~)
%GETPOSSIBLEPROPERTIES Possible properties for list view of Model Explorer.
%
%   GETPOSSIBLEPROPERTIES(X) Returns a list of properties that could be
%   viewed in the list view of the Model Explorer for object X.

%   Copyright 2015 The MathWorks, Inc.

        props = {
            'Name'                % Name

            'Value'               % Value

            'DataTypeMode'        % numerictype
            'DataType'
            'Signedness'
            'WordLength'
            'FractionLength'
            'FixedExponent'
            'Slope'
            'SlopeAdjustmentFactor'
            'Bias'

            'Dimensions'          % Dimensions
            'Complexity'          % Complexity

            'fimathislocal'       % fimath properties

            'DDGRoundingMethod'
            'DDGOverflowAction'

            'DDGProductMode'           % Product
            'DDGProductFractionLength'
            'DDGProductFixedExponent'
            'DDGProductWordLength'
            'DDGProductBias'
            'DDGProductSlope'

            'DDGSumMode'              % Sum
            'DDGSumWordLength'
            'DDGSumFractionLength'
            'DDGSumFixedExponent'
            'DDGSumSlope'
            'DDGSumBias'

            'DDGCastBeforeSum'        % Cast before sum
                };

end

