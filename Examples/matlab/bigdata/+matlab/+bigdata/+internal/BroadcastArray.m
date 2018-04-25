%BroadcastArray
% A class that represents an array that will be explicitly broadcasted.
%
% This should not be used directly, please see matlab.bigdata.internal.broadcast.
%

%   Copyright 2016-2017 The MathWorks, Inc.

classdef (Sealed) BroadcastArray < matlab.bigdata.internal.TaggedArray
    properties (SetAccess = immutable)
        % The underlying array. This is either the array itself, or an
        % instance of PartitionedArray representing the array.
        Value;
    end
    
    methods
        % The main constructor to be used by matlab.bigdata.internal.broadcast.
        function obj = BroadcastArray(value)
            if istall(value)
                obj.Value = hGetValueImpl(value);
            elseif isa(value, 'matlab.bigdata.internal.LocalArray')
                obj.Value = value.Value;
            else
                obj.Value = value;
            end
        end
    end
    
    % Overrides of TaggedArray interface.
    methods
        function value = getUnderlying(obj)
            % Get the array underlying this BroadcastArray.
            value = obj.Value;
        end
    end
end
