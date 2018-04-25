% This class is undocumented.

% The IgnoringCaseMixin can be included as a part of any class that can
% ignore case differences. See NameValueMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2010-2016 The MathWorks, Inc.
classdef (Hidden) IgnoringCaseMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % IgnoreCase - Boolean indicating whether this instance is insensitive to case
        %
        %   When this value is true, the instance is insensitive to case
        %   differences. When it is false, the instance is sensitive to case.
        %
        %   The IgnoreCase property is false by default, but can be
        %   specified to be true during construction of the instance by
        %   utilizing the (..., 'IgnoringCase', true) parameter value pair.
        IgnoreCase (1,1) = false;
    end
    
    methods (Hidden, Access=protected)
        function mixin = IgnoringCaseMixin
            mixin = mixin.addNameValue('IgnoringCase', ...
                @setIgnoreCase,...
                @ignoringCasePreSet,...
                @ignoringCasePostSet);
        end
        
        function [mixin,value] = ignoringCasePreSet(mixin,value)
            validateattributes(value,{'logical'},{},'','IgnoringCase');
        end
        
        function mixin = ignoringCasePostSet(mixin)
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = ignoringCase(mixin)
            mixin = mixin.setIgnoreCase(true);
            mixin = mixin.ignoringCasePostSet();
        end
    end
    
    methods (Access=private)
        function mixin = setIgnoreCase(mixin, value)
            mixin.IgnoreCase = value;
        end
    end
end