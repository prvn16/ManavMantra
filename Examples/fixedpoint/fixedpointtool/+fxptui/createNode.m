function subsys = createNode(blk)
% CREATENODE Creates the FPT tree node based on the class of input object

% Copyright 2013 MathWorks, Inc.

clz = class(blk);
switch clz
    case 'Simulink.BlockDiagram'
        subsys = fxptui.ModelNode(blk);
    case 'Simulink.ModelReference'
        subsys = fxptui.ModelReferenceNode(blk);
    case 'Stateflow.EMChart'
        subsys = fxptui.MATLABFunctionBlockNode(blk);
    case {'Stateflow.Chart', ...
            'Stateflow.LinkChart', ...
            'Stateflow.TruthTableChart', ...
            'Stateflow.ReactiveTestingTableChart', ...
            'Stateflow.StateTransitionTableChart'}
        subsys = fxptui.StateflowChartNode(blk);
    case {'Stateflow.State', ...
            'Stateflow.Box', ...
            'Stateflow.Function', ...
            'Stateflow.EMFunction', ...
            'Stateflow.AtomicBox',...
            'Stateflow.AtomicSubchart',...
            'Stateflow.TruthTable'}
        subsys = fxptui.StateflowObjectNode(blk);
    case 'fxptds.MATLABFunctionIdentifier'
        subsys = fxptui.MATLABFunctionNode(blk);
    otherwise
        subsys = fxptui.SubsystemNode(blk);
end
if(isempty(subsys))
    return;
end
