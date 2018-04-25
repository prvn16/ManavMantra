%FunctionHandle
% A class that represents a function handle that exposes information about
% the function handle to the Lazy Evaluation Framework.

% Copyright 2015-2017 The MathWorks, Inc.

classdef (Sealed, InferiorClasses = { ?matlab.bigdata.internal.BroadcastArray }) ...
        FunctionHandle < handle & matlab.mixin.Copyable
    properties (SetAccess = immutable)
        % Whether this function handle is known not to be able to error.
        %
        % The Lazy Evaluation Framework will store extra information
        % necessary to give a nice error message.
        ErrorFree = false;
        
        % The maximum number of slices this function handle should be passed
        % in any one call.
        MaxNumSlices = Inf;
        
        % The underlying function handle (or object supporting "feval").
        Handle;
        
        % Whether to capture the ErrorStack to be added to errors generated
        % from deferred evaluation.
        CaptureErrorStack = true;
        
        % A copy of the function stack trace captured at the point of
        % FunctionHandle construction. This is to allow the right error to
        % be thrown by gather.
        ErrorStack
        
        % A logical flag that specifies if this function handle will access
        % any allowed global state. This includes the global rand stream.
        RequiresGlobalState = false;
    end
    
    methods
        % The main constructor.
        %  functionHandle must be either a MATLAB function handle or a
        %   serializable and copyable custom class obeying the feval
        %   contract.
        %  name-value pairs are equivalent to setting the properties of this
        %  class.
        function obj = FunctionHandle(functionHandle,varargin)
            import matlab.bigdata.BigDataException;
            obj.Handle = functionHandle;
            
            p = inputParser;
            p.addParameter('ErrorFree', false, ...
                @(x)isscalar(x) && islogical(x))
            p.addParameter('CaptureErrorStack', true, @(x)isscalar(x) && islogical(x));
            p.addParameter('ErrorStack', []);
            p.addParameter('MaxNumSlices', Inf, ...
                @(x)isscalar(x) && isnumeric(x) && (isinf(x) || mod(x,1) == 0));
            p.addParameter('NumIgnoredStackFrames', 0, ...
                @(x)isscalar(x) && isnumeric(x) && (isinf(x) || mod(x,1) == 0));
            p.addParameter('RequiresGlobalState', false, ...
                @(x)isscalar(x) && islogical(x));
            p.parse(varargin{:});
            inputs = p.Results;
            
            obj.CaptureErrorStack = inputs.CaptureErrorStack;
            obj.ErrorFree = inputs.ErrorFree;
            obj.MaxNumSlices = inputs.MaxNumSlices;
            obj.RequiresGlobalState = inputs.RequiresGlobalState;
            
            if isempty(inputs.ErrorStack)
                if inputs.CaptureErrorStack
                    % We must ensure FunctionHandle constructor is not put on
                    % the submission stack.
                    frame = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>
                    inputs.ErrorStack = BigDataException.getClientStack();
                else
                    inputs.ErrorStack = cell2struct(cell(3, 0), {'file', 'name', 'line'});
                end
            end
            obj.ErrorStack = inputs.ErrorStack;
        end
        
        % This will call feval on the held function handle, passing varargin
        % as input.
        function varargout = feval(obj, varargin)
            try
                [varargout{1:max(1, nargout)}] = feval(obj.Handle, varargin{:});
            catch err
                throwAsFunction(obj, err);
            end
        end
        
        % Copy the FunctionHandle object but replacing the underlying
        % underlying handle with the given function handle.
        function newObj = copyWithNewHandle(obj, fh)
            import matlab.bigdata.internal.FunctionHandle;
            newObj = FunctionHandle(fh, ...
                'ErrorFree', obj.ErrorFree, ...
                'CaptureErrorStack', obj.CaptureErrorStack, ...
                'ErrorStack', obj.ErrorStack, ...
                'MaxNumSlices', obj.MaxNumSlices, ...
                'RequiresGlobalState', obj.RequiresGlobalState);
        end
        
        % Helper function that throws the provided error as if it were
        % thrown from the function handle.
        function throwAsFunction(obj, err)
            if ~isa(err, 'matlab.bigdata.BigDataException')
                err = matlab.bigdata.BigDataException.build(err);
            end
            if obj.CaptureErrorStack
                err = attachSubmissionStack(err, obj.ErrorStack);
            end
            updateAndRethrow(err);
        end
    end
    
    methods (Access = protected)
        function b = copyElement(obj)
            if isa(obj.Handle, 'function_handle')
                b = copyElement@matlab.mixin.Copyable(obj);
            else
                b = matlab.bigdata.internal.FunctionHandle(copy(obj.Handle), ...
                    'ErrorFree', obj.ErrorFree, ...
                    'CaptureErrorStack', obj.CaptureErrorStack, ...
                    'ErrorStack', obj.ErrorStack, ...
                    'MaxNumSlices', obj.MaxNumSlices);
            end
        end
    end
end
