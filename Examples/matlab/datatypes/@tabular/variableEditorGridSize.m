function varargout = variableEditorGridSize(a)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Undocumented method used by the Variable Editor to determine the number 
% of rows and columns needed to display the table data. The table
% is assumed to have 2 dimensions.

%   Copyright 2011-2016 The MathWorks, Inc.

import matlab.internal.datatypes.istabular

varWidths = cellfun(@(x) size(x,2)*ismatrix(x)*~ischar(x)*~isa(x,'dataset')*~istabular(x)...
    +ischar(x)+isa(x,'dataset')+istabular(x),a.data);
if (isempty(a))  
    gridSize = [0 0];
    if size(a,2)  > 0  || ~all(varWidths > 0)   
       gridSize = [-1 -1];         
    end
        
elseif all(varWidths>0)
    if isdatetime(a.rowDim.labels) || isduration(a.rowDim.labels)
        % Include rownames which are datetimes or duration along with the
        % data, so the grid size needs to include this.
        gridSize = [size(a,1) sum(varWidths)+1];
    else
        gridSize = [size(a,1) sum(varWidths)];
    end
else % The Variable Editor should not use a 2d grid to display ND arrays
    gridSize = [size(a,1) 0];
end
if nargout==2
    varargout{1} = gridSize(1);
    varargout{2} = gridSize(2);
elseif nargout==1
    varargout{1} = gridSize;
end
   

   

