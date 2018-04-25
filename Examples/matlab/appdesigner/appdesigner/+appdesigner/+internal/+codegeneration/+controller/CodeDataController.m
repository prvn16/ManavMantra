classdef CodeDataController < appdesservices.internal.interfaces.controller.AbstractController
    %CodeDataController Controller for the code model data
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods
        %------------------------------------------------------------------
        
        function obj = CodeDataController(model, proxyView)
            % constructor for the controller
            obj = obj@appdesservices.internal.interfaces.controller.AbstractController(model, [], proxyView);
            
            % notify the client that this controller has been
            % instantiated. Some code generation activity has already
            % occured by the time this is instantiated.
            proxyView.sendEventToClient('codeDataControllerCreated', {});
        end
        %------------------------------------------------------------------
        
        function createProxyView(~, ~)
            % No-Op implemented for Base Class
        end
        %------------------------------------------------------------------
    end
    
    methods(Access = protected)
        %------------------------------------------------------------------
        function handleEvent(obj, ~, event)
            import appdesigner.internal.codegeneration.compareGeneratedCodeToFileCode
            % handler for peer node events from the client
            switch event.Data.Name
                case 'callbacksUpdated'
                    obj.updateCallbacksAndStartupFcn(event.Data.CallbackData);
                    
                case 'editableSectionCodeChanged'
                    obj.handleEditableCodeChanged(event.Data.CodeData);
                    
                case 'compareCodeToFile'
                    compareGeneratedCodeToFileCode(obj.Model.GeneratedCode, ...
                        event.Data.AppFilePath, event.Data.OriginalRelease, event.Data.CurrentRelease);
            end
        end
        %------------------------------------------------------------------
        
        function getPropertiesForView(~, ~)
            % No-Op implemented for Base Class
        end
        %------------------------------------------------------------------
    end
    
    methods(Access = private)
        %------------------------------------------------------------------
        
        function handleEditableCodeChanged(obj, codeData)
            if(isempty(codeData))
                return
            end
            
            if(iscell(codeData))
                % handle client-side events that are cell arrays
                code = codeData;
            else
                code = {codeData.Code}';
            end
 
             obj.Model.EditableSectionCode  = code;
        end
        
        function updateCallbacksAndStartupFcn(obj, data)
        
            % The user has just saved the app.  Need to remove callbacks and 
            % startupFcn because what the callbacks are currently set on the server 
            % could be very different than whats on the client
            obj.Model.StartupCallback = struct.empty;
            obj.Model.Callbacks = struct.empty();
            
            % now recreate the startupFcn and callbacks
            idx = 0;
            for i = 1:length(data)
                if(strcmp(data(i).Type, 'AppStartupFunction'))
                    obj.Model.StartupCallback(1).Name = data(i).Name;
                    obj.Model.StartupCallback(1).Code = data(i).Code;
                else
                    % its a regular callback
                    idx = idx+1;
                    obj.Model.Callbacks(idx).Name = data(i).Name;
                    obj.Model.Callbacks(idx).Code = data(i).Code;
                end
            end
        end
        
    end
end
