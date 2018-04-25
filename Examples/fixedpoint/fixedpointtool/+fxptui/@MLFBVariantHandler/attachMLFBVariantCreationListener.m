function attachMLFBVariantCreationListener(this, sudObj)
% ATTACHMLFBVARIANTCREATIONLISTENER Attach a listener on the model containing the SUD to update the tree when
% a MLFB variant is created when applying data types to the model.

% Copyright 2016 The MathWorks, Inc.

this.MLFBVariantCreationListener = handle.listener(sudObj, 'ObjectChildAdded', @(src,eventData) captureVariantSubsystems(this, eventData));
if ~isa(sudObj,'Simulink.BlockDiagram')
    this.MLFBVariantCreationListener(end+1) = handle.listener(sudObj.getParent, 'ObjectChildAdded', @(src,eventData) captureVariantSubsystems(this, eventData));
end
subsystemsUnderSud = find(sudObj,'-isa','Simulink.SubSystem');
for i = 1:numel(subsystemsUnderSud)
    this.MLFBVariantCreationListener(end+1) = handle.listener(subsystemsUnderSud(i), 'ObjectChildAdded', @(src,eventData) captureVariantSubsystems(this, eventData));
end
