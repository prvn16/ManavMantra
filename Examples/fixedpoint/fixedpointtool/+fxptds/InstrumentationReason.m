% Copyright 2014 The MathWorks, Inc.

classdef InstrumentationReason
    % Reasons for log defined in LocationLogging.cpp
    
    properties (Constant)
        REASON_UNKNOWN   = 0; 
        REASON_ARGIN     = 1; 
        REASON_ASSIGN    = 2; 
        REASON_CALL      = 3; 
        REASON_MULTICALL = 4; 
        REASON_ADD       = 5; 
        REASON_SUBTRACT  = 6; 
        REASON_MULTIPLY  = 7; 
        REASON_DIVIDE    = 8; 
        REASON_FORINDEX  = 9;
        REASON_CPPSYSOBJ = 10; 
    end
end
