function hupdatedata(h)
%HUPDATEDATA Update the data in FPT

%   Copyright 2011-2014 The MathWorks, Inc.

try
    %collect results, update ui and restore action state
    h.collectdata;
    locRestore(h);
    h.updateactions;
catch fpt_exception
    %restore actionstate and me.status and then let me know why we errored
    locRestore(h);
    %it would be nice if we had an assert keyword here
    rethrow(fpt_exception);
end

% [EOF]
