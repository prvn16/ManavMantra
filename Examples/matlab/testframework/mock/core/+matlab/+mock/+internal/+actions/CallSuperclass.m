classdef CallSuperclass < matlab.mock.actions.MethodCallAction
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable, GetAccess=private)
        Superclass string;
    end
    
    methods
        function action = CallSuperclass(superclass)
            validateattributes(superclass, {'meta.class'}, {'scalar'});
            action.Superclass = superclass.Name;
        end
    end
    
    methods (Hidden)
        function varargout = callMethod(action, ~, methodName, ~, varargin)
            [varargout{1:nargout}] = builtin('matlab.mock.internal.callSuperclassMethod', ...
                action.Superclass, methodName, varargin{:});
        end
    end
end

