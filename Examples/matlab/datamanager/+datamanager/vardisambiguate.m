function vardisambiguate(fig,varNames,varValues,mfile,fcnname,okAction)

% Utility method for brushing/linked plots. May change in a future release.

% Copyright 2007-2011 The MathWorks, Inc.

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;
import com.mathworks.page.plottool.plotbrowser.*;

% Find linked variable names
% Build table entries
tableData = javaArray('java.lang.Object',length(varNames),3);
brushMgr = datamanager.BrushManager.getInstance();
for k=1:length(varNames)
    tableData(k,1) = java.lang.String(varNames{k});
    I = brushMgr.getBrushingProp(varNames{k},mfile,fcnname,'I');
%     tableData(k,2) = java.lang.String(sprintf(getString(message('MATLAB:datamanager:vardisambiguate:NumberInteger',sum(I(:)))),numel(I)));
    tableData(k,2) = java.lang.String(getString(message('MATLAB:datamanager:vardisambiguate:NumberInteger',sum(I(:)),numel(I))));
    varDescriptions = workspacefunc('getabstractvaluesummariesj',{varValues{k}});     %#ok<CCAT1>
    tableData(k,3) = varDescriptions(1);
end

% Build and show Disambiguation dialog
dlg = javaObjectEDT('com.mathworks.page.datamgr.brushing.VariableDisambiguationDialog',...
    datamanager.getJavaFrame(fig),tableData,...
    {getString(message('MATLAB:datamanager:vardisambiguate:Name')),getString(message('MATLAB:datamanager:vardisambiguate:NumberOfBrushedPoints')),getString(message('MATLAB:datamanager:vardisambiguate:Size'))});


% Specify callbacks
set(handle(dlg.getOKButton,'callbackproperties'),...
        'ActionPerformedCallback',{@localOK dlg okAction});

javaMethodEDT('show',dlg);
% Make sure the dialog is fully ready before interacting with it. We don't
% want callbacks executing before all java classes are fully initialized.
drawnow 


function localOK(~,~,dlg,okAction)

pos = dlg.getSelectionIndex+1;
javaMethodEDT('hide',dlg);
if pos>=1
    feval(okAction{1},pos,okAction{2:end});
end
javaMethodEDT('dispose',dlg);
    