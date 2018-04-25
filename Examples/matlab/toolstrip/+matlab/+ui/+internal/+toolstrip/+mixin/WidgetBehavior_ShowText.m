classdef (Abstract) WidgetBehavior_ShowText < handle
    % Mixin class inherited by ListItem, ListItemWithCheckBox, ListItemWithPopup.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public, Hidden)
        % Property "ShowText": 
        %
        %   Whether or not showing text.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       item = matlab.ui.internal.toolstrip.ListItem('MATLAB',matlab.ui.internal.toolstrip.Icon.MATLAB_16,'this is a MATLAB icon')
        %       item.ShowText = false;
        ShowText
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        ShowTextPrivate = true;
    end
    
    % ----------------------------------------------------------------------------
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    % Public methods
    methods
        
        %% Public API: Get/Set
        % ShowText
        function value = get.ShowText(this)
            % GET function
            value = this.ShowTextPrivate;
        end
        function set.ShowText(this, value)
            % SET function
            if ~islogical(value)
                error(message('MATLAB:toolstrip:control:invalidShowText'))
            end
            this.ShowTextPrivate = value;
            this.setPeerProperty('showText',value);
        end
    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_ShowText(this)
            mcos = {'ShowTextPrivate'};
            peer = {'showText'};
        end
        
    end
    
end

