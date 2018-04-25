classdef (Abstract) WidgetBehavior_Title < handle
    % Mixin class inherited by Tab and Section.
    
    % Author(s): Rong Chen
    % Copyright 2013 The MathWorks, Inc.
    
    properties (Dependent, Access = public)
        % Property "Title": 
        %
        %   The title of a tab, a section or a popup list header
        %   It is a string and the default value is ''.
        %   It is writable.
        %
        %   Example:
        %       section1 = matlab.ui.internal.toolstrip.Section('FOO')
        %       section1.Title % returns 'FOO'
        %       section1.Title = 'BAR' % change section title to BAR
        Title
    end
    
    properties (Access = {?matlab.ui.internal.toolstrip.base.Component})
        TitlePrivate = ''
    end
    
    methods (Abstract, Access = protected)
        
        setPeerProperty(this)
        
    end
    
    %% ----------------------------------------------------------------------------
    % Public methods
    methods
        
        %% Public API: Get/Set
        function value = get.Title(this)
            % GET function
            value = this.TitlePrivate;
        end
        
        function set.Title(this, value)
            % SET function
            value = matlab.ui.internal.toolstrip.base.Utility.hString2Char(value);
            if ~ischar(value)
                error(message('MATLAB:toolstrip:container:invalidTitle'))
            end
            this.TitlePrivate = value;
            this.setPeerProperty('title',value);
        end

    end
    
    methods (Access = protected)
        
        function [mcos, peer] = getWidgetPropertyNames_Title(this)
            mcos = {'TitlePrivate'};
            peer = {'title'};
        end
        
    end
    
end

