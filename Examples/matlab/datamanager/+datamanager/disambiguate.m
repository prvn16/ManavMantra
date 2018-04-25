function disambiguate(objs,okAction)

% Utility method for brushing/linked plots. May change in a future release.

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
%     tableData(k,2) = java.lang.String(sprintf(getString(message('MATLAB:datamanager:disambiguate:NumberInteger',...
%         sum(bData(:)))),length(get(objs(k),'xdata'))));
    tableData(k,2) = java.lang.String(getString(message('MATLAB:datamanager:disambiguate:NumberInteger',...
        sum(bData(:)),length(get(objs(k),'xdata')))));
    tableData(k,3) = java.lang.String(get(objs(k),'Type'));
    tableData(k,4) = java.lang.String(get(objs(k),'Tag'));
end

% Build and show Disambiguation dialog
dlg = javaObjectEDT('com.mathworks.page.datamgr.brushing.DisambiguationDialog',...
    datamanager.getJavaFrame(ancestor(objs(1),'figure')),tableData,gProxy,...
    {' ',getString(message('MATLAB:datamanager:disambiguate:NumberOfBrushedPoints')),'Type','Tag'});


set(ancestor(objs(1),'figure'),'userdata',dlg)

% Specify callbacks
set(handle(dlg.getSelectionModel,'callbackproperties'),...
        'ValueChangedCallback',{@localSelectObj objs});
set(handle(dlg.getCancelButton,'callbackproperties'),...
        'ActionPerformedCallback',{@localCancel dlg objs});
set(handle(dlg.getOKButton,'callbackproperties'),...
        'ActionPerformedCallback',{@localOK dlg objs});
   
setappdata(dlg,'okAction',okAction);
javaMethodEDT('show',dlg);
% Make sure the dialog is fully ready before interacting with it. We don't
% want callbacks executing before all java classes are fully initialized.
drawnow 

function localSelectObj(es,ed,objs) %#ok<INUSL>

% Row selection callback

pos = es.getMinSelectionIndex+1;

% Restore cached widths
localRestoreCachedWidths(objs)
if pos>=1
    lw = get(objs(pos),'LineWidth');
    setappdata(objs(pos),'CacheWidth',lw);
    set(objs(pos),'LineWidth',lw*3);
end


function localRestoreCachedWidths(ls)

% Restore emphasis line widths to original values on close.
for k=1:length(ls)
    cacheWidth = getappdata(ls(k),'CacheWidth');
    if ~isempty(cacheWidth )
        set(ls(k),'LineWidth',cacheWidth);
    end
end

function localCancel(es,ed,dlg,objs) %#ok<INUSL>

localRestoreCachedWidths(objs);
javaMethodEDT('dispose',dlg);

function localOK(es,ed,dlg,objs) %#ok<INUSL>

localRestoreCachedWidths(objs);
javaMethodEDT('dispose',dlg);

pos = dlg.getSelectionIndex+1;
if pos>=1
    okFcn = getappdata(dlg,'okAction');
    feval(okFcn{1},okFcn{2:end},objs(pos));
end


    
