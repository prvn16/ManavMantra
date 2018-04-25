classdef (Hidden) AbstractBinaryComponent < ...
        matlab.ui.control.internal.model.ComponentModel & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent& ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent

        
    % Copyright 2014 The MathWorks, Inc.
    
    properties(Dependent)
        Value = false;
    end
    
    properties(NonCopyable, Dependent)
        ValueChangedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    properties(Access = {?matlab.ui.control.internal.model.AbstractBinaryComponent, ...
            ?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValue = false;
    end 
    
    properties(NonCopyable, Access = 'protected')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValueChangedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ValueChanged
    end
    
    
    methods
        
        % -----------------------------------------------------------------
        % Constructor
        % ---------------------------------------------------------------------
        function obj = AbstractBinaryComponent(varargin)
            % call super            
            obj@matlab.ui.control.internal.model.ComponentModel(varargin{:});                        
            
            % Wire callbacks
            obj.attachCallbackToEvent('ValueChanged', 'PrivateValueChangedFcn');	             
        end
        
        
        % -----------------------------------------------------------------
        % Property Getters / Setters
        % -----------------------------------------------------------------
        function set.Value(obj, newValue)
            % Error Checking
            try
                newValue = matlab.ui.control.internal.model.PropertyHandling.validateLogicalScalar(newValue);
                
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidBooleanProperty', ...
                    'Value');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidSelected';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateValue = newValue;
            
            % Update View
            markPropertiesDirty(obj, {'Value'});
        end
        
        function value = get.Value(obj)
            value = obj.PrivateValue;
        end
        
        % ---------------------------------------------------------------------
        function set.ValueChangedFcn(obj, newValueChangedFcn)
            % Property Setting
            obj.PrivateValueChangedFcn = newValueChangedFcn;
            
            obj.markPropertiesDirty({'ValueChangedFcn'});
        end
        
        function value = get.ValueChangedFcn(obj)
            value = obj.PrivateValueChangedFcn;
        end
        
    end
    
end
