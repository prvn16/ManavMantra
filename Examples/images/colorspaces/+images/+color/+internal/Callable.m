% Mixin class to implement the behavior of using () to indicate function
% evaluation.

% Copyright 2014 The MathWorks, Inc.

classdef Callable < images.color.internal.Scalar
    
    methods (Abstract)
        evaluate(this_callable,varargin)
    end
    
    methods
        function varargout = subsref(self, s)
            if strcmp(s(1).type, '()')
                [varargout{1:nargout}] = self.evaluate(s(1).subs{:});
            else
                [varargout{1:nargout}] = builtin('subsref', self, s);
            end
        end
    end
end
