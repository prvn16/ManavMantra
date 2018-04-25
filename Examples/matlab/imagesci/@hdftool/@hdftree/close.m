function close(this)
%CLOSE A destruction method for the hdfTree class.
%
%   Function arguments
%   ------------------
%   THIS: the hdfTree object instance.

%   Copyright 2005-2013 The MathWorks, Inc.

    % Close any HDF panels.
    staticPanels = {'staticGridPanel' 'staticRasterPanel' 'staticSdsPanel' ...
        'staticSwathPanel' 'staticVdataPanel' 'staticPointPanel'};
    for i=1:length(staticPanels)
        if ishghandle(this.(staticPanels{i}))
            delete(this.(staticPanels{i}));
        end
    end
    delete(this);
end
