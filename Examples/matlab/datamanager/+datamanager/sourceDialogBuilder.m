function varList = sourceDialogBuilder(f,cmd,varargin)
% This internal helper function may be removed in a future release.

% Copyright 2007-2016 The MathWorks, Inc.

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;
import com.mathworks.page.plottool.plotbrowser.*;

datasrcPropNames = {'XDataSource','YDataSource','ZDataSource'};

if strcmp(cmd,'build')
    % Build the DataSourceDialog from MATLAB since we need info from the
    % figure graphics.
    
    % Build proxy objects for icon display
    varList = {};
    allProps = getplotbrowserproptable;
    [ls,dataSrcOptions] = localGetGraphics(f);
    gProxy = ChartObjectProxyFactory.createSeriesProxyArray(length(ls));
    
    for k=1:length(ls)
        gProxy(k) = ChartObjectProxyFactory.createHG2SeriesProxy(java(handle(ls(k))),...
            class(handle(ls(k))));
        I1 = find(cellfun(@(x) strcmp(class(ls(k)),x{1}),allProps));
        if ~isempty(I1)
            propNames = allProps{I1}{2};
            for j=1:length(propNames)
                ChartObjectProxyFactory.updateProperty(gProxy(k),propNames{j});
            end
        end
    end
    
    % Get list of current numeric/cell vars for display in combo-boxes. If
    % f is not a linked figure then this dialog is being opened to resolve
    % an ambiguous data source in the workspace when a figure is being
    % linked for the first time.
    if isLinked(f)
        varContents = evalin('caller','whos;');
        dataSourceTableData = datamanager.createLinkedVariablesTableData(varContents, ls); 
    else
        dataSourceTableData = DataSourceDialog.createSourceDialogTableEntryArray(length(ls),length(datasrcPropNames));
        for k=1:length(ls)
            gOptions = dataSrcOptions{k};
            for j=1:length(datasrcPropNames)
                if ~isempty(gOptions{j})
                    dataSourceTableData(k,j).setCurrentValue(gOptions{j}{1});
                    dataSourceTableData(k,j).addContent(gOptions{j});
                end
            end
        end
    end
    
    % Build or initialize the DataSourceDialog
    h = datamanager.LinkplotManager.getInstance();
    ind = localGetFigureIndex(f);
    if ~isLinked(f)
        dlg = awtcreate('com.mathworks.page.datamgr.linkedplots.DataSourceDialog',...
            'Ljava.lang.Object;Lcom.mathworks.hg.peer.FigurePeer;Ljava.lang.String;Ljava.lang.String;[Lcom.mathworks.page.plottool.plotbrowser.ChartObjectProxyFactory$SeriesProxy;[Ljava.lang.String;[[Lcom.mathworks.page.datamgr.linkedplots.DataSourceDialog$SourceDialogTableEntry;',...
            java(f),datamanager.getJavaFrame(f),getString(message('MATLAB:datamanager:sourceDialogBuilder:ResolveAmbiguity')),...
            getString(message('MATLAB:datamanager:sourceDialogBuilder:AmbiguousDataSourceVariableExpression')),...
            gProxy,get(ls,{'DisplayName'}),dataSourceTableData);
        dlg.setJavaNamesForTesting('DataSourceDialogDisambiguation');
        % Specify table row selection callback
        set(handle(dlg.getSelectionModel,'callbackproperties'),...
            'ValueChangedCallback',{@localSelectObj dlg ls});
        awtinvoke(dlg,'show()');
    else
        if isempty(h.Figures(ind).SourceDialog)
            h.Figures(ind).SourceDialog = awtcreate('com.mathworks.page.datamgr.linkedplots.DataSourceDialog',...
                'Ljava.lang.Object;Lcom.mathworks.hg.peer.FigurePeer;Ljava.lang.String;Ljava.lang.String;[Lcom.mathworks.page.plottool.plotbrowser.ChartObjectProxyFactory$SeriesProxy;[Ljava.lang.String;[[Lcom.mathworks.page.datamgr.linkedplots.DataSourceDialog$SourceDialogTableEntry;',...
                java(f),datamanager.getJavaFrame(f),getString(message('MATLAB:datamanager:sourceDialogBuilder:SpecifyDataSourceProperties')),...
                getString(message('MATLAB:datamanager:sourceDialogBuilder:SpecifyGraphicsDataSource')),...
                gProxy,get(ls,{'DisplayName'}),dataSourceTableData);
            dlg = h.Figures(ind).SourceDialog;
            dlg.setJavaNamesForTesting('DataSourceDialog');
            % Specify table row selection callback
            set(handle(dlg.getSelectionModel,'callbackproperties'),...
                'ValueChangedCallback',{@localSelectObj dlg ls});
            awtinvoke(dlg,'show()');
        else
            % Specify table row selection callback in case graphic objects have
            % changed
            dlg = h.Figures(ind).SourceDialog;
            set(handle(dlg.getSelectionModel,'callbackproperties'),...
                'ValueChangedCallback',{@localSelectObj dlg ls});
            dlg.initialize(gProxy,get(ls,{'DisplayName'}),dataSourceTableData);
        end
    end
    if nargin>=3
        setappdata(dlg,'OKCallback',varargin{1});
    end
    if nargin>=4
        setappdata(dlg,'CancelCallback',varargin{2});
    end
