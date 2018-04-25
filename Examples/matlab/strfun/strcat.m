function t = strcat(varargin)
%STRCAT Concatenate text.
%   COMBINEDSTR = STRCAT(S1, S2, ..., SN) horizontally concatenates text
%   in arrays S1, S2, ..., SN. Inputs can be combinations of character
%   vectors, character vectors in scalar cells, character arrays with the
%   same number of rows, same-sized cell arrays of character vectors,
%   scalar strings, or same-sized string arrays. If any input is a string
%   array, COMBINEDSTR is a string array. Otherwise, if any input is a cell
%   array, COMBINEDSTR is a cell array.  Otherwise, COMBINEDSTR is a 
%   character array.
%
%   Notes:
%
%   For character array inputs, STRCAT removes trailing ASCII white-space
%   characters: space, tab, vertical tab, newline, carriage return, and
%   form-feed. To preserve trailing spaces when concatenating character
%   arrays, use horizontal array concatenation, [s1, s2, ..., sN].
%
%   For string and cell array inputs, STRCAT does not remove trailing white
%   space.
%
%   When combining nonscalar string or cell arrays with multi-row character
%   arrays, the string or cell arrays must be column vectors with the same
%   number of rows as the character arrays.
%
%   Example:
%
%       strcat({'Red','Yellow'},{'Green','Blue'})
%
%   returns
%
%       'RedGreen'    'YellowBlue'
%
%   See also CAT, CELLSTR, STRING.

%   Copyright 1984-2016 The MathWorks, Inc.

%   The cell array implementation is in @cell/strcat.m
%   The string array implementation is in @string/strcat.m

narginchk(1, inf);

for i = 1:nargin
    input = varargin{i};
    if ~isnumeric(input) && ~ischar(input) && ~iscell(input)
        error(message('MATLAB:strcat:InvalidInputType'));
    end
end

% Initialize return arguments
t = '';

% Get number of rows of each input
rows = cellfun('size', varargin, 1);
% Get number of dimensions of each input
twod = (cellfun('ndims', varargin) == 2);

% Return empty string when all inputs are empty
if all(rows == 0)
    return;
end
if ~all(twod)
    error(message('MATLAB:strfun:InputDimension'));
end

% Remove empty inputs
k = (rows == 0);
varargin(k) = [];
rows(k) = [];
maxrows = max(rows);
% Scalar expansion

for i = 1:length(varargin)
    if rows(i) == 1 && rows(i) < maxrows
        varargin{i} = varargin{i}(ones(1,maxrows), :);
        rows(i) = maxrows;
    end
end

if any(rows ~= rows(1))
    error(message('MATLAB:strcat:NumberOfInputRows'));
end

n = rows(1);
space = sum(cellfun('prodofsize', varargin));
s0 =  blanks(space);
scell = cell(1, n);
notempty = true(1, n);
s = '';
for i = 1:n
    s = s0;
    input = varargin{1}(i, :);
    if ~isempty(input) && (input(end) == 0 || isspace(input(end)))
        input = char(deblank(input));
    end
    pos = length(input);
    s(1:pos) = input;
    pos = pos + 1;
    for j = 2:length(varargin)
        input = varargin{j}(i, :);
        if ~isempty(input) && (input(end) == 0 || isspace(input(end)))
            input = char(deblank(input));
        end
        len = length(input);
        s(pos:pos+len-1) = input;
        pos = pos + len;
    end
    s = s(1:pos-1);
    notempty(1, i) = ~isempty(s);
    scell{1, i} = s;
end
if n > 1
    t = char(scell{notempty});
else
    t = s;
end
