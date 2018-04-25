function setPropValue(this, propName, propVal)
% SETPROPVALUE Sets the value of the property being changed in the UI.

% Copyright 2012-2017 The MathWorks, Inc.

if strcmpi(propName,'Run')
    mdlName = this.getHighestLevelParent;
    appData = SimulinkFixedPoint.getApplicationData(mdlName);
    runObj = this.RunObject;
    if isempty(runObj); return; end
    newRunName = propVal;
    oldRunName = runObj.getRunName;
    % If there is no change in the run name, return without doing anything.
    if strcmp(newRunName, oldRunName); return; end
    if appData.dataset.containsRunWithName(newRunName)
        fxptui.showdialog('nonuniquerunname');
        return;
    end
    
    appData = SimulinkFixedPoint.getApplicationData(mdlName);
    allds{1} = appData.dataset;
    
     
    for idx = 1:numel(allds)
        ds = allds{idx};
        ds.updateForRunNameChange(oldRunName, newRunName);
    end
    
elseif strcmpi(propName,'Accept')
    if ischar(propVal)
        if strcmp(propVal,'0')
            propVal = false;
        else
            propVal = true;
        end
    end
    this.batchSetAccept(propVal);
else
    this.(propName) = propVal;
end