elseif strcmp(cmd,'edit') % Callback for editing table cells in col>=3
    % Verify edited cell and return varList null if error or the DisplayName
    % otherwise.
    
    % Get params
    row = double(varargin{1})+1;
    col = double(varargin{2})+1;
    dlg = varargin{4};
    newValue = varargin{3};
    tableData = cell(dlg.getTableData);
    oldValue = tableData{row,col};
    gObjs = localGetGraphics(f);
    
    %get the right graphics object for the current row
    gObjRow = gObjs(row);
    
    % Test to see if the new edited value is a MATLAB vector. If so,
    % find the DisplayName
    varList = [];
    if ~isempty(newValue)
        try
            x = evalin('caller',newValue);
            if col<=4
                if ishghandle(gObjRow,'surface') && (~isDataStyleArrray(x) || ~ismatrix(x))
                    return;
                elseif ~ishghandle(gObjRow,'surface') && (~isDataStyleArrray(x) || ~ismatrix(x))
                    return;
                end
            elseif col==5 && ((~isDataStyleArrray(x)) || ~ismatrix(x))
                return;
            end
        catch
            return
        end
        
        % If the DisplayName is equal to the previous default or is empty
        % then recalculate it based on the newly edited DataSource
        tableData{row,col} = newValue;
        if col==3
            defaultDispName = localGetDefaultDisplayName(tableData{row,5},tableData{row,4},oldValue);
        elseif col==4
            defaultDispName = localGetDefaultDisplayName(tableData{row,5},oldValue,tableData{row,3});
        elseif col==5
            defaultDispName = localGetDefaultDisplayName(oldValue,tableData{row,4},tableData{row,3});
        end
        if isempty(tableData{row,2}) || strcmp(tableData{row,2},defaultDispName)
            varList = localGetDefaultDisplayName(tableData{row,5},tableData{row,4},tableData{row,3});
        else % Just use the old value since it was edited by the user.
            varList = tableData{row,2};
        end
    end
