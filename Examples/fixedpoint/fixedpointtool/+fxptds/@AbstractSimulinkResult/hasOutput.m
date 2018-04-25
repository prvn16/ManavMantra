function [b, numOutputs] = hasOutput(this)
% HASOUTPUT returns true if the block has outputs and optionally returns the number of output ports.

%   Copyright 2013-2017 The MathWorks, Inc.

b = false;
numOutputs = [];
blkObj = this.UniqueIdentifier.getObject;
portHandles = blkObj.PortHandles;
outportHandles = portHandles.Outport;
if ~isempty(outportHandles) 
    b = true;
    numOutputs = numel(outportHandles);
end

% [EOF]
