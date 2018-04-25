%THROW Issue exception and terminate function.
%   THROW(ME) terminates the currently running function, issues an
%   exception that is based on MException object ME, and returns control to
%   the keyboard or to any enclosing catch block. A thrown MException
%   displays a message in the Command Window unless it is caught by
%   TRY-CATCH. THROW also sets the MException stack field to the location
%   from which the THROW method was called.
%
%   Example:
%      [minval, maxval] = evaluate_plots(p24, p28, p41);
%      if minval < lower_bound || maxval > upper_bound
%         ME = MException('VerifyOutput:OutOfBounds', ...
%            'Results are outside the allowable limits');
%         throw(ME);
%      end
%
%   See also MException, throwAsCaller, RETHROW, STACK, ERROR, ASSERT, TRY, CATCH.

%   Copyright 2007-2010 The MathWorks, Inc.
%   Built-in function.
