function cb_highlightconstrainedblock
%CB_HIGHLIGHTCONSTRAINEDBLOCK highlights selected block with data type constraints in model

%   Copyright 2006-2017 The MathWorks, Inc.

me = fxptui.getexplorer;
if slfeature('FPTWeb')
    fpt = fxptui.FixedPointTool.getExistingInstance;
    if ~isempty(fpt)
        selection = fpt.getSelectedResult;
    end
else
    if isempty(me); return; end
    selection = me.getSelectedListNodes;
end
if(~isempty(selection))
  if ~isempty(selection.getConstraints)
    constraints = selection.getConstraints;
    if numel(constraints) > 0
        for i=1:numel(constraints)
            try
              blkObj = constraints{1}.Object;
              blkObj.hilite;
            catch e  %#ok  %consume the error for hilighting
            end
        end
    end
  end
end
% [EOF]
