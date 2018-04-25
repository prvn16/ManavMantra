classdef (Abstract) WidgetBehavior_TextOverride < handle
    % Mixin class inherited by Button, DropDownButton, SplitButton,
    % ToggleButton, ListItem, ListItemWIthPopup, GalleryItem
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    % ----------------------------------------------------------------------------
    properties (Dependent, Access = public, Hidden)
        % Property "TextOverride": 
        %
        %   TextOverride takes a string.  If specified, the string will
        %   override what is available in the Text property.  Unlike the
        %   Text property, the string sepcified here cannot be shared.  The
        %   default value is ''.  It is writable.
        %
        %   Example:
        %       btn1 = matlab.ui.internal.toolstrip.Button;
        %       btn1.Text = 'foo';
        %       btn2 = matlab.ui.internal.toolstrip.Button;
        %       btn1.shareWith(btn2);
        %       btn2.TextOverride = 'bar';
        TextOverride
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        TextOverridePrivate = ''
    end
    
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.TextOverride(this)
            % GET function
            value = this.TextOverridePrivate;
        end
        
        function set.TextOverride(this, value)
            % SET function
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if isempty(value)
                value = '';
            elseif ~ischar(value)
                error(message('MATLAB:toolstrip:control:invalidTextOverride'))
            end
            this.TextOverridePrivate = value;
            this.setPeerProperty('textOverride',value);
        end
        
    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_TextOverride(this)
            mcos = {'TextOverridePrivate'};
            peer = {'textOverride'};
        end
        
    end
    
end
