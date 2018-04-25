% This class is undocumented.

% The RespectingOrderMixin can be included as a part of any class that can
% conditionally respect set elements. See NameValueMixin.m for details on
% the process to utilize this mixin.

%  Copyright 2010-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) RespectingOrderMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % RespectOrder - Specifies whether this instance respects the order of elements
        %
        %   When this value is true, the instance is sensitive to the order of the
        %   set members it applies to. When it is false, the instance is
        %   insensitive to the order of the set members and it is ignored.
        %
        %   The RespectOrder property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'RespectingOrder', true) parameter value pair.
        RespectOrder (1,1) = false;
    end

    methods (Hidden, Access=protected)
        function mixin = RespectingOrderMixin
            % Add RespectingOrder parameter and its set function
            mixin = mixin.addNameValue('RespectingOrder', @setRespectingOrder);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = respectingOrder(mixin)
            mixin.RespectOrder = true;
        end
    end
end

function mixin = setRespectingOrder(mixin, value)
validateattributes(value,{'logical'},{},'','RespectingOrder');
mixin.RespectOrder = value;
end

