function copyUnlinked(gobj)

% Copyright 2008-2014 The MathWorks, Inc.

import com.mathworks.page.datamgr.brushing.*;

% Find brushed graphics in this container
sibs = datamanager.getAllBrushedObjects(gobj);

if length(sibs)==1
    localMultiObjCallback(sibs);
elseif length(sibs)>1 % More than 1 obj brushed, open disambiguation dialog
    datamanager.disambiguate(handle(sibs),{@localMultiObjCallback});
end


function localMultiObjCallback(gobj)

import com.mathworks.page.datamgr.brushing.*;

cmdStr = datamanager.var2string(brushing.select.getArraySelection(gobj));

ClipBoardManager.copySelectionToClip(cmdStr);

