function registerUndoInsertAxes(hAxes)
% Utility function for undo insertion of an axes

if isempty(hAxes) || ~ishghandle(hAxes)
    return
end

container = ancestor(hAxes,{'figure','uipanel','uicontainer'});
proxyVal = plotedit({'getProxyValueFromHandle',hAxes});
serialized = getCopyStructureFromObject(hAxes);

vectorSerialized = getappdata(0,'ScribeAxesCopyBuffer');
id = length(vectorSerialized) + 1;

% add hAxes to the buffer 
setappdata(0,'ScribeAxesCopyBuffer',[vectorSerialized serialized]);

cmd.Name = 'Insertaxes';
cmd.Function = @localInsertAxes;
cmd.Varargin = {container,id};
cmd.InverseFunction = @localRemoveAxes;
cmd.InverseVarargin = {container,proxyVal,id};

hFig = ancestor(hAxes,'figure');
% Register with undo/redo
uiundo(hFig,'function',cmd);


function localRemoveAxes(container,proxyVal,id)
% CTRL+Z - serializes the axes before deleting. The most recent state of
% the axes is saved in ScribeAxesCopyBuffer .
hAxesVector = findall(container,'type','axes');
for i =1:length(hAxesVector)  
    if isequal(proxyVal, plotedit({'getProxyValueFromHandle',hAxesVector(i)}))        
        serialized = getCopyStructureFromObject(hAxesVector(i));
        vectorSerialized = getappdata(0,'ScribeAxesCopyBuffer');
        vectorSerialized(id) = serialized;        
        setappdata(0,'ScribeAxesCopyBuffer',vectorSerialized);
        delete (hAxesVector(i));
        break
    end
end
    

function localInsertAxes(container,id)     
%CTRL +Y - retrieves the axes with the specified id and adds to its
%contianer
if ~ishghandle(container)
    return
end

vectorSerialized = getappdata(0,'ScribeAxesCopyBuffer');   

hAx = getObjectFromCopyStructure(vectorSerialized(id));
hAx.Parent = container;
hFig = ancestor(container,'figure');

if isactiveuimode(hFig,'Standard.EditPlot')
    selectobject(hAx,'replace');
end
