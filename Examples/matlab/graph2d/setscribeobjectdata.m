function setscribeobjectdata(co, od)
%SETSCRIBEOBJECTDATA  Set the scribe object data

%   Copyright 1984-2013 The MathWorks, Inc. 

h = handle(co);
if isobject(h)
  if ~isprop(h,'ScribeObjectData')
    p = addprop(h,'ScribeObjectData');
    p.Transient = true;
  end
else
  if isempty(h.findprop('ScribeObjectData'))
    p = schema.prop(h, 'ScribeObjectData','MATLAB array');
    p.AccessFlags.Serialize = 'off';
  end
end

h.ScribeObjectData = od;

