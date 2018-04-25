classdef CodeModel < handle...
        & appdesigner.internal.model.AbstractAppDesignerModel
    %CodeModel  Server-side representation of code data from the client
    
    % Copyright 2015-2017 The MathWorks, Inc.
    properties(Transient)
        % the class name of the App
        ClassName;
        
        % a 1xN struct array of callbacks
        Callbacks;
        
        % the startup function structure
        StartupCallback;
        
        % n x 1 cell array
        EditableSectionCode;
        
        % the input parameters to the app.
        InputParameters;
    end
    
    properties(Transient)
        % an property to access the generated code
        GeneratedCode
    end
    
    methods
        %------------------------------------------------------------------
        
        function obj = CodeModel(appModel, proxyView)
            % constructor
            
            % create an empty structure for the callbacks and startupFcn
            obj.Callbacks = struct.empty;
            obj.StartupCallback = struct.empty();
            
            obj.EditableSectionCode = {};
            
            if (nargin > 0)
                % assign this object to the App Model handle
                appModel.CodeModel = obj;
                
                % instantiate a controller
                obj.createController(proxyView);
            end
        end

        %------------------------------------------------------------------
        
        function sendGoToLineColumnEventToClient(obj, line, column, scrollToView)
            % send gotoLineColumn peerEvent to CodeModel on client side
            % TODO: this function needs to be refactored/moved. It is
            % necessary for code realted functionality but is not related
            % to code data
            obj.Controller.ProxyView.sendEventToClient('goToLineColumn', ...
                {'Line', line, 'Column', column, 'ScrollToView', scrollToView});
        end
        %------------------------------------------------------------------
        
    end
    
    methods(Access = public)
        %------------------------------------------------------------------
        
        function controller = createController(obj,  proxyView)
            % Creates the controller for this Model.  this method is the concrete implementation of the 
            % abstract method from appdesigner.internal.model.AbstractAppDesignerModel
            controller = appdesigner.internal.codegeneration.controller.CodeDataController(obj, proxyView);
        end
        %------------------------------------------------------------------
    end
    
end
