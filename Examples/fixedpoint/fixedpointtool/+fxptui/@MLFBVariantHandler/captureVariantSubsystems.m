function captureVariantSubsystems(this, eventData)
% CAPTUREVARIANTSUBSYSTEMS Update the tree when a MLFB variant is created on the model dring the
% data type apply phase.

% Copyright 2016 The MathWorks, Inc.

if isa(eventData.Child, 'Simulink.SubSystem')
    if ~isempty(this.VariantSubsystems)
        this.VariantSubsystems(end+1) = eventData.Child;
    else
        this.VariantSubsystems = eventData.Child;
    end
end