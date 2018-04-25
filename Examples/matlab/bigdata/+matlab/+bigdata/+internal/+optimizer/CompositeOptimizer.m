%CompositeOptimizer Optimizer that represents the composite of 2 or more optimizers

% Copyright 2017 The MathWorks, Inc.

classdef (Sealed) CompositeOptimizer < matlab.bigdata.internal.Optimizer
    properties (GetAccess = private, SetAccess = immutable)
        % A cell array of Optimizer objects.
        Optimizers;
    end
    methods
        function obj = CompositeOptimizer(varargin)
            obj.Optimizers = varargin;
        end
        
        function undoGuard = optimize(obj, varargin)
            undoGuard = matlab.bigdata.internal.optimizer.UndoGuard();
            for ii = 1 : numel(obj.Optimizers)
                newUndoGuard = obj.Optimizers{ii}.optimize(varargin{:});
                undoGuard = combine(undoGuard, newUndoGuard);
            end
            
            if ~nargout
                disarm(undoGuard);
            end
        end
    end
end
