%ParallelException Capture error information from errors thrown in user code inside a parallel language construct.
%
%   ParallelException methods:
%      throw         - Issue exception and terminate function
%      rethrow       - Reissue existing exception and terminate function
%      throwAsCaller - Issue exception as if from calling function
%      addCause      - Record additional causes of exception
%      getReport     - Get error message for exception
%      last          - Return last uncaught exception
%
%   ParallelException properties:
%      identifier  - Character string that uniquely identifies the error	
%      message     - Formatted error message that is displayed
%      cause       - Cell array of MExceptions that caused remotecause
%      remotecause - The MException that caused this ParallelException
%      stack       - Structure containing stack trace information
%
%   See also try, catch, MException

%   Copyright 2012-2013 The MathWorks, Inc.

classdef ParallelException < MException & matlab.mixin.CustomDisplay
    % The intention of ParallelException is to fabricate the stack of the error
    % that is seen by the users such that all PCT code is removed.  e.g.
    %
    % Worker Error Stack
    %   <user code called by parfor>
    %   <user code inside parfor>
    %   ------------- <-- Stack frames above this won't appear in the error
    %   <PCT function>
    %   <PCT function - e.g. distcomp_evaluate_filetask>
    %
    % Client Error Stack
    %   <PCT function>
    %   <PCT function - e.g. parallel_function>
    %   ------------- <-- Stuff below this won't appear in the error
    %   <user code that does something with PCT e.g. parfor>
    %   <main user code>
    %
    % Then the resulting error stack should be:
    %   <user code called by parfor>
    %   <user code inside parfor>
    %   <user code that does something with PCT e.g. parfor>
    %   <main user code>
    %
    % Note that when referring to stacks, "up" and "above" mean moving from
    % this frame to the caller's frame; "down" and "below" mean moving from
    % this frame to the callee's frame.  (This is the same as dbup and dbdown).
    %
    % The arrays of stack frames that are used in this class are in the same
    % order as presented by MException - i.e. element n+1 is the caller of the
    % function at element n.  In other words, to go up the stack, you go down
    % the array.

    properties (Access = private)
       ClientStack
       RemoteStackToUse
       
       ShouldManipulateStack = true;
    end
    
    properties (SetAccess = private, GetAccess = public)
        %remotecause Cell array of MExceptions that caused this exception
        %   (read-only)
        %   remotecause can be used to interrogate the MExceptions thrown
        %   inside a parallel language construct that caused this exception.
        %
        %   See also ParallelException/cause
        remotecause = {};% lowercase to conform to the case used in the superclass
    end
    
    methods (Static, Hidden)
        function ex = hBuildFromRemoteException(remoteEx, ignoreRemoteStackAboveFiles)
        % Build a ParallelException with an empty client stack and ignore
        % any remote stack frames that occur at or above the specified
        % files.  i.e. the resulting exception will use only those stacks
        % frames from the remoteEx that are called by
        % ignoreRemoteStackAboveFiles. This is used on a worker to build
        % the ParallelException that should be serialized back to the
        % client.
            clientStack = [];
            stackToKeep = iGetStackBelowFile(remoteEx.stack, ignoreRemoteStackAboveFiles);
            ex = ParallelException(clientStack, remoteEx, stackToKeep);
        end

        function ex = hBuildRemoteParallelException(ex, ignoreClientStackBelowFiles, varargin)
        % Build a ParallelException using the full stack in the remoteEx
        % and the current stack as the client stack, but ignoring the parts
        % of the client stack that occur at or below the specified files.
        % If the supplied exception is already a ParallelException, then 
        % just add the client stack to the parallel exception.
        % This is used on the client to build a ParallelException from the 
        % deserialized exception.
        
            clientStack = iGetCurrentStack();
            clientStack = iGetStackAboveFile(clientStack, ignoreClientStackBelowFiles);
            if isa(ex, 'ParallelException')
                ex.ClientStack = clientStack;
            else
                remoteStackToKeep = ex.stack;
                ex = ParallelException(clientStack, ex, remoteStackToKeep);
            end
        end
        
        function newEx = hBuildLocalParallelException(remoteEx, ignoreStackAtFiles, varargin)
        % Build a ParallelException with an empty client stack and ignore
        % any remote stack frames that are at the specified files.  This is
        % used to build a ParallelException when there is no pool.
            clientStack = [];
            stackToKeep = iRemoveStackFrames(remoteEx.stack, ignoreStackAtFiles);
            newEx = ParallelException(clientStack, remoteEx, stackToKeep);
        end

        function newEx = hCloneWithNewMessage(oldEx, identifierOrMessage, varargin)
        % Build a ParallelException from another ParallelException, but
        % with a new message.
            validateattributes(oldEx, {'ParallelException'}, {'scalar'});
            
            if isa(identifierOrMessage, 'message')
                newEx = ParallelException(oldEx.ClientStack, oldEx.remotecause{1}, ...
                    oldEx.RemoteStackToUse, identifierOrMessage);
            else
                newEx = ParallelException(oldEx.ClientStack, oldEx.remotecause{1}, ...
                    oldEx.RemoteStackToUse, message(identifierOrMessage, varargin{:}));
            end
        end
        
        function ex = hBuildLikeMException(varargin)
            emptyStack = struct([]);
            ex = ParallelException(emptyStack, MException.empty, emptyStack, varargin{:});
        end
    end
    
    methods (Access = private)
        function obj = ParallelException(clientStack, ...
                remoteException, remoteStackToUse, varargin)
        % PE = ParallelException(clientStack, remoteException, ...
        %          remoteStackToUse, errID, errMsg, V1, V2, ..., VN) 
        % captures information about an error in user code that occurred
        % within a parallel construct.  A ParallelException should be used
        % to make the user's error appear as if it did not cross
        % application and machine boundaries.
        %    
        % clientStack is a structure containing the stack trace information
        % of the client-side portion of the user's code.
        %
        % remoteException is the exception that was thrown in the user code
        % on the remote end of the execution.  The remoteException is added
        % as a cause to the current exception.
        %
        % remoteStackToUse is a structure containing the stack information
        % from the remoteException that should be presented to the user in
        % this exception.  All other stack frames in the remoteException
        % are not shown to the user.
        %
        % errID, errMsg and the remaining input arguments are forwarded
        % directly to the MException constructor.
        %
        % PE = ParallelException(clientStack, remoteException, ...
        %          remoteStackToUse, message) 
        % creates a ParallelException using the supplied message.
        %
        % PE = ParallelException(clientStack, remoteException, ...
        %          remoteStackToUse) 
        % creates a ParallelException whose identifier and message are the
        % same as the identifier and message of the remoteException.
        %
        % If the clientStack, remoteException and remoteStackToUse are all
        % empty, then the ParallelException behaves like an MException and
        % no stack manipulation is performed.
        
            if nargin < 4
                mExceptionArgs = {remoteException.identifier, '%s', remoteException.message};
            else
                mExceptionArgs = varargin;
            end
            obj@MException(mExceptionArgs{:});            
            if ~isempty(remoteException)
                obj = obj.hAddRemoteCause(remoteException);
                for ii = 1:numel(remoteException.cause)
                    obj = obj.addCause(remoteException.cause{ii});
                end
            end
            
            if isempty(remoteException) && isempty(clientStack) && isempty(remoteStackToUse)
                % This is the "MException" mode.
                obj.ShouldManipulateStack = false;
            else
                obj.ClientStack      = clientStack;
                obj.RemoteStackToUse = remoteStackToUse;
            end
        end
    end
    
    methods (Access = protected)        
        function s = getStack(obj)
        % Override of MException's getStack to fabricate the
        % stack of this exception.
            if obj.ShouldManipulateStack
                s = [obj.RemoteStackToUse; obj.ClientStack];
            else
                s = getStack@MException(obj);
            end
        end
        
        function groups = getPropertyGroups(obj)
            % Overriding default display from CustomDisplay mixin
            % If any further public properties are added to
            % ParallelException their place in the display can be changed here.
            parallelExceptionPropertyList = properties(obj);
            
            % The remotecause property should follow the cause property
            propertyToMove =  {'remotecause'};
            parallelExceptionPropertyList = parallelExceptionPropertyList(~strcmp(parallelExceptionPropertyList, propertyToMove));
            indexLocationOfCause = find(strcmp(parallelExceptionPropertyList, 'cause'));          
            parallelExceptionPropertyList = [parallelExceptionPropertyList(1:indexLocationOfCause);...
                propertyToMove;...
                parallelExceptionPropertyList(indexLocationOfCause+1:end)];            
            groups = matlab.mixin.util.PropertyGroup(parallelExceptionPropertyList);
        end
    end
    
    methods (Hidden)
        function obj = hAddRemoteCause(obj, mException)
            % Append causes to the remotecause, c.f. addCause@MException
            obj.remotecause = [obj.remotecause; {mException}];
        end
    end
