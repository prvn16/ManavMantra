classdef (ConstructOnLoad=true)NinetyDegreeGauge < ...
        matlab.ui.control.internal.model.AbstractScaleDirectionComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    properties(Dependent)
        Orientation = 'northwest';
    end
    
    properties(Access= {
            ?appdesservices.internal.interfaces.model.AbstractModel, ...
            ?appdesservices.internal.interfaces.model.AbstractModelMixin})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        PrivateOrientation = 'northwest';
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = NinetyDegreeGauge(varargin)
            %

            % Do not remove above white space
            % Ticks related constants
            height = 90;
            scaleLineLength = 75;
            obj = obj@matlab.ui.control.internal.model.AbstractScaleDirectionComponent(scaleLineLength);

            % Initialize Layout Properties
            defaultSize = [height, height];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.AspectRatioLimits = [1 1];
            
            obj.Type = 'uininetydegreegauge';
            
            parsePVPairs(obj,  varargin{:});
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Orientation(obj, orientation)
            % Error Checking
            try
                newOrientation = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    obj, ...
                    orientation, ...
                    {'northwest', 'northeast', 'southwest', 'southeast'});
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidFourStringEnum', ...
                    'Orientation', 'northwest', 'northeast', 'southwest', 'southeast');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidOrientation';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);

            end
            
            % Property Setting
            obj.PrivateOrientation = newOrientation;
            
            obj.markPropertiesDirty({'Orientation'});
        end
        % -----------------------------------------------------------------
        function value = get.Orientation(obj)
            value = obj.PrivateOrientation;
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
            
            names = {...
                'Value',...
                'Limits',...
                'MajorTicks',...
                'MajorTickLabels',...
                'ScaleColors',...
                'ScaleColorLimits',...
                'ScaleDirection',...
                'Orientation'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = num2str(obj.Value);

        end
    end
    
end

