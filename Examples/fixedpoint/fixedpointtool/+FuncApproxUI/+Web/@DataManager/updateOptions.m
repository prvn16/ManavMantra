function updateOptions(this, data)
    % UPDATEOPTIONS updates the optimization problem options
    
    % Copyright 2017 The MathWorks, Inc.
    
    this.Problem.Options.AllowUpdateDiagram = this.AllowUpdateDiagram;
    this.Problem.Options.AbsTol = FunctionApproximation.internal.Utils.parseCharValue(data.AbsTol);
    this.Problem.Options.RelTol = FunctionApproximation.internal.Utils.parseCharValue(data.RelTol);
    this.Problem.Options.WordLengths = FunctionApproximation.internal.Utils.parseCharValue(data.WordLengths);
    this.Problem.Options.Display = true;
end

