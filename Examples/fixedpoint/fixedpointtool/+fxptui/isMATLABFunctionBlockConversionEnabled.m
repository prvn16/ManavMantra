function enabled = isMATLABFunctionBlockConversionEnabled()

%   Copyright 2015 The MathWorks, Inc.

    % Check the feature flag
    enabled = slfeature('FPTMATLABFunctionBlockFloat2Fixed');    
    
    persistent dependencyExists;   
    
    if enabled
        if isempty(dependencyExists)
            % If F2FDriver exists, then float2fixed was installed 
            dependencyExists = ~isempty(which('coder.internal.MLFcnBlock.F2FDriver'));
        end        
        
        enabled = dependencyExists; 
    end
end