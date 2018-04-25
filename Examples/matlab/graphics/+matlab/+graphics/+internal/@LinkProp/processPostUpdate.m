function processPostUpdate(hLink,~,~)
%   Copyright 2014 The MathWorks, Inc.

% process all the objects cleaned in this update and see if any of our
% linked properties need propagating
cleaned = hLink.CleanedTargets;
if ~isempty( cleaned )
    hLink.CleanedTargets = {  };
    hlist = hLink.Targets;
    propnames = hLink.PropertyNames;
    valid = hLink.ValidProperties;
    for n = 1:length( propnames )
        prop = propnames{ n };
        ind = find( valid( :, n ) );
        if length( ind )>1
            localGetValues( cleaned, prop, ind, hlist, n, hLink );
            localSetValues( cleaned, prop, ind, hlist, n, hLink );
        end
    end
end
end
