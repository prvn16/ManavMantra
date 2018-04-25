function addTstoolChildrenNodes(ts,tstoolSLNode)

% Copyright 2007-2017 The MathWorks, Inc.

% Utility function used by @ModelDataLogs,@StateflowDataLogs,@SubsysDataLogs,
% @TsArray & @ScopeDataLogs to populate child nodes for tstool.

% Add children nodes (ModelDataLogs may contain SubsysDataLogs, Timeseries, TsArray and other
% children nodes.)
Members = ts.whos;
for k = 1:length(Members)
    try
        thisdataobj = eval(['ts.',Members(k).name]);
    catch
        % If the string Members(k).name is of the form ('** \cr ** )' then
        % the above eval will error out. In this situation try getfield
        % after converting the ModelDataLogs to a struct as a last resort.
        try
            ts_struct = struct(ts);
            thisdataobj = ts_struct.(Members(k).name(3:end-2));
        catch
            error(message('MATLAB:tsguis:addTstoolChildrenNodes:invObj', Members( k ).name));
        end
    end
    childnode = thisdataobj.createTstoolNode(tstoolSLNode);
    if ~isempty(childnode)
        tstoolSLNode.addNode(childnode);
    end
end