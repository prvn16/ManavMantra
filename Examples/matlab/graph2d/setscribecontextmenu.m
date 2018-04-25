function setscribecontextmenu(h, hCM)
%SETSCRIBECONTEXTMENU  Set the scribe uicontextmenu object

%   Copyright 1984-2013 The MathWorks, Inc. 


if isobject(h)
  if ~isprop(h,'ScribeUIContextMenu')
    p = addprop(h,'ScribeUIContextMenu');
    p.Transient = true;
  end
else
  if isempty(findprop(handle(h), 'ScribeUIContextMenu'))
    p = schema.prop(handle(h), 'ScribeUIContextMenu','MATLAB array');
    p.AccessFlags.Serialize = 'off';
  end
end

set(handle(h), 'ScribeUIContextMenu', hCM);

