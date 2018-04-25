function varargout = datetimePiece(fcnName, outClassName, tdt, varargin)
%datetimePiece Common implementation for tall datetime day/month/year etc.
%   varargout = datetimePiece(fcnName, tdt, varargin)
%   * fcnName is 'year', 'month' etc.
%   * tdt will be validated to be a tall datetime
%   * trailing varargin will be validated to be non-tall
%   * Each output *must* be the same size as the tall input
%
%   The calling function must call narginchk and nargoutchk.

% Copyright 2016-2017 The MathWorks, Inc.

name = upper(fcnName);
% Note the "1" here is the offset in the original calling function.
tall.checkNotTall(name, 1, varargin{:});
tdt = tall.validateType(tdt, name, {'datetime'}, 1);

% Call the underlying element-wise function
underlyingFcn = str2func(fcnName);
[varargout{1:nargout}] = elementfun(@(x) underlyingFcn(x, varargin{:}), tdt);

% Update type if known
if ~isempty(outClassName)
    [varargout{:}] = setKnownType(varargout{:}, outClassName);
end
end
