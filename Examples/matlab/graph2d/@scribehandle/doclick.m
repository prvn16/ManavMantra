function doclick(hndl)
%SCRIBEHANDLE/DOCLICK Click method for scribhandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2008 The MathWorks, Inc. 

ud = getscribeobjectdata(hndl.HGHandle);
MLObj = ud.ObjectStore;
MLObj = doclick(MLObj);

% writeback
if any(ishghandle(hndl.HGHandle))
   ud.ObjectStore = MLObj;
   setscribeobjectdata(hndl.HGHandle,ud);
end
