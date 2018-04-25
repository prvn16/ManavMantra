function handleOptimize(this, options)
    % HANDLEOPTIMIZE performs the optimization using the user provided
    % parameters and send the memory report for the optimized block
    
    % Copyright 2017 The MathWorks, Inc.
    
    try
        data = this.DataManager.updateOptimize(options);
        this.publish(this.OptimizedLutInfoPublishChannel, data);
    catch e
        FuncApproxUI.Utils.showDialog('invalidOptimParams', e);
    end
end

