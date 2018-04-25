function focusCurrentFigure
%FOCUSCURRENTFIGURE  Support function for Plot Picker component.

% Copyright 2012 The MathWorks, Inc.

% Bring the current figure to the front, if there is one
if ~isempty(get(0,'CurrentFigure'))
    figure(gcf);
end