function processReset(hLink,obj,~)
%   Copyright 2014 The MathWorks, Inc.

% process all the objects cleaned in this update and see if any of our
% linked properties need propagating
hlist = hLink.Targets;
localForeachProp( hLink, hlist, @(hlist,prop,ind,n) localGetValues( { obj }, prop, ind, hlist, n, hLink ) );
localForeachProp( hLink, hlist, @(hlist,prop,ind,n) localSetValues( { obj }, prop, ind, hlist, n, hLink ) );
end
