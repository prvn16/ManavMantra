function updateXAxisTextPos(ntx)
% Update the text positions of x-axis ticks and labels
% Updates both the x and y positoin of x-axis text.
% No updates to axis limits or label strings are made

%   Copyright 2010 The MathWorks, Inc.

% Update x-axis tick positions
%
hTicks = ntx.hTicks; % could have more tick labels than needed
xticks = get(ntx.hHistAxis,'XTick'); % numeric tick locations
N = numel(xticks);
for i = 1:N
    % Adjust the y-axis of text labels
    % Setting the top of text to 0% is too close.
    % We need to go to "character" coords to do this right
    ht_i = hTicks(i);
    
    % Update y-pos first
    % This coord can change significantly under unit-conversion
    % Let it go where it needs to go...
    set(ht_i,'Units','char');
    pos = get(ht_i,'Position');
    pos(2) = -0.25;  % set y-pos
    set(ht_i,'Position',pos);
    
    % Update x-pos
    % This coord must be rock-solid so labels line up with ticks
    set(ht_i,'Units','data')
    pos = get(ht_i,'Position');
    pos(1) = xticks(i); % set x-pos
    set(ht_i,'Position',pos);
    
    % Leave tick labels in pixel units, so labels don't move
    % during y-axis changes, etc
    set(ht_i,'Units','pix');
end

% Update x-axis title position
%  - center on x-axis data limits
%  - place one char below x-tick labels
hXLabel = ntx.htXLabel;
set(hXLabel,'Units','data');
pos = get(hXLabel,'Position');
xlim = get(ntx.hHistAxis,'XLim');
pos(1) = sum(xlim)/2;
set(hXLabel,'Position',pos);

% Set y-pos of label in char units
set(hXLabel,'Units','char');
pos = get(hXLabel,'Position');
pos(2) = -1.75; % chars below axis ticks, leaving room for superscript
set(hXLabel,'VerticalAlignment','top','Position',pos);

% Restore back to pixels
set(hXLabel,'Units','pix');
