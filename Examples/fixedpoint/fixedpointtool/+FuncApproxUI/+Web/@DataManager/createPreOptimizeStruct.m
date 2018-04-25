function preOptimizeData = createPreOptimizeStruct(~)
    % CREATEPREOPTIMIZESTRUCT creates an empty struct for the
    % pre-optimization data to be sent to the client
    
    % Copyright 2017 The MathWorks, Inc.
    
    preOptimizeData = struct('AbsTolerance', '', ...
        'RelTolerance', '', 'WordLengths', '',...
        'LUTInfo', '');
end

