function blockPath = getCurrentBlockPath(this)
    % GETCURRENTBLOCKPATH gets the path of the currently selected block of
    % specified type, return empty if no such block is currently selected
    
    % Copyright 2017 The MathWorks, Inc.
    
    blockPath = FunctionApproximation.internal.Utils.getCurrentBlockPath(this.SelectedType);
end

