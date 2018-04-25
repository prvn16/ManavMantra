function validateBlock(this)
    % VALIDATEBLOCK validates the selected block and throws an 
    % exception when the block is closed/commented/made unsupported 
    
    % Copyright 2017 The MathWorks, Inc.
    
    % First check if the block is still valid. If valid, check if it is
    % commented. 
    if ~(this.validateBlockPath(this.BlockPath))
        msgID = 'FuncApproxUI:designType:invalidBlockStatus';
        msg = FuncApproxUI.Utils.lookuptableMessage('invalidBlockStatus');
        baseException = MException(msgID, msg);
        throw(baseException);
    end
end

% LocalWords:  Func
