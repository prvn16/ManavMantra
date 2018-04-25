%SlicewiseFusableOperation
% An abstract base class that represents an operation that can be fused
% slicewise.

% Copyright 2017 The MathWorks, Inc.

classdef (Abstract) SlicewiseFusableOperation < matlab.bigdata.internal.lazyeval.Operation
    methods
        function obj = SlicewiseFusableOperation(varargin)
            % Initialize the SlicewiseFusableOperation immutable state.
            
            obj = obj@matlab.bigdata.internal.lazyeval.Operation(varargin{:});
        end
    end
    
    methods
        function tf = isSlicewiseFusable(obj)
            % Check if this operation can be fused with other slicewise
            % fusable objects.
            tf = (isempty(obj.Options) || ~obj.Options.RequiresGlobalState);
            
            if tf
                fh = obj.getCheckedFunctionHandle();
                tf = tf && isinf(fh.MaxNumSlices);
            end
        end
    end
    
    methods (Abstract)
        % Get the function handle that represents this object.
        %
        % This is public in order to make it accessible to SlicewiseFusingOptimizer.
        fh = getCheckedFunctionHandle(obj);
    end
end
