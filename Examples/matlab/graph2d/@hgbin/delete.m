function delete(aObj)
%HGBIN/DELETE Delete hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 


for anItem = aObj.Items
   delete(anItem);
end

delete(aObj.scribehgobj);
