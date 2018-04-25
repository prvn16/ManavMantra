function [isValidDT, evaluatedNumericType] = validateProposedDT(proposedDT)
%% VALIDATEPROPOSEDDT function validates proposedDT string and checks if its a valid input for fixed point tool
%
%  proposedDT  is a string or a numeric type (fixdt / numerictype)

%   Copyright 2016-2017 The MathWorks, Inc.

    proposedDTStr = proposedDT;

    % If input is a embedded.numerictype or Simulink.NumericType, convert
    % the input to string
    if isnumerictype(proposedDT) || isa(proposedDT, 'Simulink.NumericType')
        proposedDTStr = proposedDT.tostring;
    end

    % construct dtContainerInfo and validate if evaluated numeric type is
    % float or fixed
    dtContainerInfo = SimulinkFixedPoint.DTContainerInfo(proposedDTStr, []);
    isValidDT = ( dtContainerInfo.isFixed ...
        && ~fixed.isSignedOneBit(dtContainerInfo.evaluatedNumericType) ...
        && ~SimulinkFixedPoint.AutoscalerUtils.exceedsMaximumWL(dtContainerInfo.evaluatedNumericType)) ...
        || dtContainerInfo.isFloat;

    % return evaluated numeric type
    evaluatedNumericType = dtContainerInfo.evaluatedNumericType;
end
