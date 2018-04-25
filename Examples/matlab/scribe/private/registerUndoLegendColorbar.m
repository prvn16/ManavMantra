function registerUndoLegendColorbar(obj)
%Utility function for undo of insertion of legend/colorbar

if isempty(obj) || ~ishghandle(obj)
    return
end

if ishghandle(obj,'legend') || ishghandle(obj,'colorbar')
    
    type = obj.Type;
    hAx = obj.Axes;
   
    proxyVal = plotedit({'getProxyValueFromHandle',hAx});
    fig = ancestor(obj,'figure');
    
    % Create command structure
    cmd.Name = ['Insert',type];
    
    cmd.Function = @localUndoRedoLegendColorbar;
    cmd.Varargin = {fig,proxyVal,type};
    cmd.InverseFunction = @localUndoRedoLegendColorbar;
    cmd.InverseVarargin = {fig,proxyVal,type};
    % Register with undo/redo
    
    uiundo(fig,'function',cmd);
end


function localUndoRedoLegendColorbar(fig,proxyVal,type)

hAxesVector = findall(fig,'type','axes');

for i =1:length(hAxesVector)
    if isequal(proxyVal, plotedit({'getProxyValueFromHandle',hAxesVector(i)}))
        hAx = hAxesVector(i);
        break
    end
end

obj = find_legend_colorbar(hAx,type);

if ~isempty(obj) && ishghandle(obj) && ~strcmpi(get(obj,'beingdeleted'),'on')
    delete(obj);
else
    if strcmpi(type,'legend')
        legend(hAx,'show');
    elseif strcmpi(type,'colorbar')
        colorbar(hAx);
    end   
end


%----------------------------------------------------%
function obj = find_legend_colorbar(hAx,type)

% find the legend/colorbar peered to hAx

if isempty(hAx) || ~ishghandle(hAx)
    return
end

if strcmpi(type,'colorbar')
    obj = hAx.Colorbar;
elseif strcmpi(type,'legend')
    obj = hAx.Legend;
end