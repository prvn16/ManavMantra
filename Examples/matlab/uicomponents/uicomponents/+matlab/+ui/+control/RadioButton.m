classdef (ConstructOnLoad=true) RadioButton < ...
        matlab.ui.control.internal.model.AbstractMutualExclusiveComponent & ...
        matlab.ui.control.internal.model.mixin.MultilineTextComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
    %
    
    % Do not remove above white space
    % Copyright 2013-2016 The MathWorks, Inc.


    methods
                
        function obj = RadioButton(varargin)
            %
            
            % Do not remove above white space
            % Defaults 
            defaultLocation = [10, 10];
			obj.PrivateInnerPosition(1:2) = defaultLocation;
			obj.PrivateOuterPosition(1:2) = defaultLocation;
            defaultSize = [91, 22];
			obj.PrivateInnerPosition(3:4) = defaultSize;
			obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.Type = 'uiradiobutton';
            
            % Override the default values
            defaultText =  getString(message('MATLAB:ui:defaults:radiobuttonText'));
            obj.Text = defaultText;
 
            parsePVPairs(obj,  varargin{:});
                        
                        
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
                'Text'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = obj.Text;
        
        end
    end
    
end



