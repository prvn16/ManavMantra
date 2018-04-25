classdef Invoke < matlab.mock.actions.MethodCallAction & ...
        matlab.mock.actions.PropertyGetAction & ...
        matlab.mock.actions.PropertySetAction
    % This class is undocumented and may change in a future release.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        Function function_handle;
    end
    
    methods
        function action = Invoke(fcn)
            action.Function = fcn;
        end
        
        function varargout = callMethod(action, ~, ~, ~, varargin)
            [varargout{1:nargout}] = action.Function(varargin{:});
        end
        
        function value = getProperty(action, ~, ~, object)
            value = action.Function(object);
        end
        
        function setProperty(action, ~, ~, object, value)
            action.Function(object, value);
        end
    end
end

