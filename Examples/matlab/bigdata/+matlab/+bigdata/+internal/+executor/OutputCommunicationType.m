%OutputCommunicationType
% An enumeration of the different output communication types supported by
% ExecutionTask.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef OutputCommunicationType
    enumeration
        % Non-communicating output.
        Simple
        
        % Communication from N partitions to 1 partition.
        AllToOne
        
        % Arbitrary communication from N partitions to M partition.
        AnyToAny

        % Communication from 1 partition to N partitions.
        Broadcast
        
        % Communication from each partition to itself. This is used as a
        % placeholder for IsPassBoundary in the implementation of
        % convertToIndependentTasks. It will not be used outside of this.
        SameToSame
    end
end