end

%---------------------------------------------------------------------
function stack = iGetCurrentStack()
try
    error('parallel:internal:cluster:DummyError', 'This is a dummy error')
catch err
    stack = err.stack;
    % Remove this function from the stack
    stack = stack(2:end);
end
end

%---------------------------------------------------------------------
function stack = iGetStackBelowFile(stack, files)
% Keep only those frames in the supplied stack that occur below the
% specified filenames. i.e the last element in the returned stack array is
% the one that is called by one of the specified filenames.  If more than
% one of the specified files appears in the stack, then the file that
% appears lowest down in the stack wins.  i.e. the returned stack will
% never contain any of the supplied filenames.
cutOffFrame = iCompareFramesWithFiles(stack, files);
cutOffFrame = find(cutOffFrame, 1, 'first');
% Always return n-by-1 by ensuring that the potentially-empty
% subscript is in the first place.
stack = stack(1:cutOffFrame-1, 1);
end

%---------------------------------------------------------------------
function stack = iGetStackAboveFile(stack, files)
% Keep only those stack frame that occur above the specified filenames.
% i.e. the first element in the returned stack array is the one that is the
% caller of one of the filenames.  If more than one of the specified files
% appears in the stack, then the file that appears highest up in the stack
% wins.  i.e. the returned stack will never contain any of the supplied
% filenames.
cutOffFrame = iCompareFramesWithFiles(stack, files);
cutOffFrame = find(cutOffFrame, 1, 'last');
stack = stack(cutOffFrame + 1:end);
end

%---------------------------------------------------------------------
function stack = iRemoveStackFrames(stack, files)
% Remove the parts of the supplied stack that correspond to the supplied
% filenames.
framesToRemove = iCompareFramesWithFiles(stack, files);
stack(framesToRemove) = [];
end

%---------------------------------------------------------------------
function tf = iCompareFramesWithFiles(stack, files)
% Return a logical array indicating which of the stack frames correspond to
% the supplied filenames.
if ~iscell(files)
    files = {files};
end

% Ensure that the filenames don't have path or extensions before comparing.
[~, files] = cellfun(@fileparts, files, 'UniformOutput', false);

tf = false(size(stack));
for ii = 1:numel(files)
    tf = tf | ...
        arrayfun(@(x) iIsFrameInFile(x, files{ii}), stack);
end
end

%---------------------------------------------------------------------
function tf = iIsFrameInFile(frame, filename)
% Return true if the supplied stack frame is somewhere in the specified filename
[~, frameFilename] = fileparts(frame.file);
tf = any(strcmp({frame.name, frameFilename}, filename));
end
