function newvardisambiguate(objs,okAction,callerWho)

% This static method builds and controls the dialog which resolves
% ambiguity caused by attempting to create a variable from multiple brushed
% graphic objects.

% Copyright 2007-2011 The MathWorks, Inc.

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;
import com.mathworks.page.plottool.plotbrowser.*;

% Build proxy objects for icon display
allProps = getplotbrowserproptable;
gProxy = ChartObjectProxyFactory.createSeriesProxyArray(length(objs));
for k=1:length(objs)
   gProxy(k) = ChartObjectProxyFactory.createSeriesProxy(java(handle(objs(k))),...
       class(handle(objs(k))));
   I1 = find(cellfun(@(x) strcmp(class(objs(k)),x{1}),allProps));
   if ~isempty(I1)
      propNames = allProps{I1}{2};
      for j=1:length(propNames)
          ChartObjectProxyFactory.updateProperty(gProxy(k),propNames{j});
      end
   end
end

% Build table entries
tableData = javaArray('java.lang.Object',length(objs),4);
for k=1:length(objs)
    tableData(k,1) = gProxy(k);
    bData = (get(objs(k),'BrushData')>0);
%     tableData(k,2) = java.lang.String(sprintf(getString(message('MATLAB:datamanager:newvardisambiguate:NumberInteger',...
%         sum(bData(:)))),length(get(objs(k),'xdata'))));
    tableData(k,2) = java.lang.String(getString(message('MATLAB:datamanager:newvardisambiguate:NumberInteger',...
        sum(bData(:)),length(get(objs(k),'xdata')))));
    tableData(k,3) = java.lang.String(get(objs(k),'Type'));
    tableData(k,4) = java.lang.String(get(objs(k),'Tag'));
end

% Build and show Disambiguation dialog
dlg = javaObjectEDT('com.mathworks.page.datamgr.brushing.NewVarDisambiguationDialog',...
    datamanager.getJavaFrame(ancestor(objs(1),'figure')),tableData,gProxy,...
    {' ',getString(message('MATLAB:datamanager:newvardisambiguate:NumberOfBrushedPoints')),'Type','Tag'},callerWho);


% Specify callbacks
set(handle(dlg.getSelectionModel,'callbackproperties'),...
        'ValueChangedCallback',{@localSelectObj objs});
set(handle(dlg.getCancelButton,'callbackproperties'),...
        'ActionPerformedCallback',{@localCancel dlg objs});
set(handle(dlg.getOKButton,'callbackproperties'),...
        'ActionPerformedCallback',{@localOK dlg okAction objs});
set(handle(dlg.getVariableComboBox.getEditor,'callbackproperties'),...
        'ActionPerformedCallback',{@localOK dlg okAction objs});
awtinvoke(dlg,'show()');
% Make sure the dialog is fully ready before interacting with it. We don't
% want callbacks executing before all java classes are fully initialized.
drawnow 


function localSelectObj(es,~,objs)

% There have been cases in automated testing where the graphics objects
% were deleted by the time this callback fired (g576643). Test to make 
% sure that objects are all valid before updating the dialog. Since this 
% dialog is modal this should never happen during manual operation.
if ~all(ishghandle(objs))
    return
end

pos = es.getMinSelectionIndex+1;

% Restore cached widths
localRestoreCachedWidths(objs)
if pos>=1
    lw = get(objs(pos),'LineWidth');
    setappdata(objs(pos),'CacheWidth',lw);
    set(objs(pos),'LineWidth',lw*3);
end


function localRestoreCachedWidths(ls)

for k=1:length(ls)
    cacheWidth = getappdata(ls(k),'CacheWidth');
    if ~isempty(cacheWidth )
        set(ls(k),'LineWidth',cacheWidth);
    end
end

function localCancel(~,~,dlg,objs)

% There have been cases in automated testing where the graphics objects
% were deleted by the time this callback fired (g576643). Test to make 
% sure that objects are all valid before updating the dialog. Since this 
% dialog is modal this should never happen during manual operation.
if all(ishghandle(objs))
    localRestoreCachedWidths(objs);
end

awtinvoke(dlg,'dispose()');

function localOK(~,~,dlg,okAction,objs)

% There have been cases in automated testing where the graphics objects
% were deleted by the time this callback fired (g576643). Test to make 
% sure that objects are all valid before updating the dialog. Since this 
% dialog is modal this should never happen during manual operation.
if ~all(ishghandle(objs))
    awtinvoke(dlg,'dispose()');
    return
end

varName = char(dlg.getVarName);
if isempty(varName) || ~isvarname(varName)
    javaMethodEDT('showMessageDialog','com.mathworks.mwswing.MJOptionPane',...
        dlg,getString(message('MATLAB:datamanager:newvardisambiguate:InvalidOrEmptyVariableName')), 'MATLAB',...
        javax.swing.JOptionPane.ERROR_MESSAGE);
    awtinvoke(dlg,'show()');
    return
end
localRestoreCachedWidths(objs);

pos = dlg.getSelectionIndex+1;
if pos>=1
    writeData = feval(okAction,objs(pos));
    if ~isempty(writeData)
        assignin('caller',varName,writeData)
    end
end
awtinvoke(dlg,'dispose()');

    
