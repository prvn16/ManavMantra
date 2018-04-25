function [isValidDT, evaluatedNumericType] = validateProposedDT(~, newDT)
%% VALIDATEPROPOSEDDT function inputs a dtstring and checks if its valid numeric type or not
% newDT is a char array

% It outputs
% isValidDT - a logical indicating if dtstring represents a valid numeric
% type data type
% evaluatedNumericType - Simulink.NumericType which dtstring resolves to

% NOTE: This class has child-class specific implementations and hence requires
% special definition instead of using Utils API directly

% Copyright 2016 The MathWorks, Inc.

    % Call validateProposedDT of  in fxptds.Utils.
    [isValidDT, evaluatedNumericType] = fxptds.Utils.validateProposedDT(newDT);
end
