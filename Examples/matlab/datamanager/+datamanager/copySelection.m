function copySelection(es,ed) %#ok<INUSD>

% Copyright 2007-2014 The MathWorks, Inc.

fig = ancestor(es,'figure');
gContainer = fig;
if ~isempty(es) && ~isempty(ancestor(es,'uicontextmenu'))
    gContainer = get(fig,'CurrentAxes');
    if isempty(gContainer)
        gContainer = fig;
    end  
end


if datamanager.isFigureLinked(fig)
     h = datamanager.LinkplotManager.getInstance();
     [mfile,fcnname] = datamanager.getWorkspace(1);
     [linkedVarList,linkedGraphics] = h.getLinkedVarsFromGraphic(...
         gContainer,mfile,fcnname);
     allBrushable = findobj(gContainer,'-function',...
         @(x) isprop(x,'BrushData') && ~isempty(get(x,'BrushData')) && ...
         any(x.BrushData(:)>0), 'HandleVisibility','on');
     allBrushable= findobj(allBrushable,'flat','-function',...
          @(x) ~isempty(get(x,'BrushData')) && any(x.BrushData(:)>0));
     unlinkedGraphics = setdiff(allBrushable,linkedGraphics);
     if ~isempty(linkedVarList) && ~isempty(unlinkedGraphics)
         msg = getString(message('MATLAB:datamanager:copySelection:LinkedUnlinkedNoCopy'));
         ButtonName = questdlg(msg, ...
                         getString(message('MATLAB:datamanager:copySelection:MATLAB')), ...
                         getString(message('MATLAB:datamanager:copySelection:Linked')),getString(message('MATLAB:datamanager:copySelection:Unlinked')),getString(message('MATLAB:datamanager:copySelection:Abort')),getString(message('MATLAB:datamanager:copySelection:Abort')));
         if isempty(ButtonName) ||  strcmp(ButtonName,getString(message('MATLAB:datamanager:copySelection:Abort')))
             return
         elseif strcmp(ButtonName,getString(message('MATLAB:datamanager:copySelection:Unlinked')))
             datamanager.copyUnlinked(unlinkedGraphics);
             return
         end
     elseif ~isempty(unlinkedGraphics)
         datamanager.copyUnlinked(unlinkedGraphics);
         return
     end
                     
     cachedVarValues = cell(length(linkedVarList),1);
     for k=1:length(cachedVarValues)
         cachedVarValues{k} = evalin('caller',[linkedVarList{k} ';']);
     end    
     datamanager.copyLinked(fig,linkedVarList,cachedVarValues,mfile,fcnname);
else
     datamanager.copyUnlinked(gContainer);
end
