classdef (Hidden)  AbstractInteractiveTickComponent < ...
        matlab.ui.control.internal.model.AbstractTickComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent
    
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties(Dependent)
        Value = 0;      
    end
    
    properties(NonCopyable, Dependent)
        ValueChangedFcn@matlab.graphics.datatype.Callback = [];
        
        ValueChangingFcn@matlab.graphics.datatype.Callback = [];
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ValueChanged
        
        ValueChanging
    end
    
     properties(Access = {?matlab.ui.control.internal.model.AbstractInteractiveTickComponent, ...
            ?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValue = 0;
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
        
        PrivateValueChangingFcn@matlab.graphics.datatype.Callback = [];
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = AbstractInteractiveTickComponent(varargin)
            
            % Call the parent constructor
			obj = obj@matlab.ui.control.internal.model.AbstractTickComponent(varargin{:});              
            
            obj.attachCallbackToEvent('ValueChanged', 'PrivateValueChangedFcn');	             
            obj.attachCallbackToEvent('ValueChanging', 'PrivateValueChangingFcn');	             
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Value(obj, newValue)
            % Error Checking
            try
                % Ensure that Value is between Limits
                lowerLimit = obj.PrivateLimits(1);
                upperLimit = obj.PrivateLimits(2);
                
                validateattributes(newValue, ...
                    {'double'}, ...
                    {'scalar', 'finite', 'nonempty', ...
                    '>=', lowerLimit, ...
                    '<=', upperLimit});
                
            catch  %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:valueNotInRange', ...
                    'Value', 'Limits');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidValue';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateValue = newValue;
            
            obj.markPropertiesDirty({'Value'});
        end
        
        function value = get.Value(obj)
            value = obj.PrivateValue;
        end
        
        function set.ValueChangedFcn(obj, newValueChangedFcn)
            % Property Setting
            obj.PrivateValueChangedFcn = newValueChangedFcn;
            obj.markPropertiesDirty({'ValueChangedFcn'});
        end
        
        function value = get.ValueChangedFcn(obj)
            value = obj.PrivateValueChangedFcn;
        end
        
        function set.ValueChangingFcn(obj, newValueChangingFcn)
            % Property Setting
            obj.PrivateValueChangingFcn = newValueChangingFcn;
            obj.markPropertiesDirty({'ValueChangingFcn'});
        end
        
        function value = get.ValueChangingFcn(obj)
            value = obj.PrivateValueChangingFcn;
        end        

                    
    end
    methods(Access = 'protected')
        
        function updatedProperties = updatesAfterLimitsChanges(obj)          
            %Ensure value is within the new limits
            obj.PrivateValue = matlab.ui.control.internal.model.PropertyHandling.calibrateValue(obj.PrivateLimits, obj.PrivateValue);            
            updatedProperties = {'Value'};
        end   
    end
      

end

