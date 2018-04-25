function [isMasked, parent] = isUnderMaskedSubsystem(daObject)
% ISUNDERMASKEDSUBSYSTEM Returns true if the simulink object is under a
% masked subsystem and also optionally returns the masked subsystem

% Copyright 2015 The MathWorks, Inc

parent = daObject;
isMasked = parent.isMasked;
if ~isMasked
    while ~isa(parent,'Simulink.BlockDiagram')
        if fxptds.isStateflowChartObject(parent)
            parent = parent.up;
        else
            obj = parent.getParent;
            if isempty(obj)
                pName = get_param(parent.getFullName,'Parent');
                parent = get_param(pName,'Object');
            else
                parent = obj;
            end
        end
        if parent.isMasked
            isMasked = true;
            return;
        end
    end
end