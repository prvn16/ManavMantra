function updateVars(h,whosStruct,mfilename,fcnname)

% Copyright 2008-2016 The MathWorks, Inc.

% Updates the brushmanager SelectionTable in response to workspace variable
% changes

Inumeric = cellfun(@(x) prod(x)>1,{whosStruct.size}) & ...
        (strcmp({whosStruct.class},'double') | ...
         strcmp({whosStruct.class},'single') | ...
         strcmp({whosStruct.class},'uint8') | ...
         strcmp({whosStruct.class},'uint16') | ...
         strcmp({whosStruct.class},'uint32') | ...
         strcmp({whosStruct.class},'uint64') | ...
         strcmp({whosStruct.class},'int8') | ...
         strcmp({whosStruct.class},'int16') | ...
         strcmp({whosStruct.class},'int32') | ...
         strcmp({whosStruct.class},'int64'));
Istruct = strcmp({whosStruct.class},'struct') | strcmp({whosStruct.class},'timeseries');
Idatetime = strcmp({whosStruct.class},'datetime') | strcmp({whosStruct.class},'duration');

I = Inumeric | Istruct | Idatetime;
whosStruct = whosStruct(I);
[brushVarNames,brushInd] = h.getVarNames(mfilename,fcnname);

% Remove any cleared variables
areVariablesCleared = false;
deletedVars = setdiff(brushVarNames,{whosStruct.name});
for k=1:length(deletedVars)
    dotPos = strfind(deletedVars{k},'.');
    % Members of structs (or timeseries) like s.data have not been cleared
    % unless the parent struct or timeseries has been cleared.
    if ~isempty(dotPos) && ismember(deletedVars{k}(1:dotPos(1)-1),{whosStruct.name})
        continue;
    end
    h.removeVar(deletedVars{k},mfilename,fcnname);
    areVariablesCleared = true;
end

% Clear brushing for variables with out of band size changes
wsVarNames = {whosStruct.name};
for k=1:length(brushInd)
    I = find(strcmp(brushVarNames{k},wsVarNames));
    if ~isempty(I) && ~isequal(size(h.SelectionTable(brushInd(k)).I),...
            whosStruct(I(1)).size)
        h.SelectionTable(brushInd(k)).I = false(whosStruct(I(1)).size);
        h.draw(h.VariableNames{brushInd(k)},mfilename,fcnname);
    end
end

% Add entries for all variables currently displayed in linked plots. This
% is needed because otherwise an attempt to brush a linked graphic for the
% first time would result in there being no corresponding entry in the 
% brushmanager selection table and no way to create one because we cannot
% know the workspace variable size during the brushing operation.
linkMgr = datamanager.LinkplotManager.getInstance();
if areVariablesCleared % If necessary recompute brushVarNames 
    brushVarNames = h.getVarNames(mfilename,fcnname);
end
if ~isempty(linkMgr.Figures)
    linkVarTempArray = {linkMgr.Figures.VarNames};
    linkVarArray = {};
    for k=1:length(linkVarTempArray)
        linkVarCell = linkVarTempArray{k}(:);
        linkVarArray = [linkVarArray(:);linkVarCell(~cellfun('isempty',linkVarCell))];
    end
    [linkVarArray,wsInd] = intersect({whosStruct.name},linkVarArray);
    linkedUnbrushedVars = setdiff(linkVarArray,brushVarNames);
    for k=1:length(linkedUnbrushedVars)
        h.setBrushingProp(linkedUnbrushedVars{k},mfilename,fcnname,'I',false(whosStruct(wsInd(k)).size));
    end
end 





