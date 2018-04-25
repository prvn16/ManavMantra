classdef (Abstract) WidgetBehavior_DescriptionOverride < handle
    % Mixin class inherited by Button, DropDownButton, SplitButton,
    % ToggleButton, ListItem, ListItemWIthPopup, GalleryItem
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public, Hidden)
        % Property "DescriptionOverride": 
        %
        %   DescriptionOverride takes a string.  If specified, the string will
        %   override what is available in the Description property.  Unlike the
        %   Description property, the string sepcified here cannot be shared.  The
        %   default value is ''.  It is writable.
        %
        %   Example:
        %       btn1 = matlab.ui.internal.toolstrip.Button();
        %       btn1.Description = 'foo';
        %       btn2 = matlab.ui.internal.toolstrip.Button();
        %       btn1.shareWith(btn2);
        %       btn2.DescriptionOverride = 'bar';
        DescriptionOverride
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        DescriptionOverridePrivate = ''
    end
    
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.DescriptionOverride(this)
            % GET function
            value = this.DescriptionOverridePrivate;
        end
        
        function set.DescriptionOverride(this, value)
            % SET function
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if isempty(value)
                value = '';
            elseif ~ischar(value)
                error(message('MATLAB:toolstrip:control:invalidDescriptionOverride'))
            end
            this.DescriptionOverridePrivate = value;
            this.setPeerProperty('descriptionOverride',value);
        end
        
    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_DescriptionOverride(this)
            mcos = {'DescriptionOverridePrivate'};
            peer = {'descriptionOverride'};
        end
        
    end
    
end

