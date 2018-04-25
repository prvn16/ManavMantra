classdef (Hidden) AbstractNumericComponent < ...
        matlab.ui.control.internal.model.ComponentModel & ...
        matlab.ui.control.internal.model.mixin.EditableComponent & ...
        matlab.ui.control.internal.model.mixin.HorizontallyAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...
        matlab.ui.control.internal.model.mixin.BackgroundColorableComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent& ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent
    
    % This undocumented class may be removed in a future release.
    
    % This is the parent class for edit field components that only accept numeric inputs.
    % e.g. Numeric edit field, Spinner
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties(Dependent)
        Value = 0;
        
        Limits = [-Inf, Inf];
        
        LowerLimitInclusive@matlab.graphics.datatype.on_off = 'on';
        
        UpperLimitInclusive@matlab.graphics.datatype.on_off = 'on';
        
        RoundFractionalValues@matlab.graphics.datatype.on_off = 'off';
        
        ValueDisplayFormat = '%11.4g';
    end
    
    properties(NonCopyable, Dependent)
        ValueChangedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    properties(Access = {?matlab.ui.control.internal.model.AbstractNumericComponent, ...
            ?appdesservices.internal.interfaces.controller.AbstractController})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateValue = 0;
        
        PrivateLimits = [-Inf, Inf];
        
        PrivateLowerLimitInclusive@matlab.graphics.datatype.on_off = 'on';
        
        PrivateUpperLimitInclusive@matlab.graphics.datatype.on_off = 'on';
        
        PrivateRoundFractionalValues@matlab.graphics.datatype.on_off = 'off'; 
        
        PrivateValueDisplayFormat = '%11.4g';
    end
    
    properties(NonCopyable, Access = {?matlab.ui.control.internal.model.AbstractNumericComponent, ...
            ?appdesservices.internal.interfaces.controller.AbstractController})
        
        PrivateValueChangedFcn@matlab.graphics.datatype.Callback = [];        
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ValueChanged
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = AbstractNumericComponent(varargin)
            
            obj = obj@matlab.ui.control.internal.model.ComponentModel(varargin{:});
            
            % Override the default values
            obj.IsSizeFixed = [false false];
            obj.HorizontalAlignment = 'right';
            
            obj.attachCallbackToEvent('ValueChanged', 'PrivateValueChangedFcn');
            
        end
        
        % ----------------------------------------------------------------------
        
        function set.Value(obj, newValue)
            
            % Type check
            try
                % newValue should be a numeric value.
                % NaN, Inf, empty are not accepted
                validateattributes(...
                    newValue, ...
                    {'double'}, ...
                    {'scalar', 'real', 'nonempty'} ...
                    );
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidDoubleInput', ...
                    'Value');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidValue';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            
            % Round the value if needed.
            %
            % A user's value will be rounded according the following rules,
            % in order:
            %
            % - try round(), which rounds to nearest integer
            %
            % - try floor() because maybe the rounded number went up, but
            % the closest integer up was too high and out out of range
            %
            % - try ceil() because maybe the rounded number went down, but
            % the closest integer up was too low and out of range
            %
            % Ex:
            %
            %  [.5, 10], and the user enters .6.  We round to 1.
            %
            %  [.1, 9.9], and the user enters 9.8.  We floor to 9.
            %
            %  [.1, 10], and the user enters .2.  We ceil to 1.
            %
            % See g1173623
            if(strcmp(obj.PrivateRoundFractionalValues, 'on'))
                
                rounded = round(newValue);
                bottom = floor(newValue);
                top = ceil(newValue);
                
                % Try rounded, then bottom, then top
                if (obj.isValueWithinLimits(rounded))
                    roundedValue = rounded;
                elseif (obj.isValueWithinLimits(bottom))
                    roundedValue = bottom;
                elseif (obj.isValueWithinLimits(top))
                    roundedValue = top;
                else
                    % There was no valid integer within the range
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
                
                % success finding something to round
                newValue = roundedValue;
            end
            
            % Check whether the value is within the limits
            if (~obj.isValueWithinLimits(newValue))
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
            
            % Update View
            markPropertiesDirty(obj, {'Value'});
        end
        
        function value = get.Value(obj)
            value = obj.PrivateValue;
        end
        
        
        % ----------------------------------------------------------------------
        
        function set.LowerLimitInclusive(obj, newIncludeLowerLimit)
            
            % Error Checking done through the datatype specification
            
            % Property Setting
            obj.PrivateLowerLimitInclusive = newIncludeLowerLimit;
            
            % Update the properties that are affected by the change in
            % limits/inclusions
            obj.calibrate();
            
            % Update View
            markPropertiesDirty(obj, {'LowerLimitInclusive', 'Value', 'RoundFractionalValues'});
        end
        
        function value = get.LowerLimitInclusive(obj)
            value = obj.PrivateLowerLimitInclusive;
        end
        
        % ----------------------------------------------------------------------
        
        function set.Limits(obj, newValue)
            % Error Checking
            rowVectorLimits = matlab.ui.control.internal.model.PropertyHandling.validateLimitsInput(obj, newValue);
            
            % Property Setting
            obj.PrivateLimits = rowVectorLimits;
            
            % Update the properties that are affected by the change in
            % limits/inclusions
            obj.calibrate();
            
            % Update View
            markPropertiesDirty(obj, {'Limits', 'Value', 'RoundFractionalValues'});
        end
        
        function value = get.Limits(obj)
            value = obj.PrivateLimits;
        end
        
        % ----------------------------------------------------------------------
        
        function set.UpperLimitInclusive(obj, newIncludeUpperLimit)
            
            % Error Checking done through the datatype specification
            
            % Property Setting
            obj.PrivateUpperLimitInclusive = newIncludeUpperLimit;
            
            % Update the properties that are affected by the change in
            % limits/inclusions
            obj.calibrate();
            
            % Update View
            markPropertiesDirty(obj, {'UpperLimitInclusive', 'Value', 'RoundFractionalValues'});
        end
        
        function value = get.UpperLimitInclusive(obj)
            value = obj.PrivateUpperLimitInclusive;
        end
        
        % ----------------------------------------------------------------------
        function set.RoundFractionalValues(obj, newRoundFractionalValues)
            % use a try / catch to keep the stack small
            
            try
                obj.doSetRoundFractionalValues(newRoundFractionalValues);
            catch ex
                throwAsCaller(ex);
            end
            
            markPropertiesDirty(obj, {'RoundFractionalValues'});
        end
        
        function value = get.RoundFractionalValues(obj)
            value = obj.PrivateRoundFractionalValues;
        end
        
        % ----------------------------------------------------------------------
        
        function set.ValueChangedFcn(obj, newValue)
            % Property Setting
            obj.PrivateValueChangedFcn = newValue;
            
            obj.markPropertiesDirty({'ValueChangedFcn'});
        end
        
        function value = get.ValueChangedFcn(obj)
            value = obj.PrivateValueChangedFcn;
        end
        
        
        % ----------------------------------------------------------------------
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
                
                messageObj = message('MATLAB:ui:components:invalidDisplayFormat', 'ValueDisplayFormat');
                
                % Use string from object
                messageText = getString(messageObj);
                
                docLinkId = 'MATLAB:ui:components:sprintfDocLink';
                messageText = matlab.ui.control.internal.model.PropertyHandling.createMessageWithDocLink(messageText, docLinkId, 'sprintf');
                
                mnemonicField = 'invalidDisplayFormat';
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, '%s', messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateValueDisplayFormat = newFormatString;
            
            % Update View
            markPropertiesDirty(obj, {'ValueDisplayFormat'});
        end
        
        function value = get.ValueDisplayFormat(obj)
            value = obj.PrivateValueDisplayFormat;
        end
        
    end
    
    % ---------------------------------------------------------------------
    
    methods(Access = 'private')
        
        function valueWithinLimits = isValueWithinLimits(obj,value)
            % Returns whether 'value' is within the limits defined by the
            % Limits UpperLimitInclusive and
            % LowerLimitInclusive properties
            
            valueWithinLimits = true;
            
            % Check validity defined by the lower limit if any
            if (~isempty(obj.PrivateLimits(1)))
                if(strcmp(obj.PrivateLowerLimitInclusive, 'on'))
                    valueWithinLimits = valueWithinLimits & (value >= obj.PrivateLimits(1));
                else
                    valueWithinLimits = valueWithinLimits & (value > obj.PrivateLimits(1));
                end
            end
            
            % Check the validity definied by the upper limit if any
            if (~isempty(obj.PrivateLimits(2)))
                if(strcmp(obj.PrivateUpperLimitInclusive, 'on'))
                    valueWithinLimits = valueWithinLimits & (value <= obj.PrivateLimits(2));
                else
                    valueWithinLimits = valueWithinLimits & (value < obj.PrivateLimits(2));
                end
            end
            
        end
        
        function calibrate(obj)
            % This method is called after the limits and inclusions are
            % changed to update the properties affected by the change
            
            % If RoundFractionalValues was set to true, check that it can
            % still be with the new limits
            obj.calibrateRoundFractionalValues();
            
            % Update the value so it falls in the new limits
            % Note: updating the value should be done after calibrating
            % RoundFractionalValues because the calibration of Value
            % depends on whether RoundFractionalValue is true or false
            obj.calibrateValue();
        end
        
        function calibrateValue(obj)
            % This method is called after the limits and inclusions are
            % changed to update the current value such that it is
            % within the new limits
            %
            % If the old value is below the lower limit (or exceeds the
            % upper limit), set the new value as follows:
            % - snap to the valid integer that is closest to the lower
            % limit (or upper limit) if RoundFractionalValues is set to true
            % - snap to the lower limit (or upper limit) if it is included
            % - otherwise, snap to the lower limit plus a small enough
            % increment (or upper limit minus a small enough increment)
            
            oldValue = obj.PrivateValue;
            
            if (obj.isValueWithinLimits(oldValue))
                % The old value is within the new limits so do nothing
                return;
            end
            
            if (strcmp(obj.RoundFractionalValues, 'on'))
                % The new value has to be an integer
                
                if (oldValue <= obj.PrivateLimits(1))
                    % Find the valid integer closest to the lower limit
                    newValue = obj.findValidIntegerClosestToLowerLimit();
                else
                    % Find the valid integer closest to the upper limit
                    newValue = obj.findValidIntegerClosestToUpperLimit();
                end
                
                obj.PrivateValue = newValue;
                return;
            end
            
            % The new value does not have to be an integer ...
            
            if (oldValue <= obj.PrivateLimits(1))
                % The old value is below the lower limit
                if (strcmp(obj.PrivateLowerLimitInclusive, 'on'))
                    % Lower limit is included so snap to it
                    newValue = obj.PrivateLimits(1);
                else
                    
                    % Avoid infinite loops by checking for large numbers
                    % This applies to inf, realmax and other large numbers
                    if (obj.PrivateLimits(1) + 1 == obj.PrivateLimits(1))
                        
                        if obj.PrivateLimits(1) <= -realmax
                            % Limits are (-inf, -realmax]
                            % Limits are (-inf, -realmax)
                            % Limits are (-inf, #)
                            % Limits are (-inf, #]
                            % Limits are (-realmax, #)
                            % Limits are (-realmax, #]
                            newValue = -realmax;
                        elseif obj.PrivateLimits(1) == realmax && strcmp(obj.PrivateUpperLimitInclusive, 'on')
                            % Limits are (realmax, inf]
                            newValue = Inf;
                        elseif obj.PrivateLimits(1) == realmax && strcmp(obj.PrivateUpperLimitInclusive, 'off')
                            % Limits are (realmax, inf)
                            newValue = obj.PrivateLimits(1);
                        end
                        
                    else
                        
                        lowerLimit = obj.PrivateLimits(1);
                        
                        % Find an increment that we can add to the non-
                        % included lower limit such that the value is
                        % within the limits.
                        % Start the increment at 1 then go to .1, then .01,
                        % etc... until the value is within the limits
                        increment = 1;
                        while(~obj.isValueWithinLimits(lowerLimit + increment))
                            increment = increment/10;
                        end
                        
                        newValue = lowerLimit + increment;
                        
                    end
                end
                
            else
                % The old value is greater the upper limit
                if (strcmp(obj.PrivateUpperLimitInclusive, 'on'))
                    % Upper limit is included so snap to it
                    newValue = obj.PrivateLimits(2);
                else
                    
                    % Avoid infinite loops by checking for large numbers
                    % This applies to inf, realmax and other large numbers
                    if (obj.PrivateLimits(2) - 1 == obj.PrivateLimits(2))
                        
                        if obj.PrivateLimits(2) >= realmax
                            
                            % Limits are (realmax, inf)
                            % Limits are [realmax, inf)
                            % Limits are (#, inf)
                            % Limits are [#, inf)
                            % Limits are (#, realmax)
                            % Limits are [#, realmax)
                            newValue = realmax;
                        elseif obj.PrivateLimits(2) == -realmax && strcmp(obj.PrivateLowerLimitInclusive, 'on')
                            % Limits are [-inf -realmax)
                            newValue = -Inf;
                        elseif obj.PrivateLimits(2) == -realmax && strcmp(obj.PrivateLowerLimitInclusive, 'off')
                            % Limits are (-inf -realmax)
                            newValue = obj.PrivateLimits(2);
                            
                            
                            %                     if ~isfinite(obj.PrivateLimits(1)) && (-realmax - obj.PrivateLimits(2)) == 0
                            %                         % Limits are [-inf, -realmax]
                            %                         newValue = -realmax;
                            
                            %                     else
                            %                         if isfinite(obj.PrivateLimits(2))
                            %                             upperLimit = obj.PrivateLimits(2);
                            %                         else
                            %                             % obj.PrivateLimits(2) is inf
                            %                             upperLimit = realmax;
                            %                         end
                            %
                            %                         if upperLimit == -realmax && strcmp(obj.PrivateLowerLimitInclusive, 'on')
                            %                             % Limits are [-inf -realmax)
                            %                             newValue = -Inf;
                            %                         elseif upperLimit == -realmax && strcmp(obj.PrivateLowerLimitInclusive, 'off')
                            %                             % Limits are (-inf -realmax)
                            %                             newValue = upperLimit;
                        end
                    else
                        
                        upperLimit = obj.PrivateLimits(2);
                        
                        % Find an increment that we can subtract to the non-
                        % included upper limit such that the value is
                        % within the limits.
                        % Start the increment at 1 then go to .1, then .01,
                        % etc... until the value is within the limits
                        increment = 1;
                        while(~obj.isValueWithinLimits(upperLimit - increment))
                            increment = increment/10;
                        end
                        newValue = upperLimit - increment;
                    end
                end
                %                 end
            end
            
            obj.PrivateValue = newValue;
            
        end
        
        function calibrateRoundFractionalValues(obj)
            % This method is called after the limits and inclusions are
            % changed to ensure that RoundFractionalValues can remain true
            % if it was set to true (limits might not contain valid
            % integers anymore)
            
            if (strcmp(obj.PrivateRoundFractionalValues, 'on'))
                if (~obj.doesLimitsContainIntegers())
                    % the limits do not contain any valid integers
                    obj.PrivateRoundFractionalValues = 'off';
                end
            end
        end
        
        function containsIntegers = doesLimitsContainIntegers(obj)
            % Returns whether the limits defined by LowerLimit, UpperLimit
            % and the inclusions contains at least one integer
            
            if (obj.PrivateLimits(1) == -Inf || obj.PrivateLimits(2) == Inf)
                % The range is unbounded at least on one side
                containsIntegers = true;
                return;
            end
            
            % The range is bounded on both sides...
            
            if (~isempty(obj.findValidIntegerClosestToLowerLimit()))
                % An integer was found
                containsIntegers = true;
                return;
            end
            
            % no integer was found within the limits
            containsIntegers = false;
            
        end
        
        function integer = findValidIntegerClosestToLowerLimit(obj)
            % Returns the integer within the limits closest to the lower
            % limit if the lower limit is finite.
            % If there is no such integer, returns empty
            
            if (obj.isValueWithinLimits( ceil(obj.PrivateLimits(1)) ))
                integer = ceil(obj.PrivateLimits(1));
                return;
                
            elseif (ceil(obj.PrivateLimits(1)) == obj.PrivateLimits(1) && ...
                    strcmp(obj.PrivateLowerLimitInclusive, 'off') && ...
                    obj.isValueWithinLimits( obj.PrivateLimits(1)+1 ) )
                % case if lower limit is an integer, and lower limit not
                % included (not covered above because ceil of an integer is
                % itself)
                integer = obj.PrivateLimits(1)+1;
                return;
                
            end
            
            % no such integer was found
            integer = [];
        end
        
        function integer = findValidIntegerClosestToUpperLimit(obj)
            % Returns the integer within the limits closest to the upper
            % limit if the upper limit is finite.
            % If there is no such integer, returns empty
            
            if (obj.isValueWithinLimits( floor(obj.PrivateLimits(2)) ))
                integer = floor(obj.PrivateLimits(2));
                return;
            elseif (floor(obj.PrivateLimits(2)) == obj.PrivateLimits(2) && ...
                    strcmp(obj.PrivateUpperLimitInclusive, 'off') && ...
                    obj.isValueWithinLimits( obj.PrivateLimits(2)-1 ) )
                % case if upper limit is an integer, and upper limit not
                % included (not covered above because floor of an integer is
                % itself)
                integer = obj.PrivateLimits(2)-1;
                return;
            end
            
            % no such integer was found
            integer = [];
        end
        
        
        function setValueToIntegerWithinLimits(obj)
            % This is called in set.RoundFractionalValues
            % Set Value to the closest integer within the limits.
            % In most cases, this means the current value is simply
            % rounded. However, if the rounded value is not within the
            % limits, the current value has to be either rounded up or down
            
            roundedValue = round(obj.PrivateValue);
            
            if (obj.isValueWithinLimits(roundedValue))
                % the rounded value is within the limits
                newValue = roundedValue;
            else
                % the rounded value is outside the limits
                if (roundedValue > obj.PrivateValue)
                    % the rounded value is greater than the original value
                    % so the value was rounded up. since the rounded value
                    % is outside the limits, we need to round down
                    newValue = roundedValue - 1;
                else
                    % the rounded value is less than the original value
                    % so the value was rounded down. since the rounded
                    % value is outside the limits, we need to round up
                    newValue = roundedValue + 1;
                end
            end
            
            obj.PrivateValue = newValue;
            
        end
    end
    
    
    
    methods(Access = 'protected')
        
        function doSetRoundFractionalValues(obj, newRoundFractionalValues)
            
            % Error Checking done through the datatype specification
            
            if (strcmp(newRoundFractionalValues, 'on') && strcmp(obj.PrivateRoundFractionalValues, 'off'))
                % If the user changes RoundFractionalValues from 'off' to 'on',
                % check whether there are any valid integer in the range.
                
                if (~obj.doesLimitsContainIntegers())
                    % no integer in the range
                    messageObj = message('MATLAB:ui:components:noIntegerInRange', ...
                        'RoundFractionalValues', 'on');
                    
                    % MnemonicField is last section of error id
                    mnemonicField = 'noIntegerInRange';
                    
                    % Use string from object
                    messageText = getString(messageObj);
                    
                    % Create and throw exception
                    exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                    throw(exceptionObject);
                    
                end
                
                % Set Value to the closest integer within the limits
                obj.setValueToIntegerWithinLimits();
                
            end
            
            % Property Setting
            obj.PrivateRoundFractionalValues = newRoundFractionalValues;
            
            % Update View
            markPropertiesDirty(obj, {'RoundFractionalValues', 'Value'});
        end
    end
end
