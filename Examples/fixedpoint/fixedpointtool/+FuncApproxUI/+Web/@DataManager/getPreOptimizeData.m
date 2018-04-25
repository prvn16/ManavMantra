function preOptimizeData = getPreOptimizeData(this)
    % PACKAGEPREOPTIMIZATIONDATA packages the optimization parameters and
    % the pre-optimization memory information to be sent to the client
    
    % Copyright 2017 The MathWorks, Inc.
    
    this.createOptimizationTable();
    preOptimizeData = this.createPreOptimizeStruct();
    options = this.Problem.Options;
    
    preOptimizeData.AbsTolerance = num2str(options.AbsTol);
    preOptimizeData.RelTolerance = num2str(options.RelTol);
    preOptimizeData.WordLengths = FuncApproxUI.Utils.vecToStr(options.WordLengths, 5);
    
    preOptimizeData.LUTInfo = this.getOriginalMemData();
end

