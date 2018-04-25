%TRY  Begin TRY block.
%   The general form of a TRY statement is:
% 
%      TRY
%         statement, ..., statement, 
%      CATCH ME
%         statement, ..., statement 
%      END
%
%   Normally, only the statements between the TRY and CATCH are executed.
%   However, if an error occurs while executing any of the statements, the
%   error is captured into an object, ME, of class MException, and the 
%   statements between the CATCH and END are executed. If an error occurs 
%   within the CATCH statements, execution stops, unless caught by another 
%   TRY...CATCH block. The ME argument is optional. 
%
%   See also CATCH, MException, rethrow, EVAL, EVALIN, END.

%   Copyright 1984-2009 The MathWorks, Inc.
%   Built-in function.
