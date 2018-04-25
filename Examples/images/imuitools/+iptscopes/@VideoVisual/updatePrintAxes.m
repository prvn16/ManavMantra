function updatePrintAxes( this,inputFig )
%UPDATEPRINTAXES Makes video visual specific updates for Printing
%   Updates the axis limits for the zoom feature in video visuals. Resets 
%   the position of print axes and print figure.

%   Copyright 2010-2015 The MathWorks, Inc.


% If the data source is empty there is no video in the scope. The scope
% could be blank or with a text message.
% Adding screen message check as Dataype wil not be cleared if we get text 
% after a video visual - g678156
if ~isempty(this.DataType) && ~this.Application.screenMsg
    
    % Get the default print axes set on the print to figure
    printAxes = get(inputFig,'CurrentAxes');

    % Video Visual uses scrollableAPI's magnification. Use the
    % magnification of the scroll panel and use it to set the position and
    % axes limits of print axes.
    hScrollable = this.ScrollPanel;
    scrollpanelAPI = iptgetapi(hScrollable);
    mag  = scrollpanelAPI.getMagnification();
    vis_rect = scrollpanelAPI.getVisibleImageRect();

    newWidth  = (mag) * vis_rect(3);
    newHeight = (mag) * vis_rect(4);
    xlim = vis_rect(1) + [0 vis_rect(3)];
    ylim = vis_rect(2) + [0 vis_rect(4)];

    oldPosition = get(inputFig ,'Position');

    % Resize the print to figure to accommodate for any resize in scope 
    % window.
    figCenter = [oldPosition(1) + oldPosition(3)/2 ...
        oldPosition(2) + oldPosition(4)/2];
        
    % Reset the position figure
    fig_left   = figCenter(1) - newWidth/2;
    fig_bottom = figCenter(2) - newHeight/2;
    fig_position = [fig_left fig_bottom newWidth newHeight];

    set(inputFig ,'Position',fig_position);

    % Reset some properties (axes limits and position) 
    set(printAxes, 'Units', 'normalized', ...
        'Position', [0 0 1 1], ...
        'XLim', xlim,...
        'YLim', ylim);


end