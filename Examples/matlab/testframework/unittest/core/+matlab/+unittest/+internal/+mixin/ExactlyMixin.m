% This class is undocumented.

% The ExactlyMixin can be included as a part of any class that can
% conditionally respect set elements. See NameValueMixin.m for details on
% the process to utilize this mixin.

%  Copyright 2011-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) ExactlyMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % Exact - Specifies whether this instance performs exact comparisons
        %
        %   When this value is true, the instance is sensitive to all ignorable
        %   differences and respects all applicable variations. When it is false,
        %   the instance relies on specification of other parameters and default
        %   instance behavior in order to determine the strictness of its
        %   comparison.
        %
        %   The Exact property is false by default, but can be specified to
        %   be true during construction of the instance by utilizing the
        %   (..., 'Exactly', true) parameter value pair.
        Exact (1,1) = false;
    end
    
    methods (Hidden, Access=protected)
        function mixin = ExactlyMixin
            % Add Exactly parameter and its set function
            mixin = mixin.addNameValue('Exactly', @setExactly);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = exactly(mixin)
            mixin.Exact = true;
        end
    end
end

function mixin = setExactly(mixin, value)
validateattributes(value,{'logical'},{},'','Exactly');
mixin.Exact = value;
end