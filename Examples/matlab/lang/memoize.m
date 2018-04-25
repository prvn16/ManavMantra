function memoizedFcnHandle = memoize(fcnHandleToMemoize)
%MEMOIZE Adds memoization semantics to the input function handle, 
% and returns a MemoizedFunction object.
%
% Memoization is an optimization technique used primarily to speed up
% programs by storing the results of expensive function calls and returning
% the cached result when the same inputs occur again.
%
% Consider memoizing function calls which are:
% 1. time consuming, and
% 2. pure functions
%    i.e. Functions whose return value is only determined by its input values,
%    without observable side effects
%
% The MemoizedFunction object returned from MEMOIZE can be used
% just like the function handle used to create it.
%
% The object will maintain caches of inputs its called with and the 
% corresponding outputs produced.
% For more information refer to matlab.lang.MemoizedFunction
%
% Example 1: General usage
%
%   inputs = rand(1000);
%   output = eigs(inputs); % Slow function call
% 
%   % Creation
%   memoizedEigs = MEMOIZE(@eigs);
% 
%   % First call will execute EIGS and cache the results
%   output = memoizedEigs(inputs); 
% 
%   % Subsequent calls are faster, as they simply return cached results
%   output2 = memoizedEigs(inputs); %
%
% In the above example, it is safe to memoize EIGS as it will always give
% the same results for the same inputs.
%
% Example 2: Unsafe usage
%    Consider the matlab function RANDI. Every call to it with the input
%    10, should result in a random integer from 1-10.
% 
%   f = memoize(@randi); % RANDI has the side effect of setting global state
%   y = f(10)
%   y =
%       9
% 
%   y = f(10) % Subsequent runs also give same result for same input
%   y =
%       9
%
% Notes: 
% 1. Multiple calls to MEMOIZE with the same function handle will return 
%    the same MemoizedFunction object.
%    Example:
%      x = memoize(@plus);
%      y = memoize(@plus);
%      isequal(x, y)
%      ans = 
%             1
%
% 2. If you memoize a function with side effects such as setting some
%    global state, or performing I/O operations. The side effects are not
%    repeated on susbsequent calls to the memoized function with the same
%    inputs. As demonstrated in Example 2.
% 
% See also: MATLAB.LANG.MEMOIZEDFUNCTION, CLEARALLMEMOIZEDCACHES
 
% Copyright 2016 The MathWorks, Inc.

narginchk(0,1)
nargoutchk(0,1);

% Using singleton class MEMOIZER to track all handles created through this
% interface.
memoizer = matlab.lang.internal.Memoizer.getInstance();

if isa(fcnHandleToMemoize,'function_handle')
    memoizedFcnHandle  = memoizer.getMemoizedFunction(fcnHandleToMemoize);
else
    error(message('MATLAB:memoize:InputMustBeHandle'));
end
