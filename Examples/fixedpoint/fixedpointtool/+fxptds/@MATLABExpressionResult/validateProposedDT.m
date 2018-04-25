function [isValidDT, evaluatedNumericType] = validateProposedDT(~, newDT)
%% VALIDATEPROPOSEDDT function inputs a dtstring and checks if its valid numeric type or not
% newDT is a char array

% It outputs
% isValidDT - a logical indicating if dtstring represents a valid numeric
% type data type
% evaluatedNumericType - embedded.numericType which dtstring resolves to

% NOTE: This function is a child-specific implementation of
% validatePropsoedDT 

% Copyright 2016 The MathWorks, Inc.

    % Call validateProposedDT of  in fxptds.Utils.
    [isValidDT, evaluatedNumericType] = fxptds.Utils.validateProposedDT(newDT);
    
    % If evaluated numeric type is an Simulink.Numerictype,
    if isValidDT && ~isnumerictype(evaluatedNumericType)
        % convert to embedded.numerictype
        evaluatedNumericType = numerictype(evaluatedNumericType);
    end
end
        