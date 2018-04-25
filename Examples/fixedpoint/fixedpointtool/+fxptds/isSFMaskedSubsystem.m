function isMasked = isSFMaskedSubsystem(subsysObj)
% ISSFMASKEDSUBSYSTEM returns true if the subsystem is masking a stateflow chart.

% Copyright 2012 MathWorks, Inc

isMasked = isa(subsysObj, 'Simulink.Block') && slprivate('is_stateflow_based_block', subsysObj.Handle);
