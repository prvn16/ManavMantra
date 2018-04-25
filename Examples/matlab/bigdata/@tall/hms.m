function varargout = hms(tt)
%HMS Hour, minute, and second numbers of tall datetime and duration.
%   [H,M,S] = HMS(T)
%
%   See also DATETIME/HMS, DURATION/HMS.

%   Copyright 2015-2016 The MathWorks, Inc.

nargoutchk(0,3);
tt = tall.validateType(tt, mfilename, {'datetime', 'duration'}, 1);
[varargout{1:max(nargout,1)}] = elementfun(@hms, tt);
[varargout{:}] = setKnownType(varargout{:}, 'double');
end
