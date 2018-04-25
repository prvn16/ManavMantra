function figureToolbarCreateFcn(tb,eventData) %#ok<INUSD>

% Callback function called on creation of a toolbar from the default figure.

%   Copyright 2008-2009 The MathWorks, Inc.

% This function is a no-op in >=R2009b. It was used to create a listener
% which displayed the linked plot and data brushing info bar. It is
% retained so as not to produce an error when loading figure files from
% previous version.