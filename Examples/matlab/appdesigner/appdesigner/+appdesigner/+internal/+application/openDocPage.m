function openDocPage(ref, anchor)
%OPENDOCPAGE Opens MATLAB documentation page

%   Copyright 2015-2016 The MathWorks, Inc.

if(nargin > 1)
    helpview(fullfile(docroot,'matlab', ref), anchor);
else
     helpview(fullfile(docroot,'matlab', ref));
end

