classdef AppDesignerNoPositionPropertyView < ...
        internal.matlab.inspector.InspectorProxyMixin & ...
        matlab.ui.internal.componentframework.services.optional.ControllerInterface
    
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    properties(SetObservable = true)
        % These properties are common to all the components. So,
        % instead of defining them in Property Views of every component,
        % these are defined only once in parent class here.
        BusyAction
        Interruptible
    end
    
    properties(SetAccess = 'private')        
        Type
    end
    
    methods
        
        function obj = AppDesignerNoPositionPropertyView(componentObject)
            obj = obj@internal.matlab.inspector.InspectorProxyMixin(componentObject);
        end
        
        function status = setPropertyValue(obj, varargin)
            
            % Let parent class take care of setting
            status = setPropertyValue@internal.matlab.inspector.InspectorProxyMixin(obj, varargin{:});
            
            % Get the controller
            controller = obj.OriginalObjects.getControllerHandle();
            
            % For GBT Controllers
            %
            % Need to force a re-population of the peer node
            %
            % TODO: this forces a repopulation for properties that work in
            % run time
            %
            % If the property is managed in design time, then this code
            % path will not hit it.  Still a work in progress
            if(ismethod(controller, 'setProperty'))
                controller.setProperty(varargin{1});
            end
            
            % For use when in App Designer
            %
            % After a successful edit... regenerate code
            if(ismethod(controller, 'updateGeneratedCode'))
                controller.updateGeneratedCode();
                % 				disp(['Inspector Edit: ' class(obj.OriginalObjects) ' property ' varargin{1}]);
                % 				newValue = varargin{2}
            end
        end
        
    end
end


