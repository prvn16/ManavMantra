%BigDataException Capture error information from errors thrown in user code inside a Big-Data language construct.
%
%   BigDataException methods:
%      throw         - Issue exception and terminate function
%      rethrow       - Reissue existing exception and terminate function
%      throwAsCaller - Issue exception as if from calling function
%      addCause      - Record additional causes of exception
%      getReport     - Get error message for exception
%      last          - Return last uncaught exception
%
%   BigDataException properties:
%      identifier  - Character string that uniquely identifies the error
%      message     - Formatted error message that is displayed
%      cause       - Cell array of MExceptions that caused the error
%      stack       - Structure containing stack trace information
%
%   See also try, catch, MException

% Copyright 2015-2017 The MathWorks, Inc.

classdef BigDataException < MException & matlab.mixin.CustomDisplay
    % This class is used to build up a reasonable user-visible error for
    % any failure that occurs within the tall array architecture. It will
    % minimize the stack trace while attaching sufficient information for
    % users to understand the cause of an error.
    %
    % A BigDataException error report will have a stack similar to the
    % following:
    %
    % 1. (Optional) Stack frames from the algorithm implementation:
    %
    %   Error using myAlgorithmImplFrame1(..)
    %   The actual error message.
    %   Error in myAlgorithmImplFrame2(..)
    %   ...
    %
    % 2. Stack frames that point to what line of code invoked the algorithm
    % that errored:
    %
    %   ...
    %   Error in tall/myAlgorithm(..)
    %   Error in userFcn1(..)
    %   Error in userFcn2(..)
    %   ...
    %
    % 3. Stack frames that point to what line of code triggered evaluation:
    %
    %   ...
    %   Error in tall/gather(..)
    %   Error in userCode(..)
    %
    % BigDataException is designed to be built up incrementally. Each
    % try/catch guard is allowed to attach more information to the error.
    %
    % In most instances, a user-visible error can be built and thrown by
    % passing a MException or a message object to:
    %
    %   matlab.bigdata.internal.throw(err);
    %
    % When more control is needed, a BigDataException can be built via:
    %
    %   err = matlab.bigdata.BigDataException.build(err);
    %   err = attachSomeInformation(err,information);
    %   updateAndRethrow(err);
    %
    % All try/catch that want to attach more information should use the
    % pattern:
    %
    %   try
    %       doSomething();
    %   catch err
    %       matlab.bigdata.internal.util.assertNotInternal(err);
    %       err = attachSomeInformation(err,information);
    %       updateAndRethrow(err);
    %   end
    %
    % If the try/catch guard did not modify the error, it can simply
    % rethrow:
    %
    %   try
    %       doSomething();
    %   catch err
    %       matlab.bigdata.internal.util.assertNotInternal(err);
    %       rethrow(err);
    %   end
    %
    properties (Access = private)
        % The function stack of the algorithm implementation on the remote
        % side that should be visible to the user. This will be the top of
        % the error stack of the error bubbles out of framework code.
        %
        % This is typically empty unless the error came from custom code
        % running as part of the evaluation. For example, the function
        % handle from arrayfun/cellfun, or a custom datastore:
        %
        %  Error using MyDatastore/myFunction(..)
        %  Could not read from file foo()
        %  Error in MyDatastore/read(..)
        %  data = myFunction(ds);
        %  ...
        %
        RemoteStack = cell2struct(cell(3,0), {'file','name','line'});
        
        % The complete functional stack of execution, including both the
        % framework stack and the algorithm implementation stack. This is
        % kept for debugging purposes and discarded unless showFullStack is
        % enabled.
        RemoteDebugStack = cell2struct(cell(3,0), {'file','name','line'});
        
        % The functional stack of the call that submitted the deferred
        % operation. This will be the middle of the stack of the error that
        % bubbles out of framework code.
        %
        % This contains all stack frames leading up-to invocation of the
        % tall method who's evaluation generated the error. For example:
        %
        %  ...
        %  Error in tall/plus(..)
        %  out = elementfun(@plus, ta, tb);
        %  Error in MyScript (..)
        %  tZ = tX + tY;
        %  ...
        %
        SubmissionStack = cell2struct(cell(3,0), {'file','name','line'});
        
        % The function stack of the code leading up-to triggering
        % evaluation of a tall array. This will become the end of the stack
        % of the error that bubbles out of framework code.
        %
        % This contains all stack frames leading up-to the invocation of
        % tall/gather. For example:
        %
        %  ...
        %  Error in tall/gather(..)
        %  [varargout{1:nargout}] = iGather(varargin{:});
        %  Error in MyScript (..)
        %  z = gather(tZ);
        %
        ClientStack = cell2struct(cell(3,0), {'file','name','line'});
    end
    
    properties (Constant, Access = private)
        % An empty stack struct array.
        EmptyStack = cell2struct(cell(3,0), {'file','name','line'});
        
        % The path to the internal package of tall arrays.
        InternalPath = fullfile('toolbox', 'matlab', 'bigdata', '+matlab', '+bigdata', '+internal');
    end
    
    methods (Static, Hidden)
        % Get the stack of the caller prior to any internal stack frames.
        %
        % Syntax:
        %   stack = BigDataException.getClientStack() returns the stack
        %   trace of the caller, from the base up-to but not including the
        %   first internal frame.
        %
        function stack = getClientStack()
            import matlab.bigdata.internal.InternalStackFrame;
            import matlab.bigdata.BigDataException;
            
            if BigDataException.showFullStack()
                stack = dbstack('-completenames', 1);
                return;
            end
            
            if InternalStackFrame.hasInternalStackFrames()
                stack = InternalStackFrame.userStack();
            else
                stack = dbstack('-completenames', 1);
            end
            
            % Any frame that is in matlab.bigdata.internal is internal. We
            % ignore all such frames and anything that they call. We're
            % only interested in the user-visible caller.
            for ii = numel(stack) : -1 : 1
                filename = stack(ii).file;
                if contains(filename, BigDataException.InternalPath)
                    stack(1 : ii) = [];
                    break;
                end
            end
        end
        
        % Build a BigDataException. This is required to generate any kind
        % of evaluation error of tall array except for internal errors.
        %
        % Syntax:
        %   err = BigDataException.build(err) builds a BigDataException
        %   that will bubble up through the lazy evaluation framework.
        %
        function newErr = build(err)
            import matlab.bigdata.BigDataException;
            if isa(err, 'matlab.bigdata.BigDataException')
                % If err is already a user-visible exception, there is
                % nothing to be done.
                newErr = err;
                return;
            elseif ~isa(err, 'MException')
                % This is to allow message object input arguments.
                err = MException(err);
            end
            newErr = BigDataException(err.identifier, '%s', err.message);
            newErr.RemoteDebugStack = err.stack;
            newErr.ClientStack = BigDataException.getClientStack();
            if ~isempty(err.cause)
                newErr = addCause(newErr, err.cause{1});
            end
        end

        % Build a BigDataException internal error from a caught error.
        %
        % This is used when an unexpected error is thrown within the lazy
        % evaluation framework outside of algorithm or user code. In a bug
        % free world, this will never be hit. When a bug is hit, we want
        % the error to be nice enough that a user isn't presented with a
        % wall of text, but include enough information that we can diagnose
        % the failure.
        %
        % This does three things to the error:
        %  1. Prepend error message with "Internal problem ...".
        %  2. Generate a stack that contains the top 3 stack frames of the
        %     actual error combined with the stack frames of the users code
        %    (typically everything up-to the gather).
        %  3. Attaches the error as a cause.
        %
        function err = buildInternal(err)
            import matlab.bigdata.BigDataException;
            
            % Remote all frames except the first three for readability.
            remoteStack = err.stack;
            remoteStack(4:end) = [];
            % Insert a "..." frame to denote the stack has been truncated.
            remoteStack(end + 1, :) = struct('file', {''}, 'name', {'....'}, 'line', {0});
            
            err = addCause(MException(message('MATLAB:bigdata:array:ExecutionError', err.message)), err);
            err = BigDataException.build(err);
            err.RemoteStack = remoteStack;
            err.RemoteDebugStack = err.stack;
        end
    end
    
    methods (Hidden)
        % Rethrows a BigDataException.
        %
        % This is roughly equivalent to MException/rethrow. The important
        % difference is that BigDataException/updateAndRethrow will update the
        % error to include any new pieces of big data information recently
        % attached to the error.
        %
        % Syntax:
        %   BigDataException.updateAndRethrow(err) rethrows the given exception as
        %   a BigDataException, preserving any and all information that has
        %   been attached to the error.
        %
        function updateAndRethrow(err)
            throwWithMarkerFrame(err);
        end
        
        % Attach a submission functional stack to the error.
        %
        % This is the main way how to attach information about who created
        % the operation that generated the error at evaluation time.
        %
        % Syntax:
        %   err = attachSubmissionStack(err, submissionStack)
        %   Prepends the attached submission stack to the error.
        %
        function err = attachSubmissionStack(err, submissionStack)
            assert(isempty(err.SubmissionStack), ...
                'Assertion failed: Attempted to attach submission stack when one already exists.');
            err.SubmissionStack = [err.EmptyStack; submissionStack];
        end
        
        % Mark the stack frames of the callee as user visible. These frames
        % will be appended to the top of the error message given to the
        % user. All frames below and including the caller will be ignored.
        %
        % If this is not called, the framework will assume all frames are
        % internal.
        %
        % Example:
        %  try
        %      userAction();
        %  catch err
        %      err = BigDataException.build(err);
        %      err = markCalleeFramesAsUserVisible(err);
        %      updateAndRethrow(err);
        %  end
        %
        function err = markCalleeFramesAsUserVisible(err)
            import matlab.bigdata.BigDataException;
            % Ignore all frames except for the callee and above.
            localStack = dbstack('-completenames');
            errStack = err.RemoteDebugStack;
            for ii = 1 : min(numel(errStack), numel(localStack))
                if ~isequal(errStack(end - ii + 1), localStack(end - ii + 1))
                    break;
                end
            end
            errStack(end - ii + 1 : end) = [];
            
            % Any frame that is in matlab.bigdata.internal is internal. We
            % ignore all such frames and anything that lead up-to them,
            % we're only interested in the user-visible callee.
            for ii = 1 : numel(errStack)
                filename = errStack(ii).file;
                if contains(filename, BigDataException.InternalPath)
                    errStack(ii : end) = [];
                    break;
                end
            end
            
            err.RemoteStack = errStack;
        end
        
        % Reset the client stack attached to this error. This will set the
        % the client stack to be the non-internal frames of the caller.
        %
        % This will be used by backend implementations when translating
        % errors back to the client. By default the client stack is
        % captured at throw, which is not correct for parallel backends.
        % This fixes that by making it look as if the error was thrown on
        % the client by the caller.
        %
        % Syntax:
        %   err = rebaseToClient(err)
        %   Re-bases the error to start with the callers stack frames.
        %
        function err = rebaseToClient(err)
            err.ClientStack = err.getClientStack();
        end
        
        % Append the given extra message to the end of the error's message.
        %
        % Syntax:
        %   err = appendToMessage(err, extraMessage) appends
        %   extraMessage onto the end of err/message.
        %
        function newErr = appendToMessage(err, extraMessage)
            import matlab.bigdata.BigDataException;
            newErr = BigDataException(err.identifier, '%s\n%s', err.message, extraMessage);
            if ~isempty(err.cause)
                newErr = addCause(newErr, err.cause{1});
            end
            newErr.ClientStack = err.ClientStack;
            newErr.RemoteStack = err.RemoteStack;
            newErr.RemoteDebugStack = err.RemoteDebugStack;
            newErr.SubmissionStack = err.SubmissionStack;
        end
    end
    
    methods (Access = protected)
        % Override of the getStack method that replaces the exception stack
        % with one that has been prepended by a submission stack.
        function stack = getStack(err)
            import matlab.bigdata.BigDataException;
            stack = getStack@MException(err);
            
            % Only modify the stack if 'BigDataException.throwWithMarkerFrame'
            % is still on the stack. This will be the case exactly until
            % throw or throwAsCaller are called.
            if isempty(stack) || stack(1).name ~= "BigDataException.throwWithMarkerFrame"
                return;
            end
            
            if BigDataException.showFullStack()
                remoteStack = err.RemoteDebugStack;
            else
                remoteStack = err.RemoteStack;
            end
            
            submissionStack = err.SubmissionStack;
            clientStack = err.ClientStack;
            % If these two are equal, typically a FunctionHandle error has
            % been issued from within the same funfun method that created
            % the operation. We remove the duplication as it isn't
            % necessary.
            if isequal(submissionStack, clientStack)
                submissionStack = [];
            end
            
            stack = [remoteStack; submissionStack; clientStack];
        end
    end
    
    methods (Access = private)
        % Private constructor for build methods.
        function err = BigDataException(varargin)
            err = err@MException(varargin{:});
        end
        
        % Private helper method that is intended to throw with the last
        % stack frame being "BigDataException.throwWithMarkerFrame".
        function throwWithMarkerFrame(err)
            throw(err);
        end
    end
    
    methods (Static, Hidden)
        % Static state that determines if errors thrown by this class
        % display the full stack or a user-friendly version.
        function out = showFullStack(in)
            persistent value;
            if ~nargin && ~nargout
                value = true;
            elseif isempty(value)
                value = false;
            end
            if nargout
                out = value;
            end
            if nargin
                value = in;
            end
        end
    end
end
