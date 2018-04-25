function binObj = notify(binObj, caller, prop, value)
%HGOBJ/NOTIFY Notify method for hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

otherItems = binObj.Items; 
otherItems = otherItems(otherItems~=caller);

switch prop
case 'position'
case 'doclick'
   if strcmp(value,'normal')
	  if ~isempty(otherItems)
         otherItems.IsSelected = 0;
	  end
   end
end

