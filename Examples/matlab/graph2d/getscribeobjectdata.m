function od = getscribeobjectdata(co)
%GETSCRIBEOBJECTDATA  Return the scribe object data

%   Copyright 1984-2013 The MathWorks, Inc. 

od = [];
h = handle(co);

if isobject(h)
  if ~isempty(h.findprop('ScribeObjectData'))
    od = h.ScribeObjectData;
  end
else
  if isprop(h,'ScribeObjectData')
    od = h.ScribeObjectData;
  end
end
