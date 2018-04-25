classdef (Abstract) DispatchDecorator < matlab.uiautomation.internal.UIDispatcher
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        Delegate
    end
    
    methods
        
        function decorator = DispatchDecorator(delegate)
            decorator.Delegate = delegate;
        end
        
        function dispatchEventAndWait(decorator, varargin)
            decorator.Delegate.dispatchEventAndWait(varargin{:});
        end
        
    end
    
end