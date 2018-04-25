function varargout = codetoolsswitchyard(action,varargin)
% CODETOOLSSWITCHYARD  This function will be removed in a future release.

%   Copyright 2005 The MathWorks, Inc.

if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end
