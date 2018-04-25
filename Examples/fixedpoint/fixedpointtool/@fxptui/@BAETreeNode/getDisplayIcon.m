function displayIcon = getDisplayIcon(this)
%GETDISPLAYICON Get the displayIcon.
%   OUT = GETDISPLAYICON(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

displayIcon = '';
if isempty(this.TreeNode); return; end
try
    hasTopFlag = this.isdominantsystem('MinMaxOverflowLogging') && ~strcmp('UseLocalSettings', this.MinMaxOverflowLogging);
    hasBotFlag = this.isdominantsystem('DataTypeOverride') && ~strcmp('UseLocalSettings', this.DataTypeOverride);
    switch class(this.TreeNode)
        case'fxptui.sfobjectnode'
            if isa(this.TreeNode.daobject, 'DAStudio.Object')
                displayIcon = this.TreeNode.daobject.getDisplayIcon;
            end
        case 'fxptui.sfchartnode'
            %Get the SF object that this node points to.
            chart = fxptui.sfchartnode.getSFChartObject(this.TreeNode.daobject);
            if ~isempty(chart)
                displayIcon = chart.getDisplayIcon;
                if(hasTopFlag && ~hasBotFlag)
                    displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','chart_flag_top.png');
                end
                if(~hasTopFlag && hasBotFlag)
                    displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','chart_flag_bottom.png');
                end
                if(hasTopFlag && hasBotFlag)
                    displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','chart_flag_both.png');
                end
            end
        case 'fxptui.emlnode'
            if(isa(this.TreeNode.daobject, 'DAStudio.Object'))
                chart = this.TreeNode.daobject.getHierarchicalChildren;
                if(isa(chart, 'DAStudio.Object'))
                    displayIcon = chart.getDisplayIcon;
                    if(hasTopFlag && ~hasBotFlag)
                        displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','eml_flag_top.png');
                    end
                    if(~hasTopFlag && hasBotFlag)
                        displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','eml_flag_bottom.png');
                    end
                    if(hasTopFlag && hasBotFlag)
                        displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','eml_flag_both.png');
                    end
                end
            end
        otherwise %fxptui.subsysnode
            if(isa(this.TreeNode.daobject, 'DAStudio.Object') || isa(this.TreeNode.daobject, 'Simulink.ModelReference'))
                displayIcon = this.TreeNode.daobject.getDisplayIcon;
                if(hasTopFlag && ~hasBotFlag)
                    displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','subsystem_flag_top.png');
                end
                if(~hasTopFlag && hasBotFlag)
                    displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','subsystem_flag_bottom.png');
                end
                if(hasTopFlag && hasBotFlag)
                    displayIcon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','subsystem_flag_both.png');
                end
            end
    end
catch e
end

% [EOF]
