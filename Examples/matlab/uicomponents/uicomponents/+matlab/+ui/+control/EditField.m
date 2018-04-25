classdef (ConstructOnLoad=true) EditField < ...        
        matlab.ui.control.internal.model.ComponentModel & ...        
        matlab.ui.control.internal.model.mixin.EditableComponent & ...
        matlab.ui.control.internal.model.mixin.HorizontallyAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent & ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent
    %

    % Do not remove above white space
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties(Dependent)
        Value = '';
    end
    
    properties(NonCopyable, Dependent)
                
        ValueChangedFcn@matlab.graphics.datatype.Callback = [];
        
        ValueChangingFcn@matlab.graphics.datatype.Callback = [];
    end
    
    properties(Access = {?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValue = '';
    end 
    
    properties(NonCopyable, Access = 'private')
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
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ValueChanged
        
        ValueChanging
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = EditField(varargin)
            %

            % Do not remove above white space
            % Defaults
            defaultSize = [100, 22];
			obj.PrivateInnerPosition(3:4) = defaultSize;
			obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.Type = 'uieditfield';
            
            parsePVPairs(obj,  varargin{:});
            
            % Wire callbacks
            obj.attachCallbackToEvent('ValueChanged', 'PrivateValueChangedFcn');
            obj.attachCallbackToEvent('ValueChanging', 'PrivateValueChangingFcn');
        end
        % ----------------------------------------------------------------------
        
        function set.Value(obj, newValue)
            % Error Checking
            try
                newValue = matlab.ui.control.internal.model.PropertyHandling.validateText(newValue);
            catch %#ok<CTCH>
                messageObj = message('MATLAB:ui:components:invalidTextValue', ...
                    'Value');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidText';
                
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
        
        % ----------------------------------------------------------------------
        
        function set.ValueChangedFcn(obj, newValue)
            % Property Setting            
            obj.PrivateValueChangedFcn = newValue;
            
            % Dirty
            obj.markPropertiesDirty({'ValueChangedFcn'});
        end
        
        function value = get.ValueChangedFcn(obj)
            value = obj.PrivateValueChangedFcn;
        end
        
        % ----------------------------------------------------------------------
        
        function set.ValueChangingFcn(obj, newValue)
            % Property Setting            
            obj.PrivateValueChangingFcn = newValue;
            
            % Dirty
            obj.markPropertiesDirty({'ValueChangingFcn'});
        end
        
        function value = get.ValueChangingFcn(obj)
            value = obj.PrivateValueChangingFcn;
        end
        
    end
   
    % ---------------------------------------------------------------------
    % Custom Display Functions
    % ---------------------------------------------------------------------
    methods(Access = protected)
        
        function names = getPropertyGroupNames(obj)
            % GETPROPERTYGROUPNAMES - This function returns common
            % properties for this class that will be displayed in the
            % curated list properties for all components implementing this
            % class.
            
            names = {'Value',...
                ...Callbacks
                'ValueChangedFcn', ...
                'ValueChangingFcn'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = obj.Value;
        
        end
    end
end

