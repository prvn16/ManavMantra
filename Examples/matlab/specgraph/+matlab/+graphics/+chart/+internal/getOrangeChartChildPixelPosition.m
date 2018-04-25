function [ pos ] = getOrangeChartChildPixelPosition( ch )
%getOrangeChartChildPixelPosition calculates position of orange chart child

    % Copyright 2017 The MathWorks, Inc.
    
container = ancestor(ch,'matlab.ui.container.CanvasContainer');        
relativeaxesposition = hgconvertunits(ancestor(ch,'figure'),ch.Position_I,ch.Units,...
                 'Pixels',container);
             
if ishghandle(container,'figure')
    pos = relativeaxesposition;
else
    contpixelpos = getpixelposition(container,true);
    if (isa(container, 'matlab.ui.container.Panel'))
        contpixelpos = contpixelpos + [matlab.ui.internal.getPanelMargins(container) 0 0];
    end
    pos(1:2) = contpixelpos(1:2) + relativeaxesposition(1:2);
    pos(3:4) = relativeaxesposition(3:4);
end