function tb = repmat(ta, varargin)
%REPMAT  Replicate and tile a tall array.
%   TB = REPMAT(TA,1,N) or TB = REPMAT(TA,[1 N])
%   TB = REPMAT(TA,1,N,P,...) or TB = REPMAT(TA,[1 N P ...])
%
%   Limitations:
%   The replication factor in the first dimension must be 1.
%
%   See also repmat, tall/repelem.

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);

% First input must be tall. Rest must be small.
tall.checkIsTall(upper(mfilename), 1, ta);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% We do some basic upfront error checking of the replication factors. Weird
% combinations of scalar and vector inputs will be caught at runtime.
if any(~cellfun(@isnumeric, varargin))
    error(message('MATLAB:repmat:nonNumericReplications'))
end

% We need to ensure that the tall dimension is not being expanded
M = varargin{1}(1);
if ~isnumeric(M) || ~isscalar(M) || (M~=1)
    error(message('MATLAB:bigdata:array:CannotExpandTallDimension', upper(mfilename)));
end

% Do it
tb = slicefun(@repmat, ta, varargin{:});
tb.Adaptor = resetSmallSizes(ta.Adaptor);
end
