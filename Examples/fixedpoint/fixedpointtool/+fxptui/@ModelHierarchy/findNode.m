function node = findNode(this, objProp, value)
% FINDNODE Find the tree node that contains the object specified in slObj.

% Copyright 2017 The MathWorks, Inc.

modelNodes = [this.TopModelNode this.SubModelNode];

% When launching FPT from a SLFunction inside a chart that is deeper than
% 2-level, the incoming value will be a Simulink.SubSystem object of the
% parent Chart whereas the stored tree data is a Stateflow Chart object of
% the parent Chart.
% We need to convert this object this object(value) to a Stateflow Chart
% first before querying for a corresponding fxptui.TreeNodeData stored in
% fxptui.ModelHierarchy
% If we don't convert this object, the findobj call will return empty and
% the SLFunction node will not be selected in the Main Tree view
if fxptds.isSFMaskedSubsystem(value)
    value = fxptds.getSFChartObject(value);
end
    
node = findobj(modelNodes, objProp, value);

end