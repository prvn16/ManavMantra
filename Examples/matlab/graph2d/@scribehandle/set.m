function set(hndl,varargin)
%SCRIBEHANDLE/SET Set scribehandle property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

% get the object
ud = getscribeobjectdata(hndl.HGHandle);

% call object methods
MyObject = set(ud.ObjectStore,varargin{:});
ud.ObjectStore = MyObject;

% writeback
setscribeobjectdata(hndl.HGHandle,ud);



