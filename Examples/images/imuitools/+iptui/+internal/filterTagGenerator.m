function tag = filterTagGenerator(varargin)

% Copyright 2014 The MathWorks, Inc.

persistent counter
if isempty(counter)
    counter = 0;
end

if (nargin == 1) && isequal(varargin{1}, 'reset')
    counter = 0;
    tag = '';
    return
end

counter = counter + 1;

tag = sprintf('PropFilter_%d', counter);
end
