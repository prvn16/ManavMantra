function B = validatehandles(B)
%VALIDATEHANDLES  prune invalid scribehandle items from a list

%   Copyright 1984-2008 The MathWorks, Inc. 

if ~isempty(B)
   %HGHandles = B.HGHandle;
   HGHandles = subsref(B,substruct('.','HGHandle'));
   if iscell(HGHandles)
      HGHandles = [HGHandles{:}];
   end
   B = B(ishghandle(HGHandles));            
end
