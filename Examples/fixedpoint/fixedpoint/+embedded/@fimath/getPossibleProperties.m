function props = getPossibleProperties(~)
%GETPOSSIBLEPROPERTIES Possible properties for list view of Model Explorer.
%
%   GETPOSSIBLEPROPERTIES(X) Returns a list of properties that could be
%   viewed in the list view of the Model Explorer for object X.

%   Copyright 2016 The MathWorks, Inc.

        props = {
            'Name'                % Name

          
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

