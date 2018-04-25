%INPUTNAME Input argument name.
%   Inside the body of a user-defined function, INPUTNAME(ARGNO)
%   returns the caller's workspace variable name corresponding to 
%   the argument number ARGNO.  If the input has no name, for example,
%   when it is the result of a calculation or an expression such as,
%   a(1), varargin{:}, eval(expr), etc, then INPUTNAME returns an
%   empty character vector.
%
%   Example: Suppose the function myfun is defined as:
%     function y = myfun(a,b)
%     disp(sprintf('My first input is "%s".' ,inputname(1)))
%     disp(sprintf('My second input is "%s".',inputname(2)))
%     y = a+b;
%   then
%     x = 5; myfun(x,5)
%   produces
%     My first input is "x".
%     My second input is "".
%
%   See also NARGIN, NARGOUT, NARGINCHK, NARGOUTCHK, MFILENAME.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.
