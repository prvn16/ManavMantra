function watchoff(figHandle)
%WATCHOFF Sets the given figure pointer to the arrow.
%   WATCHOFF(figHandle) will set the figure's pointer
%   to an arrow. If no argument is given, figHandle is taken to
%   be the current figure.
%
%   See also WATCHON.

%   Ned Gulley, 6-21-93
%   Copyright 1984-2014 The MathWorks, Inc.

if nargin<1
    figHandle = gcf;
end

% If watchon is used before a window has been opened, it will set the
% figHandle to the flag [].  In addition it is generally desirable to not
% error if the window has been closed between calls to watchon and
% watchoff.  ishghandle handles both of these cases.

if ishghandle(figHandle)
    set(figHandle,'Pointer','arrow');
end
