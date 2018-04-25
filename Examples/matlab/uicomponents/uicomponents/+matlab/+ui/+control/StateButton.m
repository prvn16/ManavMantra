classdef (ConstructOnLoad=true) StateButton < ...
        matlab.ui.control.internal.model.AbstractBinaryComponent & ...
        matlab.ui.control.internal.model.mixin.ButtonComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
    %
    
    % Do not remove above white space
    % Copyright 2014-2016 The MathWorks, Inc.
       
    
    
    methods        
        % -----------------------------------------------------------------
        % Constructor
        % -----------------------------------------------------------------
        function obj = StateButton(varargin)
            %
            
            % Do not remove above white space
            % Defaults
            defaultSize = [100, 22];
			obj.PrivateInnerPosition(3:4) = defaultSize;
			obj.PrivateOuterPosition(3:4) = defaultSize;
			obj.Type = 'uistatebutton';
			
            % Override the default values 
            obj.HorizontalAlignment = 'center';
            defaultText =  getString(message('MATLAB:ui:defaults:statebuttonText'));
            obj.Text = defaultText;
            
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
            
            names = {'Text',...
                'Icon',...
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
    
    methods(Access='public', Static=true, Hidden=true)
      function varargout = doloadobj( hObj) 
          % DOLOADOBJ - Graphics framework feature for loading graphics
          % objects
          

          hObj = doloadobj@matlab.ui.control.internal.model.mixin.IconableComponent(hObj);
          varargout{1} = hObj;
      end
   end
    
end
