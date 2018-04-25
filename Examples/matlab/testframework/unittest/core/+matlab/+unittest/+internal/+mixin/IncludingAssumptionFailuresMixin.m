% This class is undocumented.

% The IncludingAssumptionFailuresMixin can be included as a part of any
% class that can optionally react to assumption failures. See
% NameValueMixin.m for details on the process to utilize this mixin.

%  Copyright 2012-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) IncludingAssumptionFailuresMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % IncludeAssumptionFailures - determine whether this instance reacts to assumption failures
        %
        %   When this value is true, the instance reacts to assumption
        %   failures. When it is false, the instance ignores assumption failures.
        %
        %   The IncludeAssumptionFailures property is false by default, but
        %   can be specified to be true during construction of the instance
        %   by utilizing the (..., 'IncludingAssumptionFailures', true)
        %   parameter value pair.
        IncludeAssumptionFailures (1,1) = false;
    end
    
    methods (Hidden, Access=protected)
        function mixin = IncludingAssumptionFailuresMixin
            % Add IncludingAssumptionFailures parameter and its set function
            mixin = mixin.addNameValue('IncludingAssumptionFailures', @setIncludingAssumptionFailures);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = includingAssumptionFailures(mixin)
            mixin.IncludeAssumptionFailures = true;
        end
    end
end

function mixin = setIncludingAssumptionFailures(mixin, value)
validateattributes(value,{'logical'},{},'','IncludingAssumptionFailures');
mixin.IncludeAssumptionFailures = value;
end

