% This class is undocumented.

% The PreservingOnFailureMixin can be included as a part of any class that
% can optionally preserve content after a failure. See NameValueMixin.m for
% details on the process to utilize this mixin.

%  Copyright 2013-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) PreservingOnFailureMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % PreserveOnFailure - determine whether this instance preserves content after a failure
        %
        %   When this value is true, the instance preserves content after a
        %   failure.
        %
        %   The PreserveOnFailure property is false by default, but can be
        %   specified to be true during construction of the instance by utilizing
        %   the (..., 'PreservingOnFailure', true) parameter value pair.
        PreserveOnFailure (1,1) = false;
    end
    
    methods (Hidden, Access=protected)
        function mixin = PreservingOnFailureMixin
            % Add PreservingOnFailure parameter and its set function
            mixin = mixin.addNameValue('PreservingOnFailure', @setPreservingOnFailure);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = preservingOnFailure(mixin)
            mixin.PreserveOnFailure = true;
        end
    end
end

function mixin = setPreservingOnFailure(mixin, value)
validateattributes(value,{'logical'},{},'','PreservingOnFailure');
mixin.PreserveOnFailure = value;
end

