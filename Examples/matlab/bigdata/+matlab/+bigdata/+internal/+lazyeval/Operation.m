%Operation
% An interface that represents an operation.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Abstract) Operation < handle
    properties (SetAccess = immutable)
        % The number of inputs that the operation accepts.
        NumInputs;
        
        % The number of outputs that the operation returns.
        NumOutputs;
        
        % A flag that specifies if this operation supports preview. This is
        % true if and only if this operation can emit a small part of the output
        % based on only a small part of the input. This must be true if
        % DependsOnOnlyHead is true.
        SupportsPreview = false;
        
        % A flag that describes if this operation depends on only a small
        % number of slices that originate at the beginning.
        DependsOnOnlyHead = false;
    end
    
    properties (SetAccess=protected)
        % Does this operation support direct evaluation on gathered
        % arrays.
        SupportsDirectEvaluation = false;
    end
    
    properties (Access=protected)
        % Options for how to run this operation (RNG state etc.)
        Options = [];
    end
    
    methods
        % The main constructor.
        function obj = Operation(numInputs, numOutputs, supportsPreview, dependsOnlyOnHead)
            assert(isnumeric(numInputs) && isscalar(numInputs) && mod(numInputs,1) == 0 && numInputs >= 0, ...
                'Assertion failed: NumInputs must be a positive scalar integer.');
            assert(isnumeric(numOutputs) && isscalar(numOutputs) && mod(numOutputs,1) == 0 && numOutputs >= 0, ...
                'Assertion failed: NumOutputs must be a positive scalar integer.');
            obj.NumInputs = numInputs;
            obj.NumOutputs = numOutputs;
            if nargin >= 3
                assert(islogical(supportsPreview) && isscalar(supportsPreview), ...
                    'Assertion failed: SupportsPreview must be a scalar logical.');
                obj.SupportsPreview = supportsPreview;
            end
            if nargin >= 4
                assert(islogical(dependsOnlyOnHead) && isscalar(dependsOnlyOnHead), ...
                    'Assertion failed: DependsOnlyOnHead must be a scalar logical.');
                if dependsOnlyOnHead
                    assert(supportsPreview, 'The SupportsPreview property cannot be false if DependsOnOnlyHead is true.');
                end
                obj.DependsOnOnlyHead = dependsOnlyOnHead;
            end
        end
        
        function varargout = evaluate(obj, varargin) %#ok<STOUT>
            % Evaluate an operation on in-memory inputs. This can be used
            % to evaluate the operation immediately when all inputs are
            % already gathered.
            %
            % Syntax:
            %   [a,b,c,..] = evaluate(obj,x,y,..) invokes the operation on
            %   input gathered arrays {x,y,..} to produce output gathered
            %   arrays {a,b,c,..}
            %
            
            % We could provide a default implementation in terms of
            % createExecutionTasks and SerialExecutor. The reasons why we
            % don't are:
            %  1. Evaluation via SerialExecutor has too much overhead to
            %     trigger once per operation.
            %  2. Providing a version of SerialExecutor optimized for
            %  single small operations introduces a duplicate of a
            %  complicated piece of our architecture.
            assert(false, ...
                'Assertion failed: %s does not support direct evaluation.', ...
                class(obj));
        end
    end
    
    methods (Abstract)
        % Create a list of ExecutionTask instances that represent this
        % operation when applied to taskDependencies.
        %
        % Inputs:
        %  - taskDependencies: A list of ExecutionTask instances that represent
        %  the direct upstream tasks whos output will be passed into this
        %  operation.
        %  - inputFutureMap: An object that represents a mapping from the
        %  list of dependencies/taskDependencies to the list of operation inputs.
        %  - isInputReplicated: A list of logicals that for each input to the
        %  operation, describes whether that input has been replicated
        %  across all partitions.
        tasks = createExecutionTasks(obj, taskDependencies, inputFutureMap, isInputReplicated)
    end
    
    methods (Access=protected)
        
        function processorFactory = addGlobalState(obj, processorFactory)
            % Helper to add global state to the processor factor if
            % required. Should only be called for operations that have
            % options.
            import matlab.bigdata.internal.lazyeval.GlobalStateProcessorDecorator;
            if ~isempty(obj.Options) && obj.Options.RequiresGlobalState
                processorFactory = GlobalStateProcessorDecorator.wrapFactory(processorFactory, obj.Options);
            end
        end
        
    end
end
