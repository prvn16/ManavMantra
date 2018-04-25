classdef (Abstract) WidgetBehavior_ShowIcon < handle
    % Mixin class inherited by ListItem and ListItemWithPopup.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public, Hidden)
        % Property "ShowIcon": 
        %
        %   Whether or not showing icon.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       item = matlab.ui.internal.toolstrip.ListItem('MATLAB',matlab.ui.internal.toolstrip.Icon.MATLAB_16,'this is a MATLAB icon')
        %       item.ShowIcon = false;
        ShowIcon
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        ShowIconPrivate = true;
    end
    
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.ShowIcon(this)
            % GET function
            value = this.ShowIconPrivate;
        end
        function set.ShowIcon(this, value)
            % SET function
            if ~islogical(value)
                error(message('MATLAB:toolstrip:control:invalidShowIcon'))
            end
            this.ShowIconPrivate = value;
            this.setPeerProperty('showIcon',value);
        end
    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_ShowIcon(this)
            mcos = {'ShowIconPrivate'};
            peer = {'showIcon'};
        end
        
    end
    
end

