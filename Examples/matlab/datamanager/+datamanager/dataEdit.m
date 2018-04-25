function dataEdit(hFig,~,gobj,action,newvalue,linkedvardata)
% This undocumented function may be removed in a future release.

% Copyright 2008-2015 The MathWorks, Inc.

% Function for replacing data in linked and unlinked graphics in linked and
% unlinked plots. Allows combined undo and redo operations when acting on
% multiple objects/variables. Functionality has been combined into a single
% function to avoid code duplication.

% Get the figure and the current parent object: axes if invoked from a
% context menu, otherwise figure

% Find replacement value/keep flag if none specified.  Use English for
% actionStr (it is only used for the undo/redo menu, and translation is
% performed when the undo/redo menu items are created)
if strcmp(action,'replace')
    if nargin==4 || (nargin > 4 && isempty(newvalue))
        newvalue = datamanager.replacedlg;
        if isempty(newvalue)
            return
        end
    end
    if isnan(newvalue)
        actionStr = 'Replace with NaNs';
    else
        actionStr = 'Replace with a constant';
    end
elseif strcmp(action,'remove')
    if nargin==3 || ~newvalue
        actionStr = 'Remove points';
        newvalue = false;
    else
        actionStr = 'Remove unbrushed points';
    end
end

% data for Linked Plot may be precalculated, if it exits use it.
varItems = [];
linkedDataExists = 1;
if (nargin >= 6)
    varItems = linkedvardata;
end

% if varItems, create a placeholder for the linked data 
if isempty(varItems)   
    varItems = repmat(struct('VarName','','VarValue',[],'BrushingArray',[]),[0 1]);
    linkedDataExists = 0;
end

% The first argument can be a handle to the figure menu, in this case we have to get the
% figure itself
hFig = ancestor(hFig,'figure');

% the function may be called from Java (LinkPlotPanel.fireFigureCallback),
% the caller passes figure handle as the first argument (hfig)

gContainer = [];

if ~isempty(gobj) && ~isa(gobj,'matlab.ui.Figure')
    gContainer = ancestor(gobj,'axes');
elseif ~isempty(hFig)  
    gContainer = hFig;
end

if isempty(gContainer)
    gContainer = ancestor(gobj,'figure'); 
end

% Find brushed graphics
sibs = datamanager.getAllBrushedObjects(gContainer);
fig = ancestor(gContainer,'figure');
if isempty(sibs)
    errordlg(getString(message('MATLAB:datamanager:dataEdit:AtLeastOneGraphicObjectMustBeBrushed')),'MATLAB','modal')
    return
end

% Build a list of effected items:
%  - Struct array varItems: representing linked variable data sources in 
%    linked plots
%  - Struct array graphicItems: representing graphics handles of unlinked
%    plots and graphics without data sources in linked plots

graphicItems = {};
IunlinkedGraphics = true(1,length(sibs));
if datamanager.isFigureLinked(fig)
    IunlinkedGraphics = false(1,length(sibs));
    for k=1:length(sibs)  
        
        if ~linkedDataExists
            h = datamanager.LinkplotManager.getInstance();
            brushMgr = datamanager.BrushManager.getInstance();
            [mfile,fcnname] = datamanager.getWorkspace(2);
            linkedVars = h.getLinkedVarsFromGraphic(sibs(k),mfile,fcnname,true);
            if ~isempty(linkedVars)
                for j=1:length(linkedVars)
                    varValue = evalin('caller',[linkedVars{j} ';']);
                    varStruct = struct('VarName',linkedVars{j},...
                        'VarValue',varValue,'BrushingArray',...
                        brushMgr.getBrushingProp(linkedVars{j},mfile,fcnname,'I'));
                    varItems = [varItems;varStruct]; %#ok<AGROW>
                end
            end
        end
        % Is there unlinked manual data
        if isempty(hggetbehavior(sibs(k),'linked','-peek'))
            isUnlinkedXData = isempty(get(sibs(k),'XDataSource')) && ...
                isprop(handle(sibs(k)),'XDataMode') && ...
                strcmp(get(sibs(k),'XDataMode'),'manual');
            isUnlinkedYData = isempty(get(sibs(k),'YDataSource')) && ...
                isprop(handle(sibs(k)),'YDataMode') && ...
                strcmp(get(sibs(k),'YDataMode'),'manual');
            isUnlinkedZData = ~isempty(findprop(handle(sibs(k)),'ZData')) && ...
                isprop(handle(sibs(k)),'ZDataSource') && ...
                isempty(get(sibs(k),'ZDataSource')) && ...
                isprop(handle(sibs(k)),'ZDataMode') && ...
                strcmp(get(sibs(k),'ZDataMode'),'manual');
        else
            isUnlinkedXData = false;
            isUnlinkedYData = false;
            isUnlinkedZData = false;
        end
        % Unlinked graphic or linked graphic with unlinked X/Y Data in manual
        % data mode => get the graphic
        if isempty(varItems) || isUnlinkedXData || isUnlinkedYData || ...
                isUnlinkedZData
            IunlinkedGraphics(k) = true;
        end
    end
end

% Serialize the state of unlinked graphics before the edit
graphicItemsBefore = {};
for k=1:length(IunlinkedGraphics)
    if IunlinkedGraphics(k)
        graphicItemsBefore = serializeGraphicData(sibs(k),graphicItemsBefore);
    end
