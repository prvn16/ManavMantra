function deselect(hndl)
%SCRIBEHANDLE/DESELECT Deselect scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

ud = getscribeobjectdata(hndl.HGHandle);
MLObj = ud.ObjectStore;
deselect(MLObj);
