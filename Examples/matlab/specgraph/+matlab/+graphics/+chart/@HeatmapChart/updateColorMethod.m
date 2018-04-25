function updateColorMethod(hObj)
% Update the automatically generated ColorMethod on the Heatmap.

% Copyright 2016 The MathWorks, Inc.

% Get the table variable names.
xName = hObj.XVariableName;
yName = hObj.YVariableName;
cName = hObj.ColorVariableName;

% Select the color method based on the selection of table variables.
if strcmp(hObj.ColorMethodMode, 'auto')
    % Only update the color method automatically if the ColorMethodMode is
    % auto.
    oldMethod = hObj.ColorMethod_I;
    if width(hObj.SourceTable)==0 || isempty(xName) || isempty(yName)
        % If the source table is empty, then set the method to none.
        newMethod = 'none';
    elseif isempty(cName)
        % If the color variable is empty, set the method to count.
        newMethod = 'count';
    else
        % Otherwise, use the default method, which is mean.
        newMethod = 'mean';
    end
    
    % Mark the data dirty so it gets recalculated.
    if ~strcmp(oldMethod, newMethod)
        hObj.DataDirty = true;
    end
    
    % Update the stored color method
    hObj.ColorMethod_I = newMethod;
end

end
