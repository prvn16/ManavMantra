function rangeForProposal = getRangeForProposal(this, proposalSettings)
    % GETRANGEFORPROPOSAL this function returns the final range used for
    % proposal. At construction time, the group holds a mixed range that
    % has the consolidated ranges from all group members. 
    % NOTE: the range consolidation routine should be removed from the
    % AbstractResults' responsibility
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    groupMembers = this.getGroupMembers();
    rangeForProposal = fxptds.Range.empty();
    allRanges = cell(1,numel(groupMembers));
    for gIndex = 1:numel(groupMembers)
       groupMembers{gIndex}.calculateRangesForResult(proposalSettings);
       allRanges{gIndex} = groupMembers{gIndex}.getLocalExtremum();
    end
    
    mergedRange = SimulinkFixedPoint.AutoscalerUtils.unionRange([allRanges{:}], []);
    
    if ~isempty(mergedRange)
        rangeForProposal = fxptds.Range(fxptds.RangeType.Mixed, mergedRange(1), mergedRange(2));
    end
    
end