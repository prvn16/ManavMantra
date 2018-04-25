% This class is undocumented.

% The RespectingCountMixin can be included as a part of any class that can
% conditionally respect the number of occurrences of elements. See
% NameValueMixin.m for details on the process to utilize this mixin.

%  Copyright 2011-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) RespectingCountMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % RespectCount - Specifies whether this instance respects element counts
        %
        %   When this value is true, the instance is sensitive to the total number
        %   of set members. When it is false, the instance is insensitive to
        %   the number of occurrences of members and their frequency is ignored.
        %
        %   The RespectCount property is false by default, but can be specified to be
        %   true during construction of the instance by utilizing the
        %   (..., 'RespectingCount', true) parameter value pair.
        RespectCount (1,1) = false;
    end
    
    methods (Hidden, Access=protected)
        function mixin = RespectingCountMixin
            % Add RespectingCount parameter and its set function
            mixin = mixin.addNameValue('RespectingCount', @setRespectingCount);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = respectingCount(mixin)
            mixin.RespectCount = true;
        end
    end
end

function mixin = setRespectingCount(mixin, value)
validateattributes(value,{'logical'},{},'','RespectingCount');
mixin.RespectCount = value;
end

