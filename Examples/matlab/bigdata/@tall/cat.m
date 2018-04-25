function out = cat(dim, varargin)
%CAT Concatenate arrays.
%   CAT(DIM,A,B) concatenates the arrays A and B along
%   the dimension DIM.
%
%   Limitations:
%   1) Vertical concatenation of character arrays is not supported.
%   2) Concatenation in any dimension other than 1 requires all input
%      arguments to be tall arrays.
%
%   See also HORZCAT, VERTCAT.

% Copyright 2015-2017 The MathWorks, Inc.

tall.checkNotTall(upper(mfilename), 0, dim);

if ~(isnumeric(dim) && ~isobject(dim) && isscalar(dim) && dim == round(dim))
    error(message('MATLAB:catenate:invalidDimension'));
end

% Pass vertical concatenation directly to tall/vertcat.
if dim == 1
    out = vertcat(varargin{:});
    return;
end

if dim > double(intmax('int32'))
    error(message('MATLAB:catenate:maxNDims'));
end

if ~all(cellfun(@istall, varargin))
    error(message('MATLAB:bigdata:array:AllArgsTall', upper(mfilename)));
end

if any(cellfun(@iIsTabular, varargin)) && dim > 2
    error(message('MATLAB:table:cat:InvalidDim'));
end

adaptors = cellfun(@(x) x.Adaptor, varargin, 'UniformOutput', false);
try
    newAdaptor = matlab.bigdata.internal.adaptors.combineAdaptors(dim, adaptors);
catch E
    % combineAdaptors can throw a variety of errors that should appear to come from
    % this method.
    throw(E);
end

inputs = cell(1, nargin-1);
[inputs{:}] = validateSameTallSize(varargin{:});
out = slicefun(@(varargin) cat(dim, varargin{:}), inputs{:});
out.Adaptor = newAdaptor;
end

%--------------------------------------------------------------------------
function tf = iIsTabular(A)
% tf is true when input A is either a table or timetable

inputClass = A.Adaptor.Class;
tf = any(strcmpi(inputClass, {'table', 'timetable'}));
end
