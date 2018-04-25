function varargout = islegendon(HG)
%AXISOBJ/PRIVATE/ISLEGENDON

%   Copyright 1984-2002 The MathWorks, Inc. 

legendHandles = get(HG,'Legend');
legendInfoStructs = get(legendHandles,'UserData');

iMatch = [];
switch length(legendInfoStructs)
case 0
   legendExists = 0;
case 1
   legendExists = (HG==legendInfoStructs.PlotHandle);
   iMatch = 1;
otherwise
   legendExists = 0;
   for i = 1:length(legendInfoStructs)
      if (HG==legendInfoStructs{i}.PlotHandle)
         legendExists = 1;
         iMatch = i;
      end
   end
end

if legendExists
   % may be hidden
   legendExists = strcmp(get(legendHandles(iMatch),'Visible'),'on');
end

varargout{1} = legendExists;
if nargout == 2
   varargout{2} = legendHandles(iMatch);
end