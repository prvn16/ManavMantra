function tb = repelem(ta, varargin)
%REPELEM  Replicate elements of a tall array.
%   TB = REPELEM(TA,1,N)
%   TB = REPELEM(TA,1,N,P,...)
%
%   Limitations:
%   1) The two-input form of REPELEM is not supported.
%   2) The replication factor in the first dimension must be 1.
%
%   See also:REPELEM, TALL.

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);

% First input must be tall. Rest must be small.
tall.checkIsTall(upper(mfilename), 1, ta);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% We do some basic upfront error checking of the replication factors. Other
% errors will be caught at runtime.
if any(~cellfun(@isnumeric, varargin))
    error(message('MATLAB:repelem:nonNumericReplications'))
end

% We need to ensure that the tall dimension is not being expanded
M = varargin{1};
if ~isnumeric(M) || ~isscalar(M) || (M~=1)
    error(message('MATLAB:bigdata:array:CannotExpandTallDimension', upper(mfilename)));
end

% Do it
tb = slicefun(@(x) repelem(x,varargin{:}), ta);
tb.Adaptor = resetSmallSizes(ta.Adaptor);
end
