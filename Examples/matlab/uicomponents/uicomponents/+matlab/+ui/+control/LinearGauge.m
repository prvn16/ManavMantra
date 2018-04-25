classdef (ConstructOnLoad=true) LinearGauge < ...
        matlab.ui.control.internal.model.AbstractGaugeComponent & ...        
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    properties(Dependent)
        Orientation = 'horizontal';
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
        PrivateOrientation = 'horizontal';
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = LinearGauge(varargin)

            scaleLineLength = 90;
            obj = obj@matlab.ui.control.internal.model.AbstractGaugeComponent(scaleLineLength);
            
            obj.Type = 'uilineargauge';
            
            % Initialize Layout Properties
            defaultSize = [120, 40];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) =  defaultSize;
            parsePVPairs(obj,  varargin{:});
           
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Orientation(obj, orientation)
            oldOrientation = obj.Orientation;
            
            % Error Checking
            try
                newOrientation = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    obj, ...
                    orientation, ...
                    {'horizontal', 'vertical'});
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidTwoStringEnum', ...
                    'Orientation', 'horizontal', 'vertical');
                
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
            
            % Update position related properties 
            obj.updatePositionPropertiesAfterOrientationChange(...
                oldOrientation, newOrientation);
            
            % Push to view values that are certain
            % Do not push estimated OuterPosition to the view
            markPropertiesDirty(obj, {	...
                'Orientation', ...
                'AspectRatioLimits',...
                'InnerPosition', ...
                });
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

