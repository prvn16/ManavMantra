function scribeGrid = getScribeGrid(hCamera,peekflag)
% Given a camera, return a scribe grid object. If peekflag is the string 
% '-peek' then no ScribeGrid will be created.

%   Copyright 2010 The MathWorks, Inc.

% First, check for an existing grid.
scribeGrid = findobj(hCamera,'-class','matlab.graphics.shape.internal.ScribeGrid');
if (nargin<=1 || ~strcmpi(peekflag,'-peek')) && isempty(scribeGrid)
    scribeGrid = matlab.graphics.shape.internal.ScribeGrid('Parent',hCamera);
end