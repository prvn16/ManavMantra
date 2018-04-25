function selected = predicateSatisfied(predicate, varargin)
% predicateSatisfied Determine if the inputs satisfy the predicate.
% Draw as many inputs from the variable argument list as the predicate has
% input arguments.

% Make sure the predicate is a function
if ~isa(predicate,'function_handle')
    error(message('MATLAB:graphs:PredicateMustBeFcn', class(predicate)));
end

% Make sure we have enough arguments in varargin for the predicate
if nargin(predicate) > numel(varargin)
    error(message('MATLAB:graphs:PredicateArgSizeMismatch', ...
                  nargin(predicate), numel(varargin), numel(varargin)));
end

% Call the predicate, which must return true or false.
argCount = min(nargin(predicate), numel(varargin));
selected = predicate(varargin{1:argCount});

