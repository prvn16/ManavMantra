classdef (Hidden) AbstractGaugeComponent < ...
        matlab.ui.control.internal.model.AbstractTickComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent

    
    % This undocumented class may be removed in a future release.
    
    % This is the parent class for all gauge components.
    %
    % It provides all properties specific to gauges.
    
    % Copyright 2011 The MathWorks, Inc.
    
    properties(Dependent)
        Value = 0;
        
        ScaleColors = [];
        
        ScaleColorLimits = [];
    end
    
    properties(Dependent, Access = 'private')
        % These 2 properties are not exposed to the users. As a result we
        % are setting their access level to private. These properties are
        % not deleted because we expect them to return soon in r2015a.
        % Also, the setters and getters for these properties have been left
        % untouched.
        ValueDisplayFormat = '%11.4g';
        
        ValueDisplayVisible@matlab.graphics.datatype.on_off = 'off';
        
    end
    
    
    properties(Access = 'protected')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, beacuse sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValue = 0;
        
        PrivateValueDisplayFormat = '%11.4g';
        
        PrivateValueDisplayVisible@matlab.graphics.datatype.on_off = 'off';
        
        PrivateScaleColors = [];
        
        PrivateScaleColorLimits = [];
        
        PrivateScaleColorLimitsMode = 'auto';
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = AbstractGaugeComponent(varargin)
            
            defaultLabel = 'Gauge';
            
            % Super
            obj = obj@matlab.ui.control.internal.model.AbstractTickComponent(varargin{:});
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Value(obj, newValue)
            % Error Checking
            try
                validateattributes(newValue, ...
                    {'numeric'}, ...
                    {'scalar', 'finite', 'nonempty'});
                
                % convert any non-double to a double
                finalValue = double(newValue);
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidValue', ...
                    'Value');
                                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidValue';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception 
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
            end
            
            % Property Setting
            obj.PrivateValue = finalValue;
            
            obj.markPropertiesDirty({'Value'});
        end
        
        function value = get.Value(obj)
            value = obj.PrivateValue;
        end
        
        function set.ValueDisplayFormat(obj, newFormatString)
            
            % Error Checking
            try
                newFormatString = matlab.ui.control.internal.model.PropertyHandling.validateDisplayFormat(...
                                    obj,...
                                    newFormatString, ...
                                    'ValueDisplayFormat', ...
                                    obj.PrivateValue...
                                    );
            catch ex
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidNumericDisplayFormat';
                
                % Use string from object
                messageText = ex.message;
                
                % Create and throw exception 
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, '%s', messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateValueDisplayFormat = newFormatString;
            
            obj.markPropertiesDirty({'ValueDisplayFormat'});
        end
        
        function ValueDisplayFormat = get.ValueDisplayFormat(obj)
            ValueDisplayFormat = obj.PrivateValueDisplayFormat;
        end
        
        function set.ValueDisplayVisible(obj, newValue)
            
            % Error Checking done through the datatype specification
            
            % Property Setting
            obj.PrivateValueDisplayVisible = newValue;
            
            obj.markPropertiesDirty({'ValueDisplayVisible'});
        end
        
        function ValueDisplayVisible = get.ValueDisplayVisible(obj)
            ValueDisplayVisible = obj.PrivateValueDisplayVisible;
        end
        
        
        
        % -----------------------------------------------------------------
        
        function set.ScaleColors(obj, newScaleColors)
            % Error Checking
            try
                newScaleColors = matlab.ui.control.internal.model.PropertyHandling.validateColorsArray(obj, newScaleColors);
            catch  %#ok<*CTCH>
                messageObj =  message('MATLAB:ui:components:invalidColorArray', ...
                    'ScaleColors');
                
                % Use string from object
                messageText = getString(messageObj);
                
                docLinkId = 'MATLAB:ui:components:colorspecDocLink';
                messageText = matlab.ui.control.internal.model.PropertyHandling.createMessageWithDocLink(messageText, docLinkId, 'ColorSpec (Color Specification)');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidScaleColors';
                              
                % Create and throw exception 
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, '%s', messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateScaleColors = newScaleColors;
            
            % Updates
            obj.updateScaleColorLimits();
            
            obj.markPropertiesDirty({'ScaleColors', 'ScaleColorLimits'});
        end
        
        function value = get.ScaleColors(obj)
            value = obj.PrivateScaleColors;
        end
        
        % -----------------------------------------------------------------
        
        function set.ScaleColorLimits(obj, scaleColorLimits)
            
            % validateattributes() does not handle cases like "It can be an
            % Nx2 OR empty", so it is easiest to check explicitly.
            
            %  Special check for []
            if(isempty(scaleColorLimits) && isnumeric(scaleColorLimits))
                obj.PrivateScaleColorLimits = [];
                obj.markPropertiesDirty({'ScaleColorLimits'});
                
                obj.PrivateScaleColorLimitsMode = 'manual';
                return;
            end
            
            % Error Checking
            try
                % Ensure the input is a N x 2
                validateattributes(scaleColorLimits, ...
                    {'numeric'}, ...
                    {'size', [NaN, 2]});
            catch
                messageObj = message('MATLAB:ui:components:invalidScaleColorLimits', ...
                    'ScaleColorLimits');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidScaleColorLimits';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception 
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Ensure that every row is increasing
            isFirstElementLessThanSecond = scaleColorLimits(:, 1) < scaleColorLimits(:, 2);
            
            if(~all(isFirstElementLessThanSecond))
                messageObj = message('MATLAB:ui:components:nonIncreasingScaleColorLimits', ...
                    'ScaleColorLimits');
                
                % MnemonicField is last section of error id
                mnemonicField = 'nonIncreasingScaleColorLimits';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception 
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);

            end
            
            % Property Setting
            obj.PrivateScaleColorLimits = scaleColorLimits;
            obj.PrivateScaleColorLimitsMode = 'manual';
            
            obj.markPropertiesDirty({'ScaleColorLimits'});
        end
        
        function colorLimits = get.ScaleColorLimits(obj)
            colorLimits = obj.PrivateScaleColorLimits;
        end
    end
    
    % ---------------------------------------------------------------------
    % Scale Color Limits generating functions
    % ---------------------------------------------------------------------
    methods(Access = 'private')
        
        function updateScaleColorLimits(obj)
            % Generates ScaleColorLimits
            
            if(~strcmp(obj.PrivateScaleColorLimitsMode, 'auto'))
                return;
            end
            
            % Ex: 3 colors
            numberOfColors = size(obj.PrivateScaleColors, 1);
            
            % Special check for no colors
            %
            % Otherwise, the code below generates a: Empty matrix: 0-by-2
            % instead of []
            if(numberOfColors == 0)
                obj.PrivateScaleColorLimits = [];
                return;
            end
            
            % Ex: If limits were [0 30], then interval is 10
            interval = (obj.PrivateLimits(2) - obj.PrivateLimits(1)) / numberOfColors;
            
            % Ex: Start Points would be [0 10 20]
            startPoints = obj.PrivateLimits(1) : interval : obj.PrivateLimits(2) - interval;
            
            % Ex: End Points would be [10 20 30]
            endPoints = obj.PrivateLimits(1) + interval : interval : obj.PrivateLimits(2);
            
            % Ex: Create limits by turning into columns and combining
            %
            % [  0  10
            %   10  20
            %   20  30 ]
            obj.PrivateScaleColorLimits = [startPoints' endPoints'];
        end
        
    end
    
    methods(Access = 'protected')
        
        function updatedProperties = updatesAfterLimitsChanges(obj)
            %Update the Scale Color Limits
            obj.updateScaleColorLimits();
            updatedProperties = {'ScaleColorLimits'};
        end
        
        function [scaleColors, scaleColorLimits] = getScaleColorForDisplay(obj)
            % The properties ScaleColors and ScaleColorLimits might not be
            % of the same number of rows.
            % For the custom display, we need both arrays to have the same
            % number of rows. If one array has more rows than the other, the
            % additional rows are discarded for display purpose.
            % This function returns both arrays, truncated if necessary.
            
            scaleColors = obj.ScaleColors;
            scaleColorLimits = obj.ScaleColorLimits;
            
            nScaleColors = size(scaleColors,1);
            nScaleColorLimits = size(scaleColorLimits,1);
            
            if (nScaleColors > nScaleColorLimits)
                scaleColors = obj.ScaleColors(1: nScaleColorLimits, :);
            elseif (nScaleColorLimits > nScaleColors)
                scaleColorLimits = obj.ScaleColorLimits(1: nScaleColors, :);
            end
            
        end
    end
    
end
