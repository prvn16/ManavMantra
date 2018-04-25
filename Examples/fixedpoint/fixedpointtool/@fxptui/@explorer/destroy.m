function destroy(h)
% DESTROY Delete callback for FPT

% Copyright 2014 The MathWorks, Inc.

% remove the post hide listener to prevent multiple calls to cleanup.
delete(h.PostHideListener);
h.PostHideListener = [];
h.cleanup();

