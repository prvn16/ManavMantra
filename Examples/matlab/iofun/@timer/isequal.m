function out = isequal(varargin)
%ISEQUAL True if timer object arrays are equal.
%
%    ISEQUAL(A,B) is 1 if the two timer object arrays are the same
%    size and are equal, and 0 otherwise.
%
%    ISEQUAL(A,B,C,...) is 1 if all the timer object arrays are the
%    same size and are equal, and 0 otherwise.
% 

%    RDD 1-3-01
%    Copyright 2001-2003 The MathWorks, Inc.

% Error checking.
if nargin == 1,
    error(message('MATLAB:timer:notenoughinputs'));
end

% Loop through all the input arguments and compare to each other.
obj1 = varargin{1};
isFirstEmpty = isempty(obj1);

for i=1:nargin-1
    obj2 = varargin{i+1};
    
    % Return 0 if only one argument is empty.
    if (isFirstEmpty ~= isempty(obj2))
        out = false;
        return;
    end
    
    % Inputs must be the same size.
    if ~all((size(obj1) == size(obj2)))
        out = false;
        return;
    end
    
    % Call @timer\eq.
    out = eq(obj1, obj2);
    
    % If not equal, return false, otherwise loop and 
    % compare obj2 with the next object in the list.
    if (all(out) == false)
        out = false;
        return;
    end
end

out = true;