function addArgout(hThis, varargin)

% Copyright 2003-2015 The MathWorks, Inc.

argout = get(hThis,'Argout');
set(hThis,'Argout',[argout, varargin{:}]);
