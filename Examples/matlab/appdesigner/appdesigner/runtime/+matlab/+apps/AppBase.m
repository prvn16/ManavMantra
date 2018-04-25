classdef AppBase < handle
    %APPBASE This is the base class of an App which contains methods needed
    %by Apps.
    
    methods
        function delete(app)
            ams = appdesigner.internal.service.AppManagementService.instance();
            ams.unregister(app);            
        end
    end
    
    methods (Access = protected, Sealed = true)
        function newCallback = createCallbackFcn(app, callback, requiresEventData)
            if nargin == 2
                requiresEventData = false;
            end

            newCallback = @(source, event)tryCallback(appdesigner.internal.service.AppManagementService.instance(), ...
                app, callback, requiresEventData, event);
        end
        
        function runStartupFcn(app, startfcn)
            ams = appdesigner.internal.service.AppManagementService.instance();
            ams.tryCallback(app, startfcn, false, []);
        end
        
        function registerApp(app, uiFigure)
            ams = appdesigner.internal.service.AppManagementService.instance();
            ams.register(app, uiFigure);
        end
        
        function setAutoResize(~, uiFigure, value)
            matlab.ui.internal.layout.setAutoResize(uiFigure, value);
        end
    end
end
