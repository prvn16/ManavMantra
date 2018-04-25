classdef ErrorInHGCallbacks < matlab.uiautomation.internal.DispatchDecorator
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        
        function decorator = ErrorInHGCallbacks(delegate)
            decorator@matlab.uiautomation.internal.DispatchDecorator(delegate);
        end
        
        function dispatchEventAndWait(decorator, varargin)
            if ~isempty(gcbo)
                error( message('MATLAB:uiautomation:Driver:NotAllowedInHGCallbacks') );
            end
            dispatchEventAndWait@matlab.uiautomation.internal.DispatchDecorator( ...
                decorator, varargin{:});
        end
        
    end
    
end