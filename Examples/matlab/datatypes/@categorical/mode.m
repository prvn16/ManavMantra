function [b,f,c] = mode(a,dim)
%MODE Mode, or most frequent value in a sample.
%   M = MODE(X) for a categorical vector X computes M as the sample mode, or
%   most frequently occurring value in X. M has the same categories as X. For a
%   matrix X, M is a row vector containing the mode of each column. For N-D
%   arrays, MODE(X) is the mode of the elements along the first non-singleton
%   dimension of X.
%
%   When there are multiple values occurring equally frequently, MODE returns
%   the value from the category that occurs first in CATEGORIES(X).
%
%   [M,F] = MODE(X) also returns an array F, of the same size as M. Each element
%   of F is the number of occurrences of the corresponding element of M.
%
%   [M,F,C] = MODE(X) also returns a cell array C, of the same size as M. Each
%   element of C is a sorted vector of all the values having the same frequency
%   as the corresponding element of M.
%
%   [...] = MODE(X,DIM) takes the mode along the dimension DIM of X.
%
%   See also MEDIAN, HIST.

% Copyright 2014-2015 The MathWorks, Inc.

narginchk(1, 2);

acodes = a.codes;

% Rely on built-in's NaN handling if input contains any <undefined> elements.
acodes = categorical.castCodesForBuiltins(acodes);

% Rely on mode's behavior with dim vs. without, especially for empty input
outArgs = cell(1,nargout-1);
try
    if nargin == 1
        [bcodes,outArgs{:}] = mode(acodes);
    else
        [bcodes,outArgs{:}] = mode(acodes,dim);
    end
catch ME
    throw(ME);
end

if isfloat(bcodes)
    % Cast back to integer codes, including NaN -> <undefined>
    numCats = length(a.categoryNames);
    bcodes = categorical.castCodes(bcodes,numCats);
end
b = a; % preserve subclass
b.codes = bcodes;

if nargout > 1
    f = outArgs{1};
    if nargout > 2
        c = outArgs{2};
        % Convert each vector of codes to a categorical vector
        c_i = a;
        for i = 1:numel(c)
            if isfloat(c{i})
                c{i} = categorical.castCodes(c{i},numCats);
            end
            c_i.codes = c{i};
            c{i} = c_i;
        end
    end
end
