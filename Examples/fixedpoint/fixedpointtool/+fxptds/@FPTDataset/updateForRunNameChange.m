function updateForRunNameChange(this, oldRunName, newRunName)
% UPDATEFORRUNNAMECHANGE Updates the internal maps when the run name is changed from the UI.

%  Copyright 2012-2017 The MathWorks, Inc.

    
    % Order of executing these commands is very important for workflow to
    % not break
    % 1. At Dataset Level, RunNameObjMap is changed first (which keeps a map
    % of RunName->RunObjects
    % 1.1 This triggers each run to change its name and also notify
    % FPTGUIScopingEngine of a run name change
    % 2. At Dataset, the RunName to TsID Map is also changed which keeps
    % track of Runs to SDI IDs
    % g1497576
    if this.RunNameObjMap.isKey(oldRunName)
        runObj = this.RunNameObjMap.getDataByKey(oldRunName);
        updateRunName(runObj, newRunName);
        this.RunNameObjMap.deleteDataByKey(oldRunName);
        this.RunNameObjMap.insert(newRunName,runObj);
        this.LastModifiedRun = newRunName;
    end
    
    if this.RunNameTsIDMap.isKey(oldRunName)
        tsID =  this.RunNameTsIDMap.getDataByKey(oldRunName);
        this.RunNameTsIDMap.deleteDataByKey(oldRunName);
        this.RunNameTsIDMap.insert(newRunName,tsID);
    end
    
    sdiEngine = Simulink.sdi.Instance.engine();
    if this.RunNameTsIDMap.isKey(newRunName)
        tsID =  this.RunNameTsIDMap.getDataByKey(newRunName);
        if sdiEngine.isValidRunID(tsID)
            sdiEngine.setRunName(tsID, newRunName);
        end
    end
    
    indices = ismember(this.EmbeddedRunNames, oldRunName);
    
    if any(indices)
       this.EmbeddedRunNames{indices} = newRunName; 
    end
        
end


