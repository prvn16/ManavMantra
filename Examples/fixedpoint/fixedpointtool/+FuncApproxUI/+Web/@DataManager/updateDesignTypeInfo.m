function designTypeInfo = updateDesignTypeInfo(this, designTypeInfo)
    % UPDATEBLOCKDESIGNTYPEINFO creates a new problem with the provided
    % design type info and persists the design type info generated from it
    
    % Copyright 2017 The MathWorks, Inc.
    
    % Verify if the block is still active and supported
    this.validateBlock();    
    % Create the options and resolve the design type info to create the
    % problem
    options = FunctionApproximation.Options('AllowUpdateDiagram', this.AllowUpdateDiagram);
    outputType = FunctionApproximation.internal.Utils.dataTypeParser(designTypeInfo.OutputType);
    resolvedOutputType = outputType.ResolvedType;
    numInputs = numel(designTypeInfo.InputTypes);
    inputTypes = repmat(fixdt('double'), 1, numInputs);
    for i = 1: numInputs
        inputType = FunctionApproximation.internal.Utils.dataTypeParser(designTypeInfo.InputTypes{i});
        resolvedInputType = inputType.ResolvedType;
        inputTypes(i) = resolvedInputType;
    end
    
    % g1679138 - Lookup Table Optimizer: Min and Max should not be 
    % required for NON-floating-point type
    % Convert all the empty values in the 'InputLowerBounds' to -Inf
    parseVal = @FunctionApproximation.internal.Utils.parseCharValue; 
    emptyIndices = cellfun(@(x) isempty(parseVal(x)), designTypeInfo.InputLowerBounds);
    designTypeInfo.InputLowerBounds(emptyIndices) = {'-Inf'};    
    % Convert all the empty values in the 'InputUpperBounds' to Inf    
    emptyIndices = cellfun(@(x) isempty(parseVal(x)), designTypeInfo.InputUpperBounds);
    designTypeInfo.InputUpperBounds(emptyIndices) = {'Inf'};
    
    % Create a new problem with the updated design type info
    this.Problem = FunctionApproximation.Problem(this.BlockPath,...
        'InputTypes', inputTypes, 'OutputType', resolvedOutputType,...
        'InputLowerBounds', designTypeInfo.InputLowerBounds(:)',...
        'InputUpperBounds', designTypeInfo.InputUpperBounds(:)',...
        'Options', options);
    
    this.Problem = this.Problem.getWellDefinedProblem();
    
    % Package the design type info from the problem to be sent to the
    % client. This is necessary because the provided design type info might
    % change when a new problem is created. This new change has to be
    % communicated to the user. This case arises when user provides the
    % input bounds that exceed the input type. In such cases, the bounds
    % are adjusted to fit the provided input type and this information is
    % communuicated back to the client.
    designTypeInfo = this.packageDesignTypeInfo();
    this.DesignTypeInfo = designTypeInfo;
end

