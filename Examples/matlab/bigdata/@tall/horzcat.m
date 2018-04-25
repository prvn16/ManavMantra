function out = horzcat(varargin)
%HORZCAT Horizontal concatenation
%   [A B] is the horizontal concatenation of matrices A and B.  A and B
%   must have the same number of rows. 
%
%   See also tall/cat.

% Copyright 2015-2017 The MathWorks, Inc.

if ~all(cellfun(@istall, varargin))
    error(message('MATLAB:bigdata:array:AllArgsTall', upper(mfilename)));
end

adaptors = cellfun(@(x) x.Adaptor, varargin, 'UniformOutput', false);
dim = 2;
try
    newAdaptor = matlab.bigdata.internal.adaptors.combineAdaptors(dim, adaptors);
catch E
    % combineAdaptors can throw a variety of errors that should appear to come from
    % this method.
    throw(E);
end

inputs = cell(1, nargin);
[inputs{:}] = validateSameTallSize(varargin{:});
out = slicefun(@horzcat, inputs{:});
out.Adaptor = newAdaptor;
end
