classdef (Abstract) WidgetBehavior_IconOverride < handle
    % Mixin class inherited by Button, DropDownButton, SplitButton,
    % ToggleButton, ListItem, ListItemWIthPopup, GalleryItem
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public, Hidden)
        % Property "IconOverride": 
        %
        %   IconOverride takes a matlab.ui.internal.toolstrip.Icon object.
        %   If specified, the icon will override what is available in the
        %   Icon property.  Unlike the Icon property, the icon sepcified
        %   here cannot be shared.  The default value is [].  It is
        %   writable.
        %
        %   Example:
        %       btn1 = matlab.ui.internal.toolstrip.Button()
        %       btn1.Icon = matlab.ui.internal.toolstrip.Icon('foo.jpg')
        %       btn2 = matlab.ui.internal.toolstrip.Button()
        %       btn1.shareWith(btn2);
        %       btn2.IconOverride = matlab.ui.internal.toolstrip.Icon('bar.jpg')
        IconOverride
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        IconOverridePrivate = []
        IconJavaScriptOverride = ''
        IconSwingOverride = ''
    end
    
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.IconOverride(this)
            % GET function
            value = this.IconOverridePrivate;
        end
        
        function set.IconOverride(this, value)
            % SET function
            if isempty(value)
                this.IconOverridePrivate = [];
                this.IconSwingOverride = '';
                this.setPeerProperty('iconPathOverride','');
                this.IconJavaScriptOverride = '';
                this.setPeerProperty('iconOverride','');
            elseif isa(value, 'matlab.ui.internal.toolstrip.Icon')
                this.IconOverridePrivate = value;
                % must set iconPath first
                this.IconSwingOverride = value.getIconFile();
                this.setPeerProperty('iconPathOverride',value.getIconFile());
                % must set icon second (listenered by swing widgets)
                if isCSS(value)
                    % built-in or custom class
                    str = value.getIconClass();
                    this.IconJavaScriptOverride = str;
                    this.setPeerProperty('iconOverride',str);
                else
                    % file or ImageIcon
                    str = value.getBase64URL();
                    this.IconJavaScriptOverride = str;
                    this.setPeerProperty('iconOverride',str);
                end
            else
                error(message('MATLAB:toolstrip:control:invalidIconOverride'))
            end
        end
        
    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_IconOverride(this) %#ok<*MANU>
            mcos = {'IconJavaScriptOverride';'IconSwingOverride'};
            peer = {'iconOverride';'iconPathOverride'};
        end
        
    end
    
end

