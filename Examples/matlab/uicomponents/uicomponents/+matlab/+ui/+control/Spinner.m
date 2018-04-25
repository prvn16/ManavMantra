classdef (ConstructOnLoad=true) Spinner < ...
        matlab.ui.control.internal.model.AbstractNumericComponent 
    %
    
    % Do not remove above white space
    % Copyright 2014-2016 The MathWorks, Inc.
    
    properties(Dependent)
        Step = 1;
    end
    
    properties(NonCopyable, Dependent)
        ValueChangingFcn@matlab.graphics.datatype.Callback = [];
    end
    
    properties(Access = 'private')
        PrivateStep = 1;
    end
    
    properties(NonCopyable, Access = 'private')
        PrivateValueChangingFcn@matlab.graphics.datatype.Callback = [];
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ValueChanging
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = Spinner(varargin)
            %
            
            % Do not remove above white space
            % Defaults
            defaultSize = [100, 22];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;            
            obj.Type = 'uispinner';
            
            parsePVPairs(obj,  varargin{:});
            
            obj.attachCallbackToEvent('ValueChanging', 'PrivateValueChangingFcn');
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    
    methods
        function set.Step(obj, newStep)
            % Error Checking
            try
                % newStep should be a numeric value.
                % NaN, Inf, empty are not accepted
                validateattributes(...
                    newStep, ...
                    {'numeric'}, ...
                    {'scalar', 'real', 'positive', 'finite'} ...
                    );
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidStep', ...
                    'Step');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidValue';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Reject fractional value of Step if RoundFractionalValues is
            % 'on'
            if(strcmp(obj.RoundFractionalValues, 'on'))
                try
                    validateattributes(...
                        newStep, ...
                        {'numeric'}, ...
                        {'integer'} ...
                        );
                catch
                    messageObj = message('MATLAB:ui:components:invalidStepWhenRoundingIsTrue', ...
                        'Step', 'RoundFractionalValues', 'on');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'invalidStepWhenRoundingIsTrue';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
            end
            
            % Property Setting
            obj.PrivateStep = newStep;
            
            obj.markPropertiesDirty({'Step'});
        end
        
        function step = get.Step(obj)
            step = obj.PrivateStep;
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
        
        function doSetRoundFractionalValues(obj, newRoundFractionalValues)
            % Do not allow setting of RoundFractionalValues to true/1 if
            % Step is currently a fractional value
            
            if(~(mod(obj.PrivateStep, 1) == 0) && obj.PrivateStep > 0)
                if(strcmp(newRoundFractionalValues, 'on'))
                    
                    messageObj = message('MATLAB:ui:components:invalidRoundFractionalValueWhenStepIsFloat', ...
                        'RoundFractionalValues', 'on', 'Step');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'invalidRoundFractionalValueWhenStepIsFloat';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
            end
            
            doSetRoundFractionalValues@matlab.ui.control.internal.model.AbstractNumericComponent(obj, newRoundFractionalValues);
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
                'ValueDisplayFormat',...
                'RoundFractionalValues',...
                'Step',...
                'Limits',...
                'LowerLimitInclusive',...
                'UpperLimitInclusive',...
                ...Callbacks
                'ValueChangedFcn', ...
                'ValueChangingFcn'};
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = num2str(obj.Value);
            
        end
    end
end

