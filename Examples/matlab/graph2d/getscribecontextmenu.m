function hCM = getscribecontextmenu(h)
%GETSCRIBECONTEXTMENU  Get the scribe uicontextmenu object

%   Copyright 1984-2013 The MathWorks, Inc. 

hCM = [];

if isobject(h)
  if isprop(h,'ScribeUIContextMenu')
    hCM = get(handle(h), 'ScribeUIContextMenu');
  end
else
  if ~isempty(findprop(handle(h), 'ScribeUIContextMenu'))
    hCM = get(handle(h), 'ScribeUIContextMenu');
  end
end
