function specialHandlingDT = specialHandlingForResults(~, resultsScope, result, proposedDataType, proposalSettings)
    % SPECIALHANDLINGFORRESULTS Special handling for group members (results). Currently group members
    % are allowed to deviate from the group proposal for data type based on
    % certain business logic conditions. This function encodes the special
    % cases where members would require to deviate.
    % NOTE: This functionality can be abstracted out so that different
    % clients that use a class of data type groups can encode different
    % behaviors and conditions for deviation, i.e. single precision
    % conversion may require different deviation behaviors and different
    % conditions.
    
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    % identify if a member lies outside the system under design
    % NOTE: this call can be fully absorbed in the member class
    % AbstractResult and there will be no need for the second argument that
    % points to the system under design, see g1446605
    isOutsideSUD = ~resultsScope(result.UniqueIdentifier.UniqueKey);
    
    % identify if a result is locked
    isLocked = result.IsLocked;
    
    specialHandlingDT = '';
    
    % if the member lies outside the system under design, we need to
    % invalidate the proposal for data type and override with 'n/a'.
    % Additionally we populate a comment on the result that describes the
    % reason of the 'n/a' proposal
    outOfSUDComment = message('SimulinkFixedPoint:autoscaling:blockOutsideSubSystem').getString;
    if isOutsideSUD  
        specialHandlingDT = 'n/a';
        % add the comment only if it is not present
        if ~any(ismember(result.getComment, outOfSUDComment))
            result.addComment({outOfSUDComment});
        end
    end
    
    % if the member is locked we need to invalidate the proposal for data
    % type and override with 'locked'.
    % NOTE: a member may be both locked and outside the system under
    % design, in which case the member will receive the comment for being
    % outside the system under design but the data type will be overriden
    % to be 'locked' and not 'n/a'
    if isLocked
        specialHandlingDT = message('FixedPointTool:fixedPointTool:Locked').getString;
    end
    
    specifiedDTContainerInfo = result.getSpecifiedDTContainerInfo;
    
    % if the previous cases of locked and outside of system under desing
    % did not warrant any special handling cases, we need to make sure that
    % the proposal coming from the group is valid for this member. This is
    % currently encoded in the result property isInheritanceReplaceable
    % which will help us identify if we can replace inherited data types
    % with valid proposed data types
    if isempty(specialHandlingDT)        
        proposeForRecord = specifiedDTContainerInfo.isFixed || ...
            (proposalSettings.ProposeForFloatingPoint && specifiedDTContainerInfo.isFloat) || ...
            (proposalSettings.ProposeForInherited && specifiedDTContainerInfo.isInherited && result.isInheritanceReplaceable);
        if ~proposeForRecord
            specialHandlingDT = 'n/a';
        end
    end
    
    % update the proposed data type for the result based on internal logic
    % of the Entity Autoscalers for individual results; we try to apply the
    % proposed data type using APIs from Entity Autoscalers, if there are
    % any issues, the Entity Autoscalers will return comments, explaining
    % the reasoning and the proposed data type will be changed to 'n/a'
    if isempty(specialHandlingDT)
        specialHandlingDT = SimulinkFixedPoint.AutoscalerUtils.updateProposalBasedOnComments(result, proposedDataType.tostring, proposalSettings);
    end
    
end