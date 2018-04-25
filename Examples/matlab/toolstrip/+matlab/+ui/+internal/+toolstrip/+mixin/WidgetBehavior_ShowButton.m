classdef (Abstract) WidgetBehavior_ShowButton < handle
    % Mixin class inherited by Slider
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public, Hidden)
        % Property "ShowButton": 
        %
        %   Whether or not showing the arrow buttons of a slider.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       slider = matlab.ui.internal.toolstrip.Slider()
        %       slider.ShowButton = false;
        ShowButton
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        ShowButtonPrivate = true;
    end
    
    % ----------------------------------------------------------------------------
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    % Public methods
    methods
        
        %% Public API: Get/Set
        % ShowText
        function value = get.ShowButton(this)
            % GET function
            value = this.ShowButtonPrivate;
        end
        function set.ShowButton(this, value)
            % SET function
            if ~islogical(value)
                error(message('MATLAB:toolstrip:control:invalidShowButton'))
            end
            this.ShowButtonPrivate = value;
            this.setPeerProperty('showButton',value);
        end
    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_ShowButton(this)
            mcos = {'ShowButtonPrivate'};
            peer = {'showButton'};
        end
        
    end
    
end

