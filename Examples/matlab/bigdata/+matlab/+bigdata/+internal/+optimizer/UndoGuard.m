%UndoGuard
% RAII class that reverses all optimizer actions in case of error.
%
% If an error occurs during gather, we want to ensure that predecessors to
% the operation that errored are not tied to it's failure.

% Copyright 2016-2017 The MathWorks, Inc.

classdef UndoGuard < handle
    
    properties (SetAccess = private)
        % The original ClosurePromise objects prior to optimization.
        OriginalPromises = matlab.bigdata.internal.lazyeval.ClosurePromise.empty();
        
        % The new ClosurePromise objects post optimization.
        OptimizedPromises = matlab.bigdata.internal.lazyeval.ClosurePromise.empty();
    end
    
    properties (Dependent)
        % A logical scalar that is true if this guard has actions to
        % perform on destruction.
        HasActions;
    end
    
    methods
        function obj = UndoGuard(originalPromises, optimizedPromises)
            % Construct a Cleanup object that will revert the given
            % optimized promises back to the original promises.
            if nargin
                obj.append(originalPromises, optimizedPromises);
            end
        end
        
        function tf = get.HasActions(obj)
            tf = ~isempty(obj.OriginalPromises);
        end
        
        function delete(obj)
            % Perform the revert action if this has not already be
            % disarmed.
            originalPromises = obj.OriginalPromises;
            optimizedPromises = obj.OptimizedPromises;
            for ii = numel(optimizedPromises) : -1 : 1
                if ~optimizedPromises(ii).IsDone
                    swap(originalPromises(ii), optimizedPromises(ii));
                elseif ~optimizedPromises(ii).IsPartitionIndependent
                    % Partition dependent promises hold onto the upstream
                    % operation graph even when done. We need to undo the
                    % optimization on this, even though we are still
                    % marking the promise as done.
                    swap(originalPromises(ii), optimizedPromises(ii));
                    setValue(originalPromises(ii), optimizedPromises(ii).CachedValue);
                end
            end
        end
        
        function disarm(obj)
            % Disarm the cleanup. The optimized promises will no longer be
            % reverted on destruction of this object.
            import matlab.bigdata.internal.lazyeval.ClosurePromise;
            obj.OriginalPromises = ClosurePromise.empty();
            obj.OptimizedPromises = ClosurePromise.empty();
        end
        
        function append(obj, originalPromises, optimizedPromises)
            % Append the given original/optimized promise pairs to the list
            % of things to cleanup. These will be reverted before any
            % promise already in the UndoGuard object.
            assert(numel(originalPromises) == numel(optimizedPromises), ...
                'UndoGuard must be given the same number of optimized as original promises');
            obj.OriginalPromises = [obj.OriginalPromises; originalPromises(:)];
            obj.OptimizedPromises = [obj.OptimizedPromises; optimizedPromises(:)];
        end
        
        function obj = combine(varargin)
            % Combine 2 or more UndoGuard objects. In the combined
            % object, promises will be reverted in reverse order.
            import matlab.bigdata.internal.optimizer.UndoGuard;
            objs = vertcat(varargin{:});
            originalPromises = vertcat(objs.OriginalPromises);
            optimizedPromises = vertcat(objs.OptimizedPromises);
            obj = UndoGuard(originalPromises, optimizedPromises);
            for ii = 1 : numel(varargin)
                disarm(varargin{ii});
            end
        end
    end
end
