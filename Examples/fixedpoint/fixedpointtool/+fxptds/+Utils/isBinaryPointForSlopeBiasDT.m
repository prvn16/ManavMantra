function flag = isBinaryPointForSlopeBiasDT(result)
    % ISBINARYPOINTFORSLOPEBIASDT this function examines an AbstractResult
    % to see if the proposed data type is binary point while the specified
    % data type was a fixed point data type with slope and bias. If so, the
    % result will get a warning commen. 
    
    % NOTE: moving the logic of this function from the higherarchy
    % of AbstractResult here. See g1498543 for proper solution
    % using CommentGenerator
    flag = false;
    
    if SimulinkFixedPoint.AutoscalerUtils.isProposedDTFixed(result)
        specifiedDTContainer = result.getSpecifiedDTContainerInfo();
        specifiedType = specifiedDTContainer.evaluatedNumericType;
        
        if ~isempty(specifiedType)  && ...
                ( specifiedType.SlopeAdjustmentFactor ~= 1|| ...
                specifiedType.Bias ~= 0)
            flag = true;
        end
    end
end