function domethod(A, method, varargin)
%SCRIBEHANDLE/DOMETHOD Domethod method for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

ud = getscribeobjectdata(A.HGHandle);
MLObj = ud.ObjectStore;
MLObj = feval(method, MLObj, varargin{:});

% writeback
ud.ObjectStore = MLObj;
setscribeobjectdata(A.HGHandle,ud);
