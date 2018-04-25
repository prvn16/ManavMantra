function varargout = basicfitdatastat(action,varargin)
%BASICFITDATASTAT switchyard for Basic Fitting and Data Statistics.

%   Copyright 1984-2002 The MathWorks, Inc.

% Calls from Java prefer the if/else version.
% [varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end
