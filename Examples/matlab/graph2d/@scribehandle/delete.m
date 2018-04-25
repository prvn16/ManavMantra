function delete(hndl)
%SCRIBEHANDLE/DELETE Delete scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2008 The MathWorks, Inc. 

h=hndl.HGHandle;
if ishghandle(h)
    ud = getscribeobjectdata(h);
    MLObj = ud.ObjectStore;
    delete(MLObj);
    delete(hndl.HGHandle);
end

    

