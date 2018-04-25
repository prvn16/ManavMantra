classdef ThrowableDispatchDecorator < matlab.uiautomation.internal.DispatchDecorator
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        
        function decorator = ThrowableDispatchDecorator(dispatcher)
            decorator@matlab.uiautomation.internal.DispatchDecorator(dispatcher);
        end
        
        function dispatchEventAndWait(decorator, varargin)
            import matlab.ui.internal.HGCallbackErrorLogger;
            
            feat = feature('SuppressHGCallbackErrors',true);
            clean = onCleanup(@()feature('SuppressHGCallbackErrors', feat));
            
            logger = HGCallbackErrorLogger;
            logger.start;
            dispatchEventAndWait@ ...
                matlab.uiautomation.internal.DispatchDecorator(...
                decorator, varargin{:});
            logger.stop;
            
            if ~isempty(logger.Log)
                throw(logger.Log(1));
            end
        end
        
    end
    
end