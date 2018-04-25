%LocalArray
% A wrapper around a local non-partitioned array that can be accepted by
% the PartitionedArray interface.
%
% This should be used when passing the data directly to PartitionedArray is
% not possible due to dispatching rules. Specifically, this is needed if
% the local array is a MCOS class type and it appears to the left of all
% PartitionedArray instances in a call to any of the <..>fun methods.
%

%   Copyright 2015 The MathWorks, Inc.

classdef (Sealed, InferiorClasses = { ?matlab.bigdata.internal.FunctionHandle }) ...
        LocalArray < handle
    
    properties (SetAccess = immutable)
        % The underlying array.
        Value;
    end
    
    methods
        % The main constructor.
        function obj = LocalArray(value)
            obj.Value = value;
        end
    end
end
