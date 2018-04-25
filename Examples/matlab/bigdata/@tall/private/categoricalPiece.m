function varargout = categoricalPiece(fcnName, tc, varargin)
%categoricalPiece Common implementation for tall categorical addcats, removecats etc.
%   varargout = categoricalPiece(fcnName, tdt, varargin)
%   * fcnName is 'addcats', 'removecats' etc.
%   * tc will be validated to be a tall categorical
%   * trailing varargin will be broadcast.
%
%   The calling function must call narginchk and nargoutchk.

% Copyright 2016 The MathWorks, Inc.

name = upper(fcnName);
tc = tall.validateType(tc, name, {'categorical'}, 1);
vars = cellfun(@matlab.bigdata.internal.broadcast, varargin, 'UniformOutput', false);
% Call the underlying element-wise function
underlyingFcn = str2func(fcnName);
[varargout{1:nargout}]  = elementfun(underlyingFcn, tc, vars{:});
[varargout{:}] = setKnownType(varargout{:}, 'categorical');
end
