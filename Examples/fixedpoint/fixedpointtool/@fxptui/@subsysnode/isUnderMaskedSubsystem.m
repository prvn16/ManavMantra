function isMasked = isUnderMaskedSubsystem(h)
%Returns true if the node is under a masked subsyetm in the hierarchy

%   Copyright 2012 MathWorks, Inc.


parent = h.daobject;
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
