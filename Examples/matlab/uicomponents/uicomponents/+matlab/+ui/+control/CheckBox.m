classdef (ConstructOnLoad=true) CheckBox < ...
        matlab.ui.control.internal.model.AbstractBinaryComponent & ...
        matlab.ui.control.internal.model.mixin.MultilineTextComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
    %
    
    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.
    
    
    
    methods
        % -----------------------------------------------------------------
        % Constructor
        % -----------------------------------------------------------------
        function obj = CheckBox(varargin)
            %
            
            % Do not remove above white space
            % Defaults
            defaultSize = [84 22];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            
            % Override the default values
            defaultText =  getString(message('MATLAB:ui:defaults:checkboxText'));
            obj.Text = defaultText;
            
            obj.Type = 'uicheckbox';
            
            parsePVPairs(obj, varargin{:});
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
                'Text',...
                ...Callbacks
                'ValueChangedFcn'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = obj.Text;
        
        end
    end
    
    
end