end

% Execute the action for unlinked graphics or graphics with manually specifed data
if any(IunlinkedGraphics)
    for k=1:length(sibs)
        if IunlinkedGraphics(k)
            if strcmp(action,'replace')
                localReplace(sibs(k),newvalue);
            elseif strcmp(action,'remove')
                if ishghandle(sibs(k),'line') || ishghandle(sibs(k),'surface')
                    [~,pvPairs] = datamanager.createRemovedProperties(sibs(k),newvalue);
                    if ~isempty(pvPairs)
                        set(sibs(k),pvPairs{:});
                    end
                else
                    sibs(k).BrushHandles.remove(sibs(k),newvalue);
                end
            end
        end
    end
end

% Execute the action for linked graphics
executeLinkedAction(fig,varItems,action,newvalue)

% Serialize the state of unlinked graphics after the edit
graphicItemsAfter = {};
for k=1:length(IunlinkedGraphics)
    if IunlinkedGraphics(k)
        graphicItemsAfter = serializeGraphicData(sibs(k),graphicItemsAfter);
    end
end

% Update the figure undo stack
datamanager.updateFigUndoMenu(fig,actionStr,...
    @(fig,varItems,graphicItems,newvalue,action) localEditGraphic(fig,varItems,graphicItemsAfter,newvalue,action),...
    {fig,varItems,graphicItems,newvalue,action},...
    @(fig,varItems,graphicItems) localEditGraphicInv(fig,varItems,graphicItemsBefore),...
    {fig,varItems,graphicItems});

function localEditGraphic(fig,varItems,unlinkedGraphicItems,newvalue,action)

% Deal with unlinked graphics or graphics with manually specified data
for k=1:length(unlinkedGraphicItems)
    % Obtain the handles from the proxy objects
    h = plotedit({'getHandleFromProxyValue',fig,unlinkedGraphicItems{k}.ProxyVal});
    
    % Set the X/Y/ZData and BrushData
    if ishghandle(h,'line') || ishghandle(h,'surface')
        datamanager.deserializeBrushDataStruct(unlinkedGraphicItems{k},h);
    else
        unlinkedGraphicItems{k}.BrushHandleClass.deserializeBrushDataStruct(unlinkedGraphicItems{k},h);
    end
end

% Deal with variables from linked graphics
executeLinkedAction(fig,varItems,action,newvalue)

% Package inverse of replace as a local function handle for undo operations
function localEditGraphicInv(fig,varItems,unlinkedGraphicItems)

% Deal with unlinked graphics
for k=1:length(unlinkedGraphicItems)
    % Obtain the handles from the proxy objects
    h = plotedit({'getHandleFromProxyValue',fig,unlinkedGraphicItems{k}.ProxyVal});
      
    if ishghandle(h,'line') || ishghandle(h,'surface')
        datamanager.deserializeBrushDataStruct(unlinkedGraphicItems{k},h);
    else
        unlinkedGraphicItems{k}.BrushHandleClass.deserializeBrushDataStruct(unlinkedGraphicItems{k},h);
    end
end

% Deal with variables from linked graphics
if ~isempty(varItems)
    h = datamanager.BrushManager.getInstance();
    for k=1:length(varItems)
        h.UndoData.(strrep(varItems(k).VarName,'.','_')) = varItems(k).VarValue;
        h.UndoData.Brushing.(strrep(varItems(k).VarName,'.','_')) = varItems(k).BrushingArray;
    end
    cmd = 'datamanager.dataEditCallback({';
    for k=1:length(varItems)-1
        cmd = [cmd,'''' varItems(k).VarName ''',']; %#ok<AGROW>
    end 
    cmd = [cmd,'''' varItems(end).VarName '''},''action'',''undo'');'];
    h = datamanager.LinkplotManager.getInstance();
    h.LinkListener.executeFromDataSource(cmd,java(fig));
end 


function localReplace(h,newValue)

if ishghandle(h,'surface')
    if ~isvector(h.ZData)
        I = h.BrushData>0;
    else
        I = any(h.BrushData>0,1);
    end
    zdata = get(h,'ZData');
    zdata(I) = newValue;
    set(h,'ZData',zdata);
else
    I = any(h.BrushData>0,1);
    ydata = get(h,'YData');
    ydata(I) = newValue;
    set(h,'YData',ydata);
end
 
function graphicItems = serializeGraphicData(h,graphicItems)

if ishghandle(h,'line') || ishghandle(h,'surface')
    gStruct = datamanager.serializeBrushDataStruct(h);
else
    gStruct = h.BrushHandles.serializeBrushDataStruct(h);
end
graphicItems = [graphicItems;{gStruct}];

function executeLinkedAction(fig,varItems,action,newvalue)

% Deal with variables from linked graphics
if ~isempty(varItems)
    cmd = 'datamanager.dataEditCallback({';
    for k=1:length(varItems)-1        
        if  ~strcmpi(action,'remove') && ~isnumeric(varItems(k).VarValue)
            continue
        end        
        cmd = [cmd,'''' varItems(k).VarName ''',']; %#ok<AGROW>
    end
    cmd = [cmd,'''' varItems(end).VarName '''},''action'',''' action ''',''arguments'',{' num2str(newvalue,12) '});'];
    h = datamanager.LinkplotManager.getInstance();
    h.LinkListener.executeFromDataSource(cmd,java(fig));
end

