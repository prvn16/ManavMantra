classdef (ConstructOnLoad=true) Label < ...
        matlab.ui.control.internal.model.ComponentModel & ...                
        matlab.ui.control.internal.model.mixin.HorizontallyAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.VerticallyAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.MultilineTextComponent & ...        
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...
        matlab.ui.control.internal.model.mixin.PositionableComponent& ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    properties
        % BackgroundColor has its own validation and limited logic in the 
        % public setter.  There will be no PrivateBackgroundColor storage
        % In order to cut down on the number of Private properties
        % BackgroundColor for label is special cased because it allows
        % 'none' as a valid value. 
        BackgroundColor@matlab.graphics.datatype.RGBAColor = 'none';
        
    end
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = Label(varargin)
            %
            
            % Do not remove above white space
            % Defaults
            defaultSize = [31, 22];
			obj.PrivateInnerPosition(3:4) = defaultSize;
			obj.PrivateOuterPosition(3:4) = defaultSize;
			obj.Type = 'uilabel';
            
            % Override the default values                        
            defaultText =  getString(message('MATLAB:ui:defaults:labelText')); 
            obj.Text = defaultText;
                        
            parsePVPairs(obj,  varargin{:});
        end
             
    end        
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
            
        function set.BackgroundColor(obj, newColor)
            
            % Update Model
            obj.BackgroundColor = newColor;
            
            % Update View
            markPropertiesDirty(obj, {'BackgroundColor'});
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
            
            names = {'Text'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = obj.Text;
        
        end
    end
end
