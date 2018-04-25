function removeSubsystemIDFromMap(this, id)
% REMOVESUBSYSTEMIDFROMMAP Remove the uniqueID object associated with the
% id from the map. This is called from the fxptui.ModelHierarchy class when
% the model/FPT is closed. 

% Copyright 2017 The MathWorks, Inc

if this.SubsystemIDMap.isKey(id)
    this.SubsystemIDMap.remove(id);
end

end