function HighlightMLResult(selection)
% HIGHLIGHTMLRESULT highlights the MATLAB variable in codeview if avilable
% or highlights in desktop MATLAB editor. 

% Copyright 2016 The MathWorks, Inc.

if fxptui.isMATLABFunctionBlockConversionEnabled() && coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled('table')
    coder.internal.mlfb.gui.fxptToolShowResultInCodeView;
else
    fxptds.AbstractActions.selectAndInvoke('hiliteInEditor', selection);
end