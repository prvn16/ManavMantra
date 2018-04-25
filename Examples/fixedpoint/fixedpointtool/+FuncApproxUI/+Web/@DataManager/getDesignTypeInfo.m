function designTypeInfo = getDesignTypeInfo(this)
    % GETDESIGNTYPEINFO creates a new problem and packages the design type
    % information to be sent to the client
    
    % Copyright 2017 The MathWorks, Inc.
    
    % Verify if the block is still active
    this.validateBlock();    
    options = FunctionApproximation.Options('AllowUpdateDiagram', this.AllowUpdateDiagram);
    this.Problem = FunctionApproximation.Problem(this.BlockPath, 'Options', options);
    designTypeInfo = this.packageDesignTypeInfo();
    this.DesignTypeInfo = designTypeInfo;
end

