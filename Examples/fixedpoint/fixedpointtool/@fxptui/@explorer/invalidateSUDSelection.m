function invalidateSUDSelection(h)
% RESETGOALS Resets FPT to a state where the goals have not yet been
% specified. This is invoked when SUDs get invalidated

% Copyright 2015 The MathWorks, Inc

 h.clearSystemForConversion;
 h.updateWorkflowActions;
 h.ConversionNode = [];
 % Default the conversion scope to the top model and throw an error message
 % to the user
 h.isSUDVerified = false;
 h.setSystemForConversion(h.getTopNode.getDAObject.getFullName,'Simulink.BlockDiagram');
 fxptui.showdialog('invalidSUD');