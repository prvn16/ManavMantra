classdef showcaseToolGroup < handle
    % Demonstrate how to build toolstrip hierarchy in the ToolGroup host
    % container and render it with Java Swing widgets.
    %
    % Example:
    %   Run "matlab.ui.internal.desktop.showcaseToolGroup()"

    % Author(s): R. Chen
    % Copyright 2015 The MathWorks, Inc.

    properties (Transient = true)
        ToolGroup
    end

    methods
        
        function this = showcaseToolGroup()    
            % create an app with a built-in toolstrip (widget: DesktopGroup)
            this.ToolGroup = matlab.ui.internal.desktop.ToolGroup('Toolstrip Showcase');
            % listen to close event
            addlistener(this.ToolGroup, 'GroupAction',@(src, event) closeCallback(this, event));
            % create a tab group
            tabgroup = matlab.ui.internal.desktop.showcaseBuildTabGroup('swing');
            % add the tab group to the built-in toolstrip
            this.ToolGroup.addTabGroup(tabgroup);
            % show the app
            this.ToolGroup.open();
            % store java toolgroup so that app will stay in memory
            internal.setJavaCustomData(this.ToolGroup.Peer,this);
        end
        
        function delete(this)
            if ~isempty(this.ToolGroup) && isvalid(this.ToolGroup)
                delete(this.ToolGroup);
            end
        end
        
        function closeCallback(this, event)
            ET = event.EventData.EventType;
            if strcmp(ET, 'CLOSED')
                delete(this);
            end
        end
        
    end
    
end