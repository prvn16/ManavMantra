%ClosurePromise
% A class that represents the promise end of a ClosureFuture.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed) ClosurePromise < handle
    
    properties (SetAccess = immutable)
        % A unique ID.
        Id
        
        % A unique ID char vector.
        IdStr
    end
    
    properties (SetAccess = private)
        % A flag that is true if and only if the value this promise
        % represents has been calculated.
        IsDone (1,1) logical = false;
        
        % Logical flag that specifies if CachedValue is independent of the
        % partitioning of the input. If false, CachedValue becomes
        % transient, it will not be saved to disk. This is to protect
        % against Value becoming incorrect if a tall array is saved and
        % loaded into a different environment.
        IsPartitionIndependent (1,1) logical = true;
    end
    
    properties (SetAccess = private, Dependent)
        % Unique Predecessor nodes.
        Predecessors
        
        % Unique Successor nodes.
        Successors
    end
    
    properties (SetAccess = private)
        % The underlying closure that will fulfill this promise.
        Closure = matlab.bigdata.internal.lazyeval.Closure.empty();
        
        % The index into the output of the underlying closure that this
        % promise represents.
        ArgoutIndex = 1;
        
        % A reference to the actual value if it has been calculated.
        CachedValue = [];
        
        % A reference to the Future object corresponding to this promise.
        Future;
    
        % Array metadata
        Metadata = ''
    end
    
    methods 
        function metadata = hGetMetadata(obj)
            metadata = obj.Metadata;
        end
        function hSetMetadata(obj, metadata)
            obj.Metadata = metadata;
        end
    end

    properties (Access = private, Constant)
        % The means by which this class receives unique IDs.
        IdFactory = matlab.bigdata.internal.util.UniqueIdFactory('ClosurePromise');
    end
    
    methods
        % The main constructor.
        %
        %  obj = ClosurePromise(closure, argoutIndex) creates a promise
        %   around a closure/argoutIndex combination.
        %
        %  obj = ClosurePromise(value) creates a promise that has already
        %   been fulfilled with the given value.
        function obj = ClosurePromise(closureOrValue, argoutIndex, isPartitionIndependent)
            import matlab.bigdata.internal.lazyeval.ClosureFuture;
            
            obj.Id = obj.IdFactory.nextId();
            obj.IdStr = sprintf('promise_%s', obj.Id);
            obj.Future = ClosureFuture(obj);
            
            if nargin >= 2
                obj.Closure     = closureOrValue;
                obj.ArgoutIndex = argoutIndex;
            else
                obj.CachedValue = closureOrValue;
                obj.IsDone      = true;
            end
            if nargin >= 3
                obj.IsPartitionIndependent = isPartitionIndependent;
            end
        end

        function pred = get.Predecessors(obj)
            import matlab.bigdata.internal.lazyeval.Closure;
            if obj.IsDone
                pred = Closure.empty(); %#ok<PROP>
            else
                pred = obj.Closure;
            end
        end
        
        function succ = get.Successors(obj)
            succ = obj.Future;
        end
        
        % Set the cached value of this promise.
        %
        % This completes the promise and replaces the Closure reference
        % with the actual value.
        function setValue(obj, value)
            import matlab.bigdata.internal.lazyeval.Closure;
            assert(~obj.IsDone, ...
                'Assertion failed: Attempted to complete a ClosurePromise that is already complete.');
            obj.IsDone      = true;
            obj.CachedValue = value;
            if obj.IsPartitionIndependent
                obj.Closure = Closure.empty(); %#ok<PROPLC>
            end
        end
        
        % Set the partition independent flag.
        function setPartitionIndependent(obj, flag)
            import matlab.bigdata.internal.lazyeval.Closure;
            % Algorithm code is not allowed to mark a closure as partition
            % dependent when it is already complete. This is because we've
            % already dropped the closure graph at that point. The reverse
            % though is ok.
            assert(~obj.IsDone || flag, ...
                'Assertion failed: Attempted to remove the partition independent flag on a ClosurePromise that is already complete.');
            obj.IsPartitionIndependent = flag;
            if obj.IsDone && obj.IsPartitionIndependent
                obj.Closure = Closure.empty(); %#ok<PROPLC>
            end
        end
        
        % Swap two ClosurePromise instances.
        %
        % The caller must guarantee these two promises are equivalent, that
        % the two promises will be given the same output when their respective
        % closures are evaluated.
        %
        % This exists to allow optimizers to move output promises from one
        % Closure instance to another. It is a swap instead a pure move
        % because both Closure and ClosurePromise instances are not allowed
        % to be in an invalid state.
        function swap(promise1, promise2)
            [promise1.Future, promise2.Future] = deal(promise2.Future, promise1.Future);
            [promise1.Future.Promise, promise2.Future.Promise] = deal(promise2.Future.Promise, promise1.Future.Promise);
            [promise1.Metadata, promise2.Metadata] = deal(promise2.Metadata, promise1.Metadata);
        end
        
        function obj = saveobj(obj)
            if ~obj.IsPartitionIndependent
                obj.IsDone = false;
                obj.CachedValue = [];
            end
        end
    end
end

