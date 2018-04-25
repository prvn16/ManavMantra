function HighlightBlock
% HIGHLIGHTBLOCK highlights blocks connected to the Selected Result in the model
%  Copyright 2016 The MathWorks, Inc.

fpt = fxptui.FixedPointTool.getExistingInstance;

if ~isempty(fpt)
    selection = fpt.getSelectedResult;
    
    if isempty(selection)
        fxptui.showdialog('generalnoselection');
        return;
    end
    
    % If the result is a MATLABExpression or a derived result, then
    % highlight it in the codeview instead.
    if isa(selection, 'fxptds.MATLABExpressionResult')
        fxptui.Web.Callbacks.HighlightMLResult(selection);
    else
        fxptds.AbstractActions.selectAndInvoke('hiliteInEditor', selection);
    end
end

end

