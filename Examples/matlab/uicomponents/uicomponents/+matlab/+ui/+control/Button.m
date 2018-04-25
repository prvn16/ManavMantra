classdef  (ConstructOnLoad=true) Button < ...
        matlab.ui.control.internal.model.ComponentModel & ...            
        matlab.ui.control.internal.model.mixin.ButtonComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent & ...        
        matlab.ui.control.internal.model.mixin.PositionableComponent& ...
        matlab.ui.control.internal.model.mixin.EnableableComponent & ...
        matlab.ui.control.internal.model.mixin.VisibleComponent & ...
        matlab.ui.control.internal.model.mixin.Layoutable
    %

    % Do not remove above white space
    % Copyright 2011-2016 The MathWorks, Inc.

    properties(NonCopyable, Dependent)
        
        ButtonPushedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    properties(NonCopyable, Access = 'private')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
                        
        PrivateButtonPushedFcn@matlab.graphics.datatype.Callback = [];
    end
    
    events(NotifyAccess = {?matlab.ui.control.internal.controller.ComponentController})
        ButtonPushed;
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = Button(varargin)
            %
            
            % Do not remove above white space
            % Override the default values
            defaultSize = [100, 22];
            obj.PrivateInnerPosition(3:4) = defaultSize;
            obj.PrivateOuterPosition(3:4) = defaultSize;
            
            obj.HorizontalAlignment = 'center';
            defaultText =  getString(message('MATLAB:ui:defaults:pushbuttonText'));
            obj.Text = defaultText;
            
            obj.Type = 'uibutton';
            
            parsePVPairs(obj,  varargin{:});
            
            obj.attachCallbackToEvent('ButtonPushed', 'PrivateButtonPushedFcn');	             
        end
        
        
        % ----------------------------------------------------------------------
        function set.ButtonPushedFcn(obj, newValue)
            % Property Setting
            obj.PrivateButtonPushedFcn = newValue; 
            
            obj.markPropertiesDirty({'ButtonPushedFcn'});
        end
        
        function value = get.ButtonPushedFcn(obj)
            value = obj.PrivateButtonPushedFcn;
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
                'ButtonPushedFcn'};
                
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


