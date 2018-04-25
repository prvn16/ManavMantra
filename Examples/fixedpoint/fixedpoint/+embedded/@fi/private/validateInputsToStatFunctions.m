function validateInputsToStatFunctions(x,fnname)
%VALIDATE_INPUTS_TO_STAT_FUNCTIONS Internal use only: check inputs to mean, median.
%   Validate that the input is (a) not a slope-bias scaled FI, and (b) not a FI-boolean.

%   Copyright 2009-2012 The MathWorks, Inc.
%     


if isslopebiasscaled(numerictype(x))
    error(message('fixed:fi:unsupportedSlopeBias',fnname));
elseif isboolean(x)
    error(message('fixed:fi:unsupportedBooleanMath'));
end  
