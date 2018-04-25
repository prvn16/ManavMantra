function tNew = updateforreuse(tOld,tNew)
%UPDATEFORREUSE Mark that a new tall array should replace an old tall array
% marked for reuse.
%
%   tNew = MARKFORREUSE(tOld,tNew) marks that tNew should replace tOld in
%   all cache structures.

%   Copyright 2017 The MathWorks, Inc.

updateforreuse(hGetValueImpl(tOld), hGetValueImpl(tNew));
end