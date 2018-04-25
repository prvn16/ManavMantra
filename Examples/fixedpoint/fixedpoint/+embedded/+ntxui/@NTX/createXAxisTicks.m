function createXAxisTicks(ntx)
% Update x-axis tick labels, of the form "2^-N"
% These represent bit weights at histogram bin centers

%   Copyright 2010 The MathWorks, Inc.

% Find widest tick label we might render
% It's either the min or max x-axis limit
% e.g., min may be '2^-10' while max may be '2^32'
xmin = ntx.XAxisDisplayMin;
xmax = ntx.XAxisDisplayMax;
minSpacing = findMinXTickSpacing(ntx,xmin,xmax);
if minSpacing <= 0
    minSpacing = 1;
end
% Construct x-tick label positions, and update the x-axis
xList = xmin : minSpacing : xmax;

% Manage list of text handles
hax = ntx.hHistAxis;
hText = ntx.hTicks; % get current list of handles
Nalloc = numel(hText);
Nneeded = numel(xList);
if Nalloc >= Nneeded
    % NOTE: Need to enter here when "==", so visibilities are updated
    %       when no change to # allocated objects occurs
    %
    % We have more x-tick text labels than currently needed
    % We could delete the excess, but it's a performance optimization to
    % keep them all and reuse them.  In a later update, we may find we need
    % more.  Deleting and reallocating costs time.
    
    % Delete excess text objects
    %delete(hText(Nneeded+1:end));
    %hText(Nneeded+1:end) = [];
    
    % Keep extra text labels, just make them invis
    % We'll probably need to use these again later
    set(hText(Nneeded+1:end),'Visible','off');
    set(hText(1:Nneeded),'Visible','on');
    
elseif Nalloc < Nneeded
    % turn on any cached invisible text widgets
    % Allocate additional if we exhaust those
    
    % Turn on all allocated labels
    set(hText,'Visible','on');
    
    % Allocate additional
    % reverse order of indexing used to preallocate entries
    for i = Nneeded:-1:Nalloc+1
        hText(i) = text('Parent',hax, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','top', ...
        'Visible','On',...
        'Tag','xtlabel'); 
    end
end

% Update with created/deleted handles
ntx.hTicks = hText;

% Set tick mark locations on underlying (invisible) axis scale
% This aligns our data bars with our axis ticks
set(hax,'XTick',xList);

% If axis is no longer being rendered, because it's very small in size,
% etc, suppress visibility of x-ticks
pos = get(hax,'Position'); % any units, doesn't matter
if any(pos(3:4)<=0)
    set(hText(1:Nneeded),'Visible','off');
    return
end

for i = 1:Nneeded
    % Create TeX-formatted label at the right x-axis data location.
    %
    % Use a tentative y-axis position in data space; here we use "0%" to
    % put the top of the text just below the 0-percent line.
    % This will be readjusted afterward.
    set(hText(i), ...
        'String',sprintf('2^{%d}',xList(i)), ...
        'Units','data', ...
        'Visible','On',...
        'Position', [xList(i) 0]); % bogus y-value for now, 
    set(hText(i),'Units','pix');
end
