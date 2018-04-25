% This class is undocumented.

% The WhenNargoutIsMixin can be included as a part of any class that can
% execute functions while specifying a number of outputs. See
% NameValueMixin.m for details on the process to utilize this mixin.

%  Copyright 2011-2016 The MathWorks, Inc.
classdef (Hidden, HandleCompatible) WhenNargoutIsMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % Nargout - Specifies the number of outputs this instance should supply
        %
        %   The Nargout value can be a non-negative real scalar integer. It
        %   determines the number of output arguments the instance will use
        %   when executing functions.
        %
        %   The Nargout property is 0 by default, but can be specified to
        %   be a higher value during construction of the instance by
        %   utilizing the (..., 'WhenNargoutIs', N) parameter value pair,
        %   which applies N output arguments.
        Nargout = 0;
    end
    
    methods (Hidden, Access=protected)
        function mixin = WhenNargoutIsMixin
            % Add WhenNargoutIs parameter and its set function
            mixin = mixin.addNameValue('WhenNargoutIs', @whenNargoutIs);
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = whenNargoutIs(mixin, value)
            validateattributes(value, ...
                {'numeric'}, {'scalar','nonnegative','integer','real'}, '', 'Nargout');
            mixin.Nargout = value;
        end
    end
end