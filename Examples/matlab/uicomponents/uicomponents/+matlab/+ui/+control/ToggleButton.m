classdef (ConstructOnLoad=true) ToggleButton < ...
        matlab.ui.control.internal.model.AbstractMutualExclusiveComponent & ...
        matlab.ui.control.internal.model.mixin.ButtonComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
    %
    
    % Do not remove above white space
    % Copyright 2014-2016 The MathWorks, Inc.


    methods
                
        function obj = ToggleButton(varargin)
            %
            
            % Do not remove above white space
            % Defaults 
            defaultLocation = [10, 10];
			obj.PrivateInnerPosition(1:2) = defaultLocation;
			obj.PrivateOuterPosition(1:2) = defaultLocation;
            defaultSize = [100, 22];
			obj.PrivateInnerPosition(3:4) = defaultSize;
			obj.PrivateOuterPosition(3:4) = defaultSize;
            obj.Type = 'uitogglebutton';
            
            % Override the default values 
            obj.HorizontalAlignment = 'center';
            defaultText =  getString(message('MATLAB:ui:defaults:togglebuttonText'));
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
            
            names = {'Value', ...
                'Text',...
                'Icon'};
                
        end
        
        function str = getComponentDescriptiveLabel(obj)
            % GETCOMPONENTDESCRIPTIVELABEL - This function returns a
            % string that will represent this component when the component
            % is displayed in a vector of ui components.
            str = obj.Text;
        
        end
    end
    
    methods(Access='public', Static=true, Hidden=true)
      function varargout = doloadobj( hObj) 
          % DOLOADOBJ - Graphics framework feature for loading graphics
          % objects
          

          hObj = doloadobj@matlab.ui.control.internal.model.mixin.IconableComponent(hObj);
          varargout{1} = hObj;
      end
   end
end



