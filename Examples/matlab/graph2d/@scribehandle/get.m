function value = get(hndl,varargin)
%SCRIBEHANDLE/GET Get scribehandle property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

ud = getscribeobjectdata(hndl.HGHandle);
value = get(ud.ObjectStore,varargin{:});
