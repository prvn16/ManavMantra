function t = strcat(varargin)
%STRCAT String horizontal concatenation.
%   T = STRCAT(S1,S2,...), when any of the inputs is a cell array of
%   character vectors, returns a cell array of character vectors formed by
%   concatenating corresponding elements of S1,S2, etc.  The inputs must
%   all have the same size (or any can be a scalar).

%   Copyright 1984-2016 The MathWorks, Inc.

narginchk(1, inf);

% Make sure everything is a cell array
maxsiz = -1;
siz = cell(1, nargin);
for i = 1:nargin
    if ischar(varargin{i})
        varargin{i} = cellstr(varargin{i});
    elseif ~iscell(varargin{i})
        if isempty(varargin{i})
            varargin{i} = {''};
        else
            error(message('MATLAB:strcat:InvalidInputType'));
        end
    end
    siz{i} = size(varargin{i});
    if ~isscalar(varargin{i}) && prod(siz{i}) > prod(maxsiz)
        maxsiz = siz{i};
    end
end

if isequal(maxsiz, -1)
    maxsiz = [1, 1];
end

% Scalar coercion
for i = 1:length(varargin)
    if prod(siz{i}) == 1
        varargin{i} = varargin{i}(ones(maxsiz));
        siz{i} = size(varargin{i});
    end
end

if (numel(siz) > 1) && ~isequal(siz{:})
    error(message('MATLAB:strcat:InvalidInputSize'));
end

s = cell([length(varargin) maxsiz]);
for i = 1:length(varargin)
    s(i, :) = varargin{i}(:);
end

t = cell(maxsiz);
for i = 1:prod(maxsiz)
    t{i} = [s{:, i}];
end
