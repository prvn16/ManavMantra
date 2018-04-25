function data = updateOptimize(this, options)
    % UPDATEOPTIMIZE updates the problem options, solves the optimization 
    % problem and sends the memory information of the optimized LUT
    % 'Solution' property
    
    % Copyright 2017 The MathWorks, Inc.
    
    % update problem options
    this.updateOptions(options);
    % Solve the optimization problem
    this.Solution = this.Problem.solve;
    % Package and publish the memory information to the client
    data = this.getOptimizedMemData();    
end

