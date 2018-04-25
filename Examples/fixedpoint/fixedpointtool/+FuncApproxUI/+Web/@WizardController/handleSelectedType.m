function handleSelectedType(this, selectedType)
    % HANDLESELECTEDTYPE handles the type selection and publishing of the
    % block information
    
    % Copyright 2017 The MathWorks, Inc.
    
    this.DataManager.setSelectedType(selectedType);
    try
        data.path = this.DataManager.getCurrentBlockPath();
        if ~(this.DataManager.validateBlockPath(data.path))
            data.path = '';
        end
        this.publishBlockInfo(data, false);
    catch e
        FuncApproxUI.Utils.showDialog('CLIError', e);
    end    
end

% LocalWords:  CLI
