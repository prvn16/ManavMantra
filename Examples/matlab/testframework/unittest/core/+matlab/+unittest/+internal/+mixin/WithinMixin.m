% This class is undocumented.

% The WithinMixin can be included as a part of class that supports
% specifying a tolerance. See NameValueMixin.m for details on the process
% to utilize this mixin.

%  Copyright 2012-2015 The MathWorks, Inc.
classdef (Hidden) WithinMixin < matlab.unittest.internal.mixin.NameValueMixin
    properties (SetAccess=private)
        % Tolerance - A matlab.unittest.constraints.Tolerance object
        %
        %   When specified, the instance uses the specified tolerance.
        %
        %   The Tolerance property is empty by default, but can be
        %   specified any valid tolerance during construction of the
        %   instance by utilizing the (..., 'Within', tolerance) parameter
        %   value pair.
        Tolerance = [];
    end
    
    methods (Hidden, Access=protected)
        function mixin = WithinMixin
            % Add Within parameter and its set function
            mixin = mixin.addNameValue('Within', ...
                @setTolerance,...
                @withinPreSet,...
                @withinPostSet);
        end
        
        function [mixin, tol] = withinPreSet(mixin, tol)
            validateattributes(tol, ...
                {'matlab.unittest.constraints.Tolerance'}, ...
                {'scalar'}, '', 'Tolerance');
        end
        
        function mixin = withinPostSet(mixin)
        end
    end
    
    methods (Hidden, Sealed)
        function mixin = within(mixin, tol)
            [mixin, tol] = mixin.withinPreSet(tol);
            mixin = mixin.setTolerance(tol);
            mixin = mixin.withinPostSet();
        end
    end
    
    methods (Access=private)
        function mixin = setTolerance(mixin, tol)
            mixin.Tolerance = tol;
        end
    end
end