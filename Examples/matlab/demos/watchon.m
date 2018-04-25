function figHandle = watchon

%WATCHON Sets the current figure pointer to the watch.
%   figHandle = WATCHON will set the current figure's pointer
%   to a watch.
%
%   See also WATCHOFF.

%   Ned Gulley, 6-21-93
%   Copyright 1984-2014 The MathWorks, Inc.

% If there are no windows open, just set figHandle to a flag value.
if isempty(get(0,'Children')),
    figHandle = NaN;
else
    figHandle = gcf;
    set(figHandle,'Pointer','watch');
end
