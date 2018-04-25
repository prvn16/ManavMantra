% Local functions called from processRemoveHandle()
%
function localSetAllEnableState(hList,newVal)

%   Copyright 2014-2015 The MathWorks, Inc.

if ~isa( hList{ 1 }, 'handle.listener' )
    newVal = strcmpi( newVal, 'on' );
end
for k = 1:numel( hList )
    hList{ k }.Enabled = newVal;
end

end
