function pasteUnlinked(h)

% Copyright 2007-2014 The MathWorks, Inc.

% Paste the current selection to the command line
sibs = datamanager.getAllBrushedObjects(h);
if isempty(sibs)
    errordlg(getString(message('MATLAB:datamanager:pasteUnlinked:AtLeastOneGraphicObjectMustBeBrushed')),'MATLAB','modal')
    return
elseif length(sibs)==1
    localMultiObjCallback(sibs);
else
    datamanager.disambiguate(handle(sibs),{@localMultiObjCallback});
end

function localMultiObjCallback(gobj)

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.mde.cmdwin.*;

cmdStr = datamanager.var2string(brushing.select.getArraySelection(gobj));
cmd = CmdWinDocument.getInstance;
awtinvoke(cmd,'insertString',cmd.getLength,cmdStr,[]);