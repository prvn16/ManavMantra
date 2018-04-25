function h = datachildren(parent)
%DATACHILDREN Handles to figure children that contain data.
%    H = DATACHILDREN(FIG) returns the children in the figure
%    that contain data and are suitable for manipulation via
%    functions like ROTATE3D and ZOOM.
%
%    This is a helper function for ROTATE3D and ZOOM.

%    Copyright 1984-2016 The MathWorks, Inc. 

% Current implementation:
%    Figure children that have an application data property
%    called 'NonDataObject' are excluded.

h = findobj(parent,'-regexp','Type','.*axes');
nondatachild = logical([]);
for i=length(h):-1:1
  nondatachild(i) = isappdata(h(i),'NonDataObject');
end
h(nondatachild) = [];
