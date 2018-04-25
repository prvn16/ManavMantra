%RETURN Return to invoking function.
%   RETURN causes a return to the invoking function.
%
%   Normally functions return when the end of the function is reached.
%   A RETURN statement can be used to force an early return.
%
%   Example
%      function d = det(A)
%      if isempty(A)
%         d = 1;
%         return
%      else
%        ...
%      end
%
%   See also FUNCTION, BREAK, CONTINUE.

%   Copyright 1984-2017 The MathWorks, Inc. 
%   Built-in function.
