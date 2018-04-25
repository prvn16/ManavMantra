classdef (Hidden) AbstractScaleDirectionComponent < matlab.ui.control.internal.model.AbstractGaugeComponent
    % This undocumented class may be removed in a future release.
    
    % This is the parent class for all gauge components which define a
    % ScaleDirection.
    %
    % In addition to normal gauge propeties, it defines a Scale Direction
    % property.
    
    % Copyright 2011 The MathWorks, Inc.
    
    properties(Dependent)
        ScaleDirection = 'clockwise'
    end
    
    properties(Access = 'protected')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, beacuse sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        PrivateScaleDirection = 'clockwise'
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = AbstractScaleDirectionComponent(varargin)  
						
            obj = obj@matlab.ui.control.internal.model.AbstractGaugeComponent(varargin{:});
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function obj = set.ScaleDirection(obj, scaleDirection)
            % Error Checking
            try
                newScaleDirection = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    obj, ...
                    scaleDirection,...
                    {'clockwise', 'counterclockwise'});
            catch %#ok<CTCH>
                messageObj = message('MATLAB:ui:components:invalidTwoStringEnum', ...
                    'ScaleDirection', 'clockwise', 'counterclockwise');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidScaleDirection';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);

            end
            
            % Property Setting
            obj.PrivateScaleDirection = newScaleDirection;
            
            obj.markPropertiesDirty({'ScaleDirection'});
        end
        
        function scaleDirection = get.ScaleDirection(obj)
            scaleDirection = obj.PrivateScaleDirection;
        end
        
    end
    
end

