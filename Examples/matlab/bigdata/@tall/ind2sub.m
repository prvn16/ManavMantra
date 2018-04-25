function varargout = ind2sub(siz, ndx)
%IND2SUB Multiple subscripts from linear index.
%   [I,J] = IND2SUB(SIZ,IND)
%   [I1,I2,I3,...,In] = IND2SUB(SIZ,IND) 
%
%   See also: ind2sub.

% Copyright 2016 The MathWorks, Inc.

narginchk(2,2);

if ~istall(ndx)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 2, upper(mfilename)));
end

[siz, ndx] = tall.validateType(siz, ndx, mfilename, {'numeric'}, 1:nargin);

[varargout{1:max(nargout,1)}] = ...
    elementfun(@ind2sub, matlab.bigdata.internal.broadcast(siz), ndx);
[varargout{:}] = setKnownType(varargout{:}, 'double');
end
