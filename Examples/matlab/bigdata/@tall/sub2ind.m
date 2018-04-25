function out = sub2ind(siz, varargin)
%SUB2IND Linear index from multiple subscripts.
%   IND = SUB2IND(SIZ,I,J)
%   IND = SUB2IND(SIZ,I1,I2,...,IN)
%
%   See also: sub2ind.

% Copyright 2016 The MathWorks, Inc.

narginchk(2, inf);

if ~all(cellfun(@(x) istall(x), varargin)) 
    error(message('MATLAB:bigdata:array:AllArgsTall', upper(mfilename)));
end

[siz, varargin{:}] = ...
    tall.validateType(siz, varargin{:}, mfilename, {'numeric'}, 1:nargin);

out = elementfun(@sub2ind, matlab.bigdata.internal.broadcast(siz), varargin{:});
out = setKnownType(out, 'double');
end
