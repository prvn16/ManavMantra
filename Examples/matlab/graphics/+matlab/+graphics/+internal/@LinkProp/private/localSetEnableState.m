% Local functions called from processRemoveHandle()
%
function localSetEnableState(hList,newVal)

%   Copyright 2014-2015 The MathWorks, Inc.

if isa( hList, 'handle.listener' )
    hList.Enabled = newVal;
else
    hList.Enabled = strcmpi( newVal, 'on' );
end

end
