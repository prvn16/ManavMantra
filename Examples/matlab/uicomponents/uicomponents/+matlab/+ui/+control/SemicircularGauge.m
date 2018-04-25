classdef (ConstructOnLoad=true) SemicircularGauge < ...
        matlab.ui.control.internal.model.AbstractScaleDirectionComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    properties(Dependent)
        Orientation = 'north';
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
        PrivateOrientation = 'north';
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = SemicircularGauge(varargin)

            scaleLineLength = 101;
            obj = obj@matlab.ui.control.internal.model.AbstractScaleDirectionComponent(...
                scaleLineLength);

            % Initialize Layout Properties
            defaultSize = [120, 65];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.AspectRatioLimits = [120/65, 120/65];
            
            obj.Type = 'uisemicirculargauge';
            
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
                    {'north', 'south', 'east', 'west'});
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidFourStringEnum', ...
                    'Orientation', 'north', 'south', 'east', 'west');
                
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
            
            
            % when orientation changes from south to north, east to west or vice
            % versa, keep the Size and OuterSize as is. otherwise transpose the
            % width and height of both the inner art and the outer art
            % (they are the same for the semicircular gauge).
            % this is because the south and north orientations have the same form factor.
            % Similarly, east and west have the same form factor.
            if(strcmpi(oldOrientation, 'north') && strcmpi(newOrientation, 'south')...
                    || strcmpi(oldOrientation, 'south') && strcmpi(newOrientation, 'north')...
                    || strcmpi(oldOrientation, 'east') && strcmpi(newOrientation, 'west')...
                    || strcmpi(oldOrientation, 'west') && strcmpi(newOrientation, 'east'))
                obj.markPropertiesDirty({'Orientation'});
            else
                % Update position related properties 
                obj.updatePositionPropertiesAfterOrientationChange(...
                    oldOrientation, newOrientation);
            
                % Push to view values that are certain
                % Do not push estimated OuterPosition to the view
                obj.markPropertiesDirty({...
                    'Orientation',...
                    'AspectRatioLimits',...
                    'InnerPosition', ...
                    });
            end
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

