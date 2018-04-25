classdef onCleanup < handle
%onCleanup - Specify cleanup work to be done on function completion.
%   C = onCleanup(S), when called in function F, specifies any cleanup tasks
%   that need to be performed when F completes.  S is a handle to a function
%   that performs necessary cleanup work when F exits (e.g., closing files that
%   have been opened by F).  S will be called whether F exits normally or
%   because of an error.
%
%   onCleanup is a MATLAB class and C = onCleanup(S) constructs an instance C of
%   that class.  Whenever an object of this class is explicitly or implicitly
%   cleared from the workspace, it runs the cleanup function, S.  Objects that
%   are local variables in a function are implicitly cleared at the termination
%   of that function.
%
%   Example 1: Use onCleanup to close a file.
%
%       function fileOpenSafely(fileName)
%           fid = fopen(fileName, 'w');
%           c = onCleanup(@()fclose(fid));
%
%           functionThatMayError(fid);
%       end   % c will execute fclose(fid) here
%
%
%   Example 2: Use onCleanup to restore the current directory.
%
%       function changeDirectorySafely(fileName)
%           currentDir = pwd;
%           c = onCleanup(@()cd(currentDir));
%
%           functionThatMayError;
%       end   % c will execute cd(currentDir) here
%
%   See also: CLEAR, CLEARVARS

%   Copyright 2007-2012 The MathWorks, Inc.

    properties(SetAccess = 'private', GetAccess = 'public', Transient)
        task = @nop;
    end

    methods
        function h = onCleanup(functionHandle)
            % onCleanup - Create a ONCLEANUP object
            %   C = ONCLEANUP(FUNC) creates C, a ONCLEANUP object.  There is no need to
            %   further interact with the variable, C.  It will execute FUNC at the time it
            %   is cleared.
            %
            %   See also: CLEAR, ONCLEANUP
            h.task = functionHandle;
        end
        
        function delete(h)
            % DELETE - Delete a ONCLEANUP object.
            %   DELETE does not need to be called directly, as it is called when the
            %   ONCLEANUP object is cleared.  DELETE is implicitly called for all ONCLEANUP
            %   objects that are local variables in a function that terminates.
            %
            %   See also: CLEAR, ONCLEANUP, ONCLEANUP/ONCLEANUP
            h.task();
        end
    end
end
function nop
end
