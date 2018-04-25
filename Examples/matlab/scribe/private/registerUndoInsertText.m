function registerUndoInsertText(hAxes,textType)
% Utility function for undo insertion of xlabel/ylabel/title

if isempty(hAxes) || ~ishghandle(hAxes)
    return
end

container = ancestor(hAxes,{'figure','uipanel','uicontainer'});
cmd.Name = strcat('Insert',textType);
cmd.Function = @localUndoRedoInsertText;
% store the proxy value to be robust to axes deletions
proxyVal = plotedit({'getProxyValueFromHandle',hAxes});

cmd.Varargin = {container,proxyVal,textType};
cmd.InverseFunction = @localUndoRedoInsertText;
cmd.InverseVarargin = {container,proxyVal,textType};

% Register with undo/redo
fig = ancestor(hAxes,'figure'); 
uiundo(fig,'function',cmd);


function localUndoRedoInsertText(container,proxyVal,textType)
% Undo/Redo for Insert xLabel,yLabel, title using the insert menu.

hAxesVector = findall(container,'type','axes');

for i = 1:length(hAxesVector)
    if isequal(proxyVal, plotedit({'getProxyValueFromHandle',hAxesVector(i)}))
        hAx = hAxesVector(i);
        break
    end
end

if ~ishghandle(hAx)
    return
end

textH = get(hAx,textType);

if ~ishghandle(textH) || strcmpi(textH.Editing,'on')
    return
end

%if the text object has a string, set its current string to empty, otherwise
%set the show its previous value 

if ~isempty(textH.String)
    setappdata(textH,'PrevString',textH.String);
    textH.String = '';
else
    textH.String = getappdata(textH,'PrevString');
end
