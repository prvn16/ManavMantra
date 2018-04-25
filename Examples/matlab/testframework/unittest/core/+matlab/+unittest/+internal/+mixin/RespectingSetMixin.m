% This class is undocumented.

% The RespectingSetMixin can be included as a part of any class that can
% conditionally respect set elements. See NameValueMixin.m for details on
% the process to utilize this mixin.

%  Copyright 2010-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) RespectingSetMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % RespectSet - Specifies whether this instance respects set elements
        %
        %   When this value is true, the instance is sensitive to additional set
        %   members. When it is false, the instance is insensitive to additional
        %   set members and they are ignored.
        %
        %   The RespectSet property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'RespectingSet', true) parameter value pair.
        RespectSet (1,1) = false;
    end
 
    methods (Hidden, Access=protected)
        function mixin = RespectingSetMixin
            % Add RespectingSet parameter and its set function
            mixin = mixin.addNameValue('RespectingSet', @setRespectingSet);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = respectingSet(mixin)
            mixin.RespectSet = true;
        end
    end
end

function mixin = setRespectingSet(mixin, value)
validateattributes(value,{'logical'},{},'','RespectingSet');
mixin.RespectSet = value;
end

