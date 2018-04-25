function m = getPanelMargins( panel )
% This function is undocumented and will change in a future release

% Copyright 2015 The MathWorks, Inc.

% Get panel margins in pixels
parent = get(panel, 'Parent'); 
if isempty(parent)
    m = [0 0];
    return;
end   
    
titlePosition = get(panel, 'TitlePosition');
borderType = get(panel, 'BorderType');
borderWidth = floor(get(panel, 'BorderWidth'));
switch titlePosition
    case {'lefttop','centertop','righttop'}
        switch borderType
            case 'none'
                m = [0 0];
            case {'line','beveledin','beveledout'}
                m = borderWidth * [1 1];
            otherwise
                m = borderWidth * [2 2];
        end
    case {'leftbottom','centerbottom','rightbottom'}
        fig = ancestor(panel, 'figure');
        outerPosition = hgconvertunits( fig, get(panel, 'Position'), get(panel, 'Units'), 'pixels', parent);
        innerPosition = hgconvertunits( fig, [0 0 1 1], 'normalized', 'pixels', panel );
        switch borderType
            case 'none'
                m = [0 outerPosition(4) - innerPosition(4)];
            case {'line','beveledin','beveledout'}
                m = [0 outerPosition(4) - innerPosition(4)] + borderWidth * [1 -1];
            otherwise
                m = [0 outerPosition(4) - innerPosition(4)] + borderWidth * [2 -2];
        end
end
