function pj = adjustGridLineStyles(state, pj) 
% This undocumented helper function is for internal use.
   
% if doing postscript and axes layer is 'top', and alpha is not 1 (opaque) 
% then we want to change the GridLineStyle to ':' so it looks decent in 
% output because postscript doesn't support transparency 

%   Copyright 2014 The MathWorks, Inc.
    
   if ~(pj.temp.isPostscript &&  pj.temp.outputUsesPainters)
       return; % only for truly vectorized postscript formats 
   end
   if strcmp(state, 'save')
       % save state, if needed  
       gridAx = findall(pj.Handles{1}, ...
           {'Type', 'axes', '-or', 'Type','polaraxes'}, ...
           'Visible', 'on', 'Layer', 'top', ...
           'GridLineStyleMode', 'auto', '-not', 'GridAlpha', 1);
       if ~isempty(gridAx)
           pj.temp.gridData.ax = gridAx;
           pj.temp.gridData.linestyle     = get(gridAx, 'GridLineStyle');
           pj.temp.gridData.linestyleMode = get(gridAx, 'GridLineStyleMode');
           % make sure to have cell arrays to make it easier to restore later
           if ~iscell(pj.temp.gridData.linestyle)
               pj.temp.gridData.linestyle = {pj.temp.gridData.linestyle};
               pj.temp.gridData.linestyleMode = {pj.temp.gridData.linestyleMode};
           end
           set(gridAx, 'GridLineStyle', ':');
           pj.temp.test.adjustGridLineStyles = 'set';
       end
   else
       % restore previously saved values 
       if isfield(pj.temp, 'gridData') && ~isempty(pj.temp.gridData.ax)
          set(pj.temp.gridData.ax, {'GridLineStyle'}, pj.temp.gridData.linestyle);
          set(pj.temp.gridData.ax, {'GridLineStyleMode'}, pj.temp.gridData.linestyleMode);
          pj.temp.test.adjustGridLineStyles = 'restore';
       end
   end

end
