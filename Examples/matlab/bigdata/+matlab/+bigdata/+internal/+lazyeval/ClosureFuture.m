%ClosureFuture
% A class that represents the future to a given output of a closure.
%
% This will automatically update if the underlying closure is replaced by
% the another closure or the output.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) ClosureFuture < handle
    
    properties (SetAccess = ?matlab.bigdata.internal.lazyeval.ClosurePromise)
        % A reference to the Promise object corresponding to this future.
        Promise
    end
    
    properties (SetAccess = private, Dependent)
        % A flag that is true if and only if the value this future
        % represents has been calculated and is available locally.
        IsDone
        
        % The actual value this has been calculated and is available
        % locally. Otherwise empty.
        Value

        % Unique Predecessor nodes.
        Predecessors
    end
    
    properties (SetAccess = immutable)
        % A unique ID char vector.
        IdStr
        
        % Unique Successor nodes.
        %
        % This is empty to avoid lifetime of downstream closures being tied
        % to this future or predecessors. It also prevents the optimizers
        % from pulling in unrelated operations to a gather.
        Successors = matlab.bigdata.internal.lazyeval.Closure.empty();
    end
    
    methods (Access = ?matlab.bigdata.internal.lazyeval.ClosurePromise)
        % The main constructor.
        %
        % This should only be called by the ClosurePromise class.
        function obj = ClosureFuture(promise)
            obj.Promise = promise;
            obj.IdStr   = sprintf('future_%s', obj.Promise.Id);
        end
    end
    
    methods
        function pred = get.Predecessors(obj)
            pred = obj.Promise;
        end
        function isDone = get.IsDone(obj)
            isDone = obj.Promise.IsDone;
        end
        
        function value = get.Value(obj)
            if ~obj.Promise.IsDone
                value = [];
            else
                value = obj.Promise.CachedValue;
            end
        end
    end
end
