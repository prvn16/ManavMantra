%BUILTIN  Execute built-in function from overloaded method.
%   BUILTIN is used in methods that overload built-in functions to execute
%   the original built-in function. If F is the name of a built-in function, 
%   specified as a character vector or string scalar, then BUILTIN(F,x1,...,xn) 
%   evaluates that function at the given arguments.
%
%   BUILTIN(...) is the same as FEVAL(...) except that it will call the
%   original built-in version of the function even if an overloaded one
%   exists (for this to work, you must never overload BUILTIN).
%
%   [y1,..,yn] = BUILTIN(F,x1,...,xn) returns multiple output arguments.
%
%   See also FEVAL.

%   Copyright 1984-2017 The MathWorks, Inc. 
%   Built-in function.
