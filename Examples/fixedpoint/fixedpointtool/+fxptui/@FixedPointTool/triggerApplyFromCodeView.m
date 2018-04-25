function triggerApplyFromCodeView(this)
% TRIGGERAPPLYFROMCODEVIEW Triggers the proposal action from the client
% when requested by codeview. We do this so that the user will be given the
% correct run selection dialog when needed.

% Copyright 2016 The MathWorks, Inc.

this.WorkflowController.triggerApplyForCodeView;

end
