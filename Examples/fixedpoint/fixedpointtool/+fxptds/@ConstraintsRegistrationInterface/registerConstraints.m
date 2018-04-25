function registerConstraints(~, dataTypeGroup, result)
    % REGISTERCONSTRAINTS This function is processing the group member (AbstractResult) and
    % adds any constraints found in the member to the group it belongs to.
    % The function uses the public API of the DataTypeGroup class of
    % addConstraints that assumes the responsibility of accessing the
    % internal infrastrucutre to finalize the consolidation of the incoming
    % constraints.
	
    %   Copyright 2016 The MathWorks, Inc.
    
    resultConstraints = result.getConstraints();
    if ~isempty(resultConstraints)
        % currently results hold a cell array of constraints but at each
        % time only a single constraint is registered
        dataTypeGroup.addConstraints(resultConstraints{1});
    end
end