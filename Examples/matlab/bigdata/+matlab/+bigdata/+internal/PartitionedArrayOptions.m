%PartitionedArrayOptions  Simple class for storing global state for 
%   PartitionedArray operations.
%
%   Copyright 2017 The MathWorks, Inc.

classdef PartitionedArrayOptions < matlab.mixin.SetGet
    
    properties
        RequiresRandState (1,1) logical = false;

        % Function to create a RandStream when needed. This must have the
        % form RandStream = fcn(partitionIdx, baseRNGState). Will typically
        % be empty if RequiresRandState is false.
        RandStreamFactory 
        
        % Pass tagged inputs direct to the function handle without
        % unwrapping them. If this is set to true, function handles must
        % handle both of the following types:
        %  * BroadcastArray: An array that has been explicitly broadcasted.
        %  * UnknownEmptyArray: A chunk of height 0 that does not know its
        %  type and/or its small size.
        PassTaggedInputs (1,1) logical = false;
    end
    
    properties (Dependent)
        % Does any option require the setting of global (to the partition) state.
        RequiresGlobalState;
    end
    
    methods
        function obj = PartitionedArrayOptions(varargin)
            if ~isempty(varargin)
                obj.set(varargin{:});
            end
        end

        function value = get.RequiresGlobalState(obj)
            value = obj.RequiresRandState;
        end

        function set.RandStreamFactory(obj, rsf)
            assert( isempty(rsf) || isa(rsf, 'matlab.bigdata.internal.RandStreamFactory') );
            obj.RandStreamFactory = rsf;
        end
    end
end
