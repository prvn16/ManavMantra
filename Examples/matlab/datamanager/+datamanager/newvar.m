function newvar(es,~) 

% Creates a new variable from brushed graphics

% Get the host axes/figure

% Copyright 2007-2014 The MathWorks, Inc.

fig = ancestor(es,'figure');
gContainer = fig;
if ~isempty(es) && ~isempty(ancestor(es,'uicontextmenu'))
    gContainer = get(fig,'CurrentAxes');
    if isempty(gContainer)
        gContainer = fig;
    end
end

% Record the variable names in the calling workspace so that they can be
% used to populate the new variable creation MJCombobox in the
% disambiguation dialogs.
callerWho = evalin('caller','who');

if datamanager.isFigureLinked(fig)
     h = datamanager.LinkplotManager.getInstance();
     [mfile,fcnname] = datamanager.getWorkspace(1);
     [linkedVarList,linkedGraphics] = h.getLinkedVarsFromGraphic(...
         gContainer,mfile,fcnname);
     allBrushable = datamanager.getAllBrushedObjects(gContainer);
     unlinkedGraphics = setdiff(allBrushable,linkedGraphics);
     if ~isempty(linkedVarList) && ~isempty(unlinkedGraphics)
         msg = getString(message('MATLAB:datamanager:newvar:NoVariableFromCombinationGraphics'));
         ButtonName = questdlg(msg, ...
                         getString(message('MATLAB:datamanager:newvar:MATLAB')), ...
                         getString(message('MATLAB:datamanager:newvar:Linked')),getString(message('MATLAB:datamanager:newvar:Unlinked')),getString(message('MATLAB:datamanager:newvar:Abort')),getString(message('MATLAB:datamanager:newvar:Abort')));
         if isempty(ButtonName) ||  strcmp(ButtonName,getString(message('MATLAB:datamanager:newvar:Abort')))
             return
         elseif strcmp(ButtonName,getString(message('MATLAB:datamanager:newvar:Unlinked')))
              openCreateVarDialog(unlinkedGraphics,callerWho);
             return
         end
     elseif ~isempty(unlinkedGraphics)
         openCreateVarDialog(unlinkedGraphics,callerWho);
         return
     end    
     
    cachedVarValues = cell(length(linkedVarList),1);
    for k=1:length(cachedVarValues)
         cachedVarValues{k} = evalin('caller',[linkedVarList{k} ';']);
    end
    datamanager.newvardisambiguateVariables(fig,linkedVarList,cachedVarValues,mfile,fcnname,...
        @localMultiVarCallback,callerWho);
else   
    localNewVarUnlinked(gContainer,callerWho);
end

function localNewVarUnlinked(gContainer,callerWho)

sibs = datamanager.getAllBrushedObjects(gContainer);
if isempty(sibs)
    errordlg(getString(message('MATLAB:datamanager:newvar:AtLeastOneGraphicObjectMustBeBrushed')),'MATLAB','modal')
else
   openCreateVarDialog(sibs,callerWho);
end


function openCreateVarDialog(sibs,callerWho)
datamanager.newvardisambiguate(handle(sibs),@localMultiObjCallback,callerWho);


    
function outData = localMultiObjCallback(gobj)
outData = brushing.select.getArraySelection(gobj);


function outData = localMultiVarCallback(varName,varValue,mfile,fcnname)

brushMgr = datamanager.BrushManager.getInstance();
I = brushMgr.getBrushingProp(varName,mfile,fcnname,'I');
if isvector(varValue)
    outData = varValue(I);
else
    outData = varValue(any(I,2),:);
end
       


