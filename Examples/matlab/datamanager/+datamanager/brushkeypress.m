function brushkeypress(es,ed)

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;

% Copyright 2008-2015 The MathWorks, Inc.

% Key hit callback for MATLAB figures when brushing mode is active.

% Note that we do not need key listeners for undo, redo, or ctrl-c since
% those events are handled by the corresponding menu accelerators.


if strcmp(ed.Key,'delete')     
     if datamanager.isFigureLinked(es)
         LinkPlotPanel.fireFigureCallback(es,'datamanager.dataEdit',...
             {[],[],'replace',NaN});
     else
         datamanager.dataEdit(es,[],[],'replace',NaN);
     end
end



