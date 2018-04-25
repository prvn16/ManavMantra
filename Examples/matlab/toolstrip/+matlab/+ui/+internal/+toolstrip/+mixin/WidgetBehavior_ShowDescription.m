classdef (Abstract) WidgetBehavior_ShowDescription < handle
    % Mixin class inherited by ListItem, ListItemWithCheckBox, ListItemWithPopup.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public)
        % Property "ShowDescription": 
        %
        %   Whether or not showing description.
        %   It is a logical and the default value is true.
        %   It is writable.
        %
        %   Example:
        %       item = matlab.ui.internal.toolstrip.ListItem('MATLAB',matlab.ui.internal.toolstrip.Icon.MATLAB_16,'this is a MATLAB icon')
        %       item.ShowDescription = false;
        ShowDescription
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        ShowDescriptionPrivate = true;
    end
    
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        % ShowDescription
        function value = get.ShowDescription(this)
            % GET function
            value = this.ShowDescriptionPrivate;
        end
        function set.ShowDescription(this, value)
            % SET function
            if ~islogical(value)
                error(message('MATLAB:toolstrip:control:invalidShowDescription'))
            end
            this.ShowDescriptionPrivate = value;
            this.setPeerProperty('showDescription',value);
        end
    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_ShowDescription(this)
            mcos = {'ShowDescriptionPrivate'};
            peer = {'showDescription'};
        end
        
    end
    
end

