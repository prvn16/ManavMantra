function [containerType, allContainerTypes] = getContainerType(result)
%% GETCONTAINERTYPE function returns a valid SimulinkFixedPoint.DTContainerInfo
% which contains evaluated numeric type information for compiled types,
% along will all the other container types.

%   Copyright 2016-2017 The MathWorks, Inc.

    % Construct proposed type
    proposedDT = result.getProposedDT; 
    proposedDTContainerType = SimulinkFixedPoint.DTContainerInfo(proposedDT, []);
    
    specifiedDT = result.getSpecifiedDT;
    specifiedDTContainerType = SimulinkFixedPoint.DTContainerInfo(specifiedDT, []);
        
    compiledDT = result.getCompiledDT;
    compiledDTContainerType = SimulinkFixedPoint.DTContainerInfo(compiledDT, []);
    
    if isempty(proposedDTContainerType) || isempty(proposedDTContainerType.evaluatedNumericType) 
        % If specified type is empty, query for compiled type
        if isempty(specifiedDTContainerType) || isempty(specifiedDTContainerType.evaluatedNumericType) 
            containerType = compiledDTContainerType;
        else
            containerType = specifiedDTContainerType;
        end
    else
        containerType = proposedDTContainerType;
    end

    allContainerTypes = struct('ProposedDT', proposedDTContainerType, ...
                            'SpecifiedDT', specifiedDTContainerType, ...
                            'CompiledDT', compiledDTContainerType);
end