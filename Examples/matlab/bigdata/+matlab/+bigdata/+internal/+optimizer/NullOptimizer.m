%NullOptimizer Optimizer that doesn't optimize anything

% Copyright 2016-2017 The MathWorks, Inc.

classdef NullOptimizer < matlab.bigdata.internal.Optimizer
    methods
        function undoGuard = optimize(~, varargin)
        % Return an empty guard to indicate no changes were made.
            undoGuard = matlab.bigdata.internal.optimizer.UndoGuard();
        end
    end
end
