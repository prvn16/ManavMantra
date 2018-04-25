function chartObj = getSFChartObject(sfObj)
% GETSFCHARTOBJECT Gets the actual chart object that is masked by a subsystem

%    Copyright 2012-2014 The MathWorks, Inc.


% getHierarchicalChildren on a Subsystem containing a chart may have more
% than 1 child. Use the find method instead to get thte SF chart object that the
% object points to. Restrict the find to Chart types because other stateflow
% objects might have the same name returning more than one object.

chartObj = find(sfObj,'-depth',1,'Name',sfObj.Name,'-isa',...
    'Stateflow.Chart','-or','-isa','Stateflow.EMChart','-or','-isa',...
    'Stateflow.TruthTableChart','-or','-isa','Stateflow.StateTransitionTableChart',...
    '-or', '-isa', 'Stateflow.ReactiveTestingTableChart');

% To avoid finding multiple objects, we try to satisfy the first condition 
% & then try to find the linkchart if it was previously not found
if isempty(chartObj)
   chartObj = find(sfObj,'-depth',1,'Name',sfObj.Name,'-isa','Stateflow.LinkChart'); %#ok<*GTARG>
end
if isempty(chartObj)
    chartObj = sfObj;
end
