% Local functions called from processRemoveHandle()
%
function localDeleteListeners(hList)

%   Copyright 2014-2015 The MathWorks, Inc.

for i = 1:numel( hList )
    delete( hList{ i } );
end

end
