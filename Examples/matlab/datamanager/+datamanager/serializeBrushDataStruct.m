function gStruct = serializeBrushDataStruct(gobj)
% This undocumented function may be removed in a future release.

% Serialize the data properties of a scattergroup so that data editing
% operations such as removing brushed data can be undone.

% Copyright 2016 The MathWorks, Inc.

% Serialize a structure representing the graphic object data which is
% modified when taking action on brushed data. Some graphic
% objects, such as scatter, may need to add additional properties
% to this structure, e.g., SizeData and CData properties
if nargin==0 || isempty(gobj)
    gStruct = repmat(struct('ProxyVal','','Xdata',[],'Ydata',[],...
        'Zdata',[],'BrushingArray',[]),[0 1]);
elseif ~isprop(handle(gobj),'ZData') || isempty(get(gobj,'ZData'))
    gStruct = struct('ProxyVal',plotedit({'getProxyValueFromHandle',gobj}),...
        'Xdata',get(gobj,'XData'),...
        'Ydata',get(gobj,'YData'),'Zdata',[],...
        'BrushingArray',get(gobj,'BrushData'));
else
    gStruct = struct('ProxyVal',plotedit({'getProxyValueFromHandle',gobj}),...
        'Xdata',get(gobj,'XData'),...
        'Ydata',get(gobj,'YData'),'Zdata',get(gobj,'ZData'),...
        'BrushingArray',get(gobj,'BrushData'));
end


if isprop(gobj,'MarkerIndices') && strcmpi(get(gobj,'MarkerIndicesMode'),'manual')
   gStruct.MarkerIndices = get(gobj,'MarkerIndices');
   gStruct.Marker = get(gobj,'Marker');
end

gStruct.BrushHandleClass = gobj.BrushHandles.empty;