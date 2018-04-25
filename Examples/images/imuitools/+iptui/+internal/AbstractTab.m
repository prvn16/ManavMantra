% ABSTRACTTAB  Ancestor of all tabs available in Color Thresholder
%
%    This class is simply a part of the tool-strip infrastructure.

% Copyright 2014-2017 The MathWorks, Inc.

classdef AbstractTab < handle
    
    properties(Access = private)
        Parent
        ToolTab
    end
    
    %----------------------------------------------------------------------
    methods
        % Constructor
        function this = AbstractTab(tool,tabname,title)
            this.Parent = tool;
            this.ToolTab = matlab.ui.internal.toolstrip.Tab(title);
            this.ToolTab.Tag = tabname;
        end
        % getToolTab
        function tooltab = getToolTab(this)
            tooltab = this.ToolTab;
        end
    end
    
    %----------------------------------------------------------------------
    methods (Access = protected)
        % getParent
        function parent = getParent(this)
            parent = this.Parent;
        end
    end
    
    methods(Static)
        %--------------------------------------------------------------------------
        function section = createSection(nameId, tag)
            section = matlab.ui.internal.toolstrip.Section(getString(message(nameId)));
            section.Tag = tag;
        end
    end
    
end
