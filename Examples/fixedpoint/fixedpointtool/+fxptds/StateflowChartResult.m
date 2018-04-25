classdef StateflowChartResult < fxptds.AbstractSimulinkResult
% STATEFLOWCHARTRESULT Class definition for a result representing stateflow charts

% Copyright 2013-2016 The MathWorks, Inc.

    methods 
        function this = StateflowChartResult(data)
            if nargin == 0
                argList = {};
            else
                argList{1} = data;
            end
            this@fxptds.AbstractSimulinkResult(argList{:});
        end
        
        function icon = getDisplayIcon(this)
            icon = '';
            if ~this.isResultValid; return; end
            slObj = this.getUniqueIdentifier.getObject;
            chartObject = fxptds.getSFChartObject(slObj);
            icon = chartObject.getDisplayIcon;
            if(this.isPlottable)
                % Default to Chart icon for all Stateflow Chart like objects
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources','Chart.png');
                idx = strfind(icon,filesep);
                filename = strrep(icon(idx(end)+1:end),'.png', ['Logged' this.Alert '.png']);
                icon = fullfile('toolbox','fixedpoint','fixedpointtool','resources',filename);
            end
        end
    end
    
    methods(Hidden)
        function ovMode = getOverflowMode(this)
            ovMode = 'wrap';
            slObj = this.getUniqueIdentifier.getObject;
            chartObject = fxptds.getSFChartObject(slObj);
            if ~isempty(chartObject)
                if chartObject.SaturateOnIntegerOverflow
                    ovMode = 'saturate';
                end
            end
        end
        % computeIfInheritanceReplaceable API verifies if a result is a
        % candidate for fixed point proposal on having an inheritance
        % rule as specified type. 
        % For StateflowChart result, this API always sets IsInheritanceReplaceable
        % property to false
        function computeIfInheritanceReplaceable(~)
            this.IsInheritanceReplaceable  = false;
        end
    end
end
