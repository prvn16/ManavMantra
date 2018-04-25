%RETHROW Reissue existing exception and terminate function.
%   RETHROW(ME) terminates the currently running function, reissues an
%   exception that is based on MException object ME that has been caught
%   within a TRY-CATCH block, and returns control to the keyboard or to any
%   enclosing CATCH block. Call stack information in the ME object is kept
%   as it was when the exception was first thrown.
%
%   RETHROW differs from the throw and throwAsCaller methods in that
%   it does not modify the stack field. Also, RETHROW can only issue a
%   previously caught exception.
%
%   Example:
%      try
%         fid = fopen(file);
%         fread(fid);
%      catch ME
%         fclose(fid);
%         rethrow(ME);
%      end
%
%   See also MException, THROW, throwAsCaller, STACK, ERROR, ASSERT, TRY, CATCH.

%   Copyright 2007-2010 The MathWorks, Inc.
%   Built-in function.
