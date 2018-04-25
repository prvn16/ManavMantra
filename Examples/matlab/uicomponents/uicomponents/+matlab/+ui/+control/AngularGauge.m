classdef AngularGauge < ...
        matlab.ui.control.internal.model.AbstractScaleDirectionComponent     
    %

    % Do not remove above white space
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties(Dependent)
        StartAngle = 0;
        
        EndAngle = 135;
    end
    
    properties(Access = 'protected')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        PrivateStartAngle = 0;
        
        PrivateEndAngle = 135;
    end
    
    methods
        function obj = AngularGauge(varargin)
            %

            % Do not remove above white space
            % Initialize Position Properties
            defaultSize = [34, 34];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.AspectRatioLimits = [1,1];

            parsePVPairs(obj,  varargin{:});
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.StartAngle(obj, startAngle)
            % Error Checking
            try
                normalizedStartAngle = matlab.ui.control.AngularGauge.validateAngle(startAngle);
            catch %#ok<*CTCH>
                messageObj =  message('MATLAB:ui:components:invalidStartAngle', 'StartAngle');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidStartAngle';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateStartAngle = normalizedStartAngle;
            
            % Update the view
            markPropertiesDirty(obj, {'StartAngle'});
        end
        
        function value = get.StartAngle(obj)
            value = obj.PrivateStartAngle;
        end
        
        function set.EndAngle(obj, endAngle)
            % Error Checking
            try
                normalizedEndAngle = matlab.ui.control.AngularGauge.validateAngle(endAngle);
            catch
                messageObj =  message('MATLAB:ui:components:invalidEndAngle', 'EndAngle');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidEndAngle';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateEndAngle = normalizedEndAngle;
            
            % Update the view
            markPropertiesDirty(obj, {'EndAngle'});
        end
        % -----------------------------------------------------------------
        function value = get.EndAngle(obj)
            value = obj.PrivateEndAngle;
        end
    end
    
    % ---------------------------------------------------------------------
    % Private Validation Functions
    % ---------------------------------------------------------------------
    methods(Access = 'private', Static)
        function normalizedAngle = validateAngle(angle)
            % Validates that ANGLE is a valid angle, as well as returns a
            % normalized angle.
            
            % make sure it is a number
            validateattributes(angle, ...
                {'numeric'}, ...
                {'scalar', 'finite'});
            
            % convert to double representation
            angle = double(angle);
            
            if(angle == -360)
                % -360 is a special case
                %
                % -360 is equivalent to 0
                normalizedAngle = 0;
                return;
            elseif(angle < 0)
                % anything negative
                normalizedAngle = -360 + mod(angle, 360);
                return;
            else
                % any positive numbers are normalized through a regular
                % mod()
                normalizedAngle = mod(angle, 360);
                return;
            end
        end
    end
    
end

