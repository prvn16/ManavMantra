classdef MeterState
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods (Abstract)
        B = start(A)
        B = stop(A)
        B = log(A)
    end
    
end