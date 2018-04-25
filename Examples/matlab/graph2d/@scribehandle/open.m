function open(hndl)
%SCRIBEHANDLE/OPEN Open scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

ud = getscribeobjectdata(hndl.HGHandle);
MLObj = ud.ObjectStore;
open(MLObj);