elseif strcmp(cmd,'ok')
    dlg = varargin{1};
    linkmgr = datamanager.LinkplotManager.getInstance();
    ls = localGetGraphics(f);
    
    tableData = cell(dlg.getTableData);
    for k=1:length(ls)
        allProps = [{'DisplayName'},datasrcPropNames];
        datasrcVals = {tableData{k,2},tableData{k,3},tableData{k,4},tableData{k,5}};
        Iprops = false(size(datasrcVals));
        for j = 1:length(allProps)
            Iprops(j) = ~isempty(ls(k).findprop(allProps{j}));
        end
        I = cellfun('isclass',datasrcVals,'char') & Iprops;
        % Special handling for linked behavior objects
        if ~isempty(hggetbehavior(ls(k),'linked','-peek'))
            if ischar(tableData{k,2})
                set(ls(k),'DisplayName',tableData{k,2});
            end
            linkBehavior = hggetbehavior(ls(k),'linked');
            datalen = sum([linkBehavior.UsesXDataSource linkBehavior.UsesYDataSource linkBehavior.UsesZDataSource]);
            data = cell(1,datalen);
            count = 1;
            if linkBehavior.UsesXDataSource
                try %#ok<TRYNC>
                    data{count} = evalin('caller',tableData{k,3});
                end
                set(linkBehavior,'XDataSource',strtrim(tableData{k,3}));
                count = count+1;
            end
            if linkBehavior.UsesYDataSource
                try %#ok<TRYNC>
                    data{count} = evalin('caller',tableData{k,4});
                end
                set(linkBehavior,'YDataSource',strtrim(tableData{k,4}));
                count = count+1;
            end
            if linkBehavior.UsesZDataSource
                try %#ok<TRYNC>
                    data{count} = evalin('caller',tableData{k,5});
                end
                set(linkBehavior,'ZDataSource',strtrim(tableData{k,5}));
            end
            
            try %#ok<TRYNC>
                feval(linkBehavior.DataSourceFcn{1},ls(k),...
                    data,linkBehavior.DataSourceFcn{2:end});
            end
        else
            set(ls(k),allProps(I),strtrim(datasrcVals(I)));
        end
    end
    
    % Update live plot
    if isLinked(f)
        linkmgr.updateLinkedGraphics(f);
        linkmgr.createlinkpanel(handle(ancestor(ls(1),'figure')));
        linkmgr.LinkListener.postRefresh({f','clearUndo','redrawBrushing'});
    else
        for k=1:length(ls)
            if isappdata(double(ls(k)),'XDataSourceOptions')
                rmappdata(double(ls(k)),'XDataSourceOptions')
            end
            if isappdata(double(ls(k)),'YDataSourceOptions')
                rmappdata(double(ls(k)),'YDataSourceOptions')
            end
            if isappdata(double(ls(k)),'ZDataSourceOptions')
                rmappdata(double(ls(k)),'ZDataSourceOptions')
            end
        end
        okCallback = getappdata(dlg,'OKCallback');
        if length(okCallback)>=2
            feval(okCallback{1},okCallback{2:end});
        end
    end
    % Restore cached line widths
    localRestoreCachedWidths(ls)
elseif strcmp(cmd,'cancel')
    % Restore cached line widths
    localRestoreCachedWidths(localGetGraphics(f));
    dlg = varargin{1};
    cancelAction = getappdata(dlg,'CancelCallback');
    if ~isempty(cancelAction)
        feval(cancelAction{1},cancelAction{2:end});
    end
end

function localSelectObj(es,ed,dlg,ls) %#ok<INUSL>

pos = es.getMinSelectionIndex+1;

% Restore cached widths
localRestoreCachedWidths(ls)
if pos>=1
    if isprop(ls,'LineWidth')
        lw = get(ls(pos),'LineWidth');
        setappdata(ls(pos),'CacheWidth',lw);
        set(ls(pos),'LineWidth',lw*3);
    end
end


function localRestoreCachedWidths(ls)

for k=1:length(ls)
    cacheWidth = getappdata(ls(k),'CacheWidth');
    if ~isempty(cacheWidth )
        set(ls(k),'LineWidth',cacheWidth);
    end
end


function defaultName = localGetDefaultDisplayName(zDataSrc,yDataSrc,xDataSrc)

defaultName = zDataSrc;
if ~isempty(defaultName) && ~isempty(yDataSrc)
    defaultName = [defaultName getString(message('MATLAB:datamanager:sourceDialogBuilder:Vs'))  yDataSrc];
elseif isempty(defaultName)
    defaultName = yDataSrc;
end
if ~isempty(defaultName) && ~isempty(xDataSrc)
    defaultName = [defaultName getString(message('MATLAB:datamanager:sourceDialogBuilder:Vs'))  xDataSrc];
elseif isempty(defaultName)
    defaultName = xDataSrc;
end


function [gObj,dataSrcOptions] = localGetGraphics(f)

[gObj_series, gObj_custom] = datamanager.findLinkedGraphics(f);
if isempty(gObj_custom)
    gObj = handle(gObj_series(:));
elseif isempty(gObj_series)
    gObj = handle(gObj_custom(:));
else
    gObj = handle([gObj_custom(:);gObj_series(:)]);
end
dataSrcOptions = {length(gObj),1};
if isLinked(f)
    return
end

% If we are unlinked then we are resolving data sources screen out
% unambiguous graphics
I = false(length(gObj),1);
for k=1:length(gObj)
    XSrcs = getappdata(double(gObj(k)),'XDataSourceOptions');
    YSrcs = getappdata(double(gObj(k)),'YDataSourceOptions');
    ZSrcs = getappdata(double(gObj(k)),'ZDataSourceOptions');
    I(k) = ~isempty(XSrcs) || ~isempty(YSrcs) || ~isempty(ZSrcs);
    dataSrcOptions{k} = {XSrcs,YSrcs,ZSrcs};
end
gObj = gObj(I);
dataSrcOptions = dataSrcOptions(I);


function I = localGetFigureIndex(f)

I = [];
linkmgr = datamanager.LinkplotManager.getInstance();
if isempty(linkmgr.Figures)
    return
end
I = find([linkmgr.Figures.('Figure')]==f);

function status = isLinked(f)

fH = handle(f);
status = false;
if isempty(fH.findprop('LinkPlot'))
    return
end
status = fH.LinkPlot;

function status = isDataStyleArrray(data)

status = isnumeric(data) || ...
    any(strcmp(class(data),{'datetime','calendarduration','duration','categorical'}));
    
