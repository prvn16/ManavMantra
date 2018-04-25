function deletePostShowListener(h)
%DELETEPOSTSHOWLISTENER Delete listener to 'MEPostShow'

%   Copyright 2012 MathWorks, Inc.

for i = 1:length(h.listeners)
    if strcmpi(h.listeners(i).EventType,'MEPostShow')
        delete(h.listeners(i));
        h.listeners(i) = [];
        break;
    end
end

% [EOF]
