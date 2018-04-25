function h = gca(fig)
%GCA Get handle to current axis.
%   H = GCA returns the handle to the current axis in the current
%   figure. The current axis is the axis that graphics commands
%   like PLOT, TITLE, SURF, etc. draw to if issued.
%   Use the commands AXES or SUBPLOT to change the current axis
%   to a different axis, or to create new ones.
%
%   See also AXES, SUBPLOT, DELETE, CLA, HOLD, GCF, GCBO, GCO, GCBF.

%   H = GCA(FIG) returns the handle to the current axis in the
%   specified figure (it need not be the current figure).
%
%   Copyright 1984-2006 The MathWorks, Inc.

if nargin == 0
  fig = gcf;
end

h = get(fig,'CurrentAxes');

% 'CurrentAxes' is no longer guaranteed to return an axes,
% so we might need to create one (because gca IS guaranteed to
% return an axes)
if isempty(h)
    h = axes('parent',fig);
end

end